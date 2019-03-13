//
//  CallService.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 09.12.16.
//  Copyright © 2016 anton. All rights reserved.
//

import Foundation

enum CallServiceState {
	case undefined
	case connecting
	case connected
	case disconnected
	case error
}

enum CallServiceError: Error {
	case notLogined
	case noPendingOfferForOpponent
	case canNotRejectCallWithoutPendingOffer
}

@objc open class CallService: NSObject {
	
	internal var observers = MulticastDelegate<CallServiceObserver>()
	internal var chatRoomObservers = MulticastDelegate<CallServiceChatRoomObserver>()
	
	internal var sessions: [String: SessionDetails] = [:]
	/// SessionID: Connections
	var connections: [String: [PeerConnection]] = [:]
	var pendingRequests: [SVUser: CallServicePendingRequest] = [:]
	
	var state = CallServiceState.undefined {
		didSet {
			observers |> { $0.callService(self, didChangeState: self.state) }
		}
	}
	
	var signalingProcessor: SignalingProcessor!
	var timersFactory: TimersFactory!
	
	// MARK: - RTC properties
	internal let factory: RTCPeerConnectionFactory = {
		let decoderFactory = RTCDefaultVideoDecoderFactory()
		let encoderFactory = RTCDefaultVideoEncoderFactory()
		let defaultVideoCodecInfo = RTCVideoCodecInfo(name: kRTCVideoCodecH264Name)
		encoderFactory.preferredCodec = defaultVideoCodecInfo
		let factory = RTCPeerConnectionFactory(encoderFactory: encoderFactory, decoderFactory: decoderFactory)
		return factory
	}()
	
	// Injected dependencies
	var cacheService: CacheServiceProtocol!
	var defaultOfferConstraints: RTCMediaConstraints!
	var defaultAnswerConstraints: RTCMediaConstraints!
	var defaultPeerConnectionConstraints: RTCMediaConstraints!
	var defaultMediaStreamConstraints: RTCMediaConstraints!
	var defaultConfigurationWithCurrentICEServers: RTCConfiguration!
	var signalingChannel: SignalingChannelProtocol!
	var ICEServers: [RTCIceServer]!
	
	internal var dialingTimers: [SVUser: SVTimer] = [:]
	
	/// Return active connection for opponenID with given session ID
	func activeConnectionWithSessionID(_ sessionID: String, opponent: SVUser) -> PeerConnection? {
		return connections[sessionID]?.filter({$0.opponent.id == opponent.id && $0.state == PeerConnectionState.initial}).first
	}
}

extension CallService: CallServiceProtocol {
	@objc var isConnected: Bool {
		return signalingChannel.isConnected
	}
	
	@objc var isConnecting: Bool {
		return signalingChannel.isConnecting
	}
	
	var currentUser: SVUser? {
		return signalingChannel.user
	}
	
	/**
	Return true when at least one connection is active (not closed)
	Currently if hasActiveCall is true, incoming calls are rejected
	*/
	var hasActiveCall: Bool {
		let peerConnections = connections.flatMap({$0.1})
		return peerConnections.contains { (peerConnection) -> Bool in
			let isIncluded = peerConnection.state == .initial
			return isIncluded
		}
	}
	
	func addObserver(_ observer: CallServiceObserver) {
		observers += observer
	}
	
	func removeObserver(_ observer: CallServiceObserver) {
		observers -= observer
	}
	
	func connectWithUser(_ user: SVUser, completion: ((_ error: Error?) -> Void)?) {
		assert(user.password != nil)
		state = .connecting
		
		signalingChannel.addObserver(self)
		signalingChannel.addObserver(signalingProcessor)
		
		do{
			try signalingChannel.connectWithUser(user) { [unowned self] (error) in
				self.state = (error == nil) ? .connected : .error
				completion?(error)
			}
		} catch let error {
			NSLog("%@", "Error connecting with user \(error)")
		}
	}
	
	func disconnectWithCompletion(_ completion: ((_ error: Error?) -> Void)?) {
		signalingChannel.disconnectWithCompletion { [unowned self] (error) in
			if error == nil {
				self.state = .disconnected
			}
			completion?(error)
		}
	}
	
	// MARK: - Call start
	
	/**
	Start call with opponent
	
	Creates SessionDetails instance, creates new PeerConnection
	After PeerConnection initialized, peerConnection:didSetLocalSessionOfferDescription: will be called
	And then method startDialing with the opponent will be executed
	
	- parameter user: SVUser instance
	
	- throws: throws CallServiceError.notLogined exception in case user is not logged in
	*/
	@objc func startCallWithOpponent(_ user: SVUser) throws {
		guard let currentUserID = self.currentUser?.id?.uintValue else {
			throw CallServiceError.notLogined
		}
		let sessionDetails = SessionDetails(initiatorID: currentUserID, membersIDs: [currentUserID, user.id!.uintValue])
		sessions[sessionDetails.sessionID] = sessionDetails

		assert(ICEServers != nil)
		assert(defaultMediaStreamConstraints != nil)
		assert(defaultPeerConnectionConstraints != nil)

		let connection = PeerConnection(opponent: user, sessionID: sessionDetails.sessionID, ICEServers: ICEServers, factory: factory, mediaStreamConstraints: defaultMediaStreamConstraints, peerConnectionConstraints: defaultPeerConnectionConstraints, offerAnswerConstraints: defaultOfferConstraints)
		connection.addObserver(self)
		connections[sessionDetails.sessionID] = [connection]
		
		connection.startCall()
	}
	
	func acceptCallFromOpponent(_ opponent: SVUser) throws {
		guard let pendingRequest = pendingRequests[opponent] else {
			throw CallServiceError.noPendingOfferForOpponent
		}
		
		let sessionDetails = pendingRequest.sessionDetails
		sessions[sessionDetails.sessionID] = sessionDetails
		
		let connection = PeerConnection(opponent: opponent, sessionID: sessionDetails.sessionID, ICEServers: ICEServers, factory: factory, mediaStreamConstraints: defaultMediaStreamConstraints, peerConnectionConstraints: defaultPeerConnectionConstraints, offerAnswerConstraints: defaultOfferConstraints)
		connection.addObserver(self)
		connections[sessionDetails.sessionID] = [connection]
	
		connection.acceptCall()
		connection.applyRemoteSDP(pendingRequest.pendingSessionDescription)
		
		pendingRequests[opponent] = nil
	}
	
	// MARK: - Dialing
	
	/**
	Start dialing an opponent with a message and session details
	
	The message will be repeatedly sent to the opponent
	If the opponent will not answer within 20 seconds, didAnswerTimeoutForOpponent: will be called
	
	- parameter opponent:       SVUser instance
	- parameter message:        SignalingMessage instance
	- parameter sessionDetails: SessionDetails instance
	*/
	func startDialingOpponent(_ opponent: SVUser, withMessage message: SignalingMessage, sessionDetails: SessionDetails) {
		assert(timersFactory != nil)
		let sendMessageBlock = { [weak self] in
			self?.signalingChannel.sendMessage(message, withSessionDetails: sessionDetails, toUser: opponent, completion: nil)
		}
		sendMessageBlock()
		
		observers |> { $0.callService(self, didStartDialingOpponent: opponent) }
		
		let dialingTimer = timersFactory.createDialingTimerWithExpirationTime(45000, block: sendMessageBlock) { [unowned self] in
			self.observers |> { $0.callService(self, didAnswerTimeoutForOpponent: opponent) }
			self.stopDialingOpponent(opponent)
			self.activeConnectionWithSessionID(sessionDetails.sessionID, opponent: opponent)?.close()
		}
		dialingTimer.start()
		sendMessageBlock()
		dialingTimers[opponent] = dialingTimer
	}
	
	/**
	Stop dialing an opponent
	In case there was a dialing, didStopDialingOpponent: will be called
	
	- parameter opponent: SVUser instance
	*/
	func stopDialingOpponent(_ opponent: SVUser) {
		if let timer = dialingTimers[opponent] {
			if timer.isValid {
				timer.cancel()
			}
			dialingTimers[opponent] = nil
			observers |> { $0.callService(self, didStopDialingOpponent: opponent) }
		}
	}
	
	// MARK: - Ending a call
	
	/**
	Reject an incoming call
	Marks a session details for the incoming call as .Rejected
	Messages for the rejected session will be ignored
	
	- parameter opponent: SVUser instance
	*/
	@objc func sendRejectCallToOpponent(_ opponent: SVUser) throws {
		guard let pendingRequest = pendingRequests[opponent] else {
			throw CallServiceError.canNotRejectCallWithoutPendingOffer
		}
		let sessionDetails = pendingRequest.sessionDetails
		sessionDetails.sessionState = .rejected
		sessions[sessionDetails.sessionID] = sessionDetails
		
		signalingChannel.sendMessage(SignalingMessage.reject, withSessionDetails: sessionDetails, toUser: opponent, completion: nil)
		
		pendingRequests[opponent] = nil
		
		observers |> { $0.callService(self, didSendRejectToOpponent: opponent) }
	}
	
	func hangup() {
		for user in dialingTimers.keys {
			self.stopDialingOpponent(user)
		}
		
		for connection in connections.values.joined() where connection.state == PeerConnectionState.initial {
			connection.close()
			guard let sessionDetails = sessions[connection.sessionID] else {
				NSLog("Error: no session details for connection with session ID: \(connection.sessionID))")
				continue
			}
			signalingChannel.sendMessage(SignalingMessage.hangup, withSessionDetails: sessionDetails, toUser: connection.opponent, completion: nil)
			observers |> { $0.callService(self, didSendHangupToOpponent: connection.opponent) }
		}
	}
}

extension CallService: CallServiceChatRoomProtocol {

	func addObserver(_ observer: CallServiceChatRoomObserver) {
		chatRoomObservers += observer
	}

	func removeObserver(_ observer: CallServiceChatRoomObserver) {
		chatRoomObservers -= observer
	}

	func sendMessageCurrentUserEnteredChatRoom(_ chatRoomName: String, toUser: SVUser) {
		let signalingMessage = SignalingMessage.user(enteredChatRoomName: chatRoomName)
		signalingChannel.sendMessage(signalingMessage, withSessionDetails: nil, toUser: toUser, completion: nil)
		chatRoomObservers |> { $0.callService(self, didSendUserEnteredChatRoomName: chatRoomName, toUser: toUser) }
	}
}

// MARK: - SignalingProcessorObserver
extension CallService: SignalingProcessorObserver {
	func didReceiveICECandidates(_ signalingProcessor: SignalingProcessor, ICECandidates: [RTCIceCandidate], fromOpponent opponent: SVUser, sessionDetails: SessionDetails) {
		activeConnectionWithSessionID(sessionDetails.sessionID, opponent: opponent)?.applyICECandidates(ICECandidates)
	}
	
	func didReceiveOffer(_ signalingProcessor: SignalingProcessor, offer: RTCSessionDescription, fromOpponent opponent: SVUser, sessionDetails: SessionDetails) {
		NSLog("didReceiveOffer")
		guard activeConnectionWithSessionID(sessionDetails.sessionID, opponent: opponent) == nil else {
			// The second and further offer for a call for the same user for the same session
			// We already have connection, so just skip it
			// User may send many requests for one call in case some messages may be not delivered
			return
		}
		
		guard !hasActiveCall else {
			_ = try? sendRejectCallToOpponent(opponent)
			return
		}
		
		if let session = sessions[sessionDetails.sessionID] {
			guard session.sessionState != SessionDetailsState.rejected else {
				NSLog("declined rejected session")
				return
			}
		} else {
			if pendingRequests[opponent] == nil {
				pendingRequests[opponent] = CallServicePendingRequest(initiator: opponent, pendingSessionDescription: offer, sessionDetails: sessionDetails)
				observers |> { $0.callService(self, didReceiveCallRequestFromOpponent: opponent) }
			}
		}
	}
	
	func didReceiveAnswer(_ signalingProcessor: SignalingProcessor, answer: RTCSessionDescription, fromOpponent opponent: SVUser, sessionDetails: SessionDetails) {
		NSLog("didReceiveAnswer")
		guard let connection = activeConnectionWithSessionID(sessionDetails.sessionID, opponent: opponent) else {
			return
		}
		connection.applyRemoteSDP(answer)
		observers |> { $0.callService(self, didReceiveAnswerFromOpponent: opponent) }
		stopDialingOpponent(opponent)
	}
	
	func didReceiveHangup(_ signalingProcessor: SignalingProcessor, fromOpponent opponent: SVUser, sessionDetails: SessionDetails) {
		NSLog("didReceiveHangup")
		pendingRequests[opponent] = nil
		if let connection = activeConnectionWithSessionID(sessionDetails.sessionID, opponent: opponent) {
			// Connection can be nil when we received incoming call and hasn't responded to it yet
			connection.close()
		}
		// Anyway, If we received hangup for pending offer,
		// then we should notify IncomingCallStory the opponent decided to decline the offer for a call
		observers |> { $0.callService(self, didReceiveHangupFromOpponent: opponent) }
		stopDialingOpponent(opponent)
		
	}
	
	func didReceiveReject(_ signalingProcessor: SignalingProcessor, fromOpponent opponent: SVUser, sessionDetails: SessionDetails) {
		NSLog("didReceiveReject")
		pendingRequests[opponent] = nil
		guard let connection = activeConnectionWithSessionID(sessionDetails.sessionID, opponent: opponent) else {
			return
		}
		connection.close()
		observers |> { $0.callService(self, didReceiveRejectFromOpponent: opponent) }
		stopDialingOpponent(opponent)
	}
}

// MARK: - PeerConnectionObserver

extension CallService: PeerConnectionObserver {
	
	// Current User has an offer to send
	func peerConnection(_ peerConnection: PeerConnection, didSetLocalSessionOfferDescription localSessionOfferDescription: RTCSessionDescription) {
		let sessionDetails = sessions[peerConnection.sessionID]!
		let opponent = peerConnection.opponent
		let offerSDP = RTCSessionDescription(type: .offer, sdp: localSessionOfferDescription.sdp)
		let offerMessage = SignalingMessage.offer(sdp: offerSDP)
		startDialingOpponent(opponent, withMessage: offerMessage, sessionDetails: sessionDetails)
	}
	
	// Current User has an answer to send
	func peerConnection(_ peerConnection: PeerConnection, didSetLocalSessionAnswerDescription localSessionAnswerDescription: RTCSessionDescription) {
		let sessionDetails = sessions[peerConnection.sessionID]!
		let answerSDP = RTCSessionDescription(type: .answer, sdp: localSessionAnswerDescription.sdp)
		let opponent = peerConnection.opponent
		sendSignalingMessageSDP(SignalingMessage.answer(sdp: answerSDP), withSessionDetails: sessionDetails, toOpponent: opponent)
	}
	
	func sendSignalingMessageSDP(_ message: SignalingMessage, withSessionDetails sessionDetails: SessionDetails, toOpponent opponent: SVUser) {
		signalingChannel.sendMessage(message, withSessionDetails: sessionDetails, toUser: opponent) { [unowned self] (error) in
			if let error = error {
				self.observers |> { $0.callService(self, didErrorSendingLocalSessionDescriptionMessage: message, toOpponent: opponent, error: error) }
			} else {
				self.observers |> { $0.callService(self, didSendLocalSessionDescriptionMessage: message, toOpponent: opponent) }
			}
		}
	}
	
	func peerConnection(_ peerConnection: PeerConnection, didSetLocalICECandidates localICECandidates: RTCIceCandidate) {
		let sessionDetails = sessions[peerConnection.sessionID]!
		let signalingMessage = SignalingMessage.candidates(candidates: [localICECandidates])
		let opponent = peerConnection.opponent
		
		signalingChannel.sendMessage(signalingMessage, withSessionDetails: sessionDetails, toUser: opponent) { [unowned self] (error) in
			if let error = error {
				self.observers |> { $0.callService(self, didErrorSendingLocalICECandidates: [localICECandidates], toOpponent: opponent, error: error) }
			} else {
				self.observers |> { $0.callService(self, didSendLocalICECandidates: [localICECandidates], toOpponent: opponent) }
			}
		}
	}
	
	func peerConnection(_ peerConnection: PeerConnection, didReceiveLocalVideoTrack localVideoTrack: RTCVideoTrack) {
		observers |> { $0.callService(self, didReceiveLocalVideoTrack: localVideoTrack) }
	}
	func peerConnection(_ peerConnection: PeerConnection, didReceiveLocalAudioTrack localAudioTrack: RTCAudioTrack) {
		observers |> { $0.callService(self, didReceiveLocalAudioTrack: localAudioTrack) }
	}
	func peerConnection(_ peerConnection: PeerConnection, didReceiveRemoteVideoTrack remoteVideoTrack: RTCVideoTrack) {
		observers |> { $0.callService(self, didReceiveRemoteVideoTrack: remoteVideoTrack) }
	}
	func peerConnection(_ peerConnection: PeerConnection, didCreateSessionWithError error: Error) {
		observers |> { $0.callService(self, didError: error) }
	}
	func didReceiveUser(_ signalingProcessor: SignalingProcessor, user: SVUser, forChatRoomName chatRoomName: String) {
		chatRoomObservers |> { $0.callService(self, didReceiveUser: user, forChatRoomName: chatRoomName) }
	}
}

extension CallService: SignalingChannelObserver {
	func signalingChannel(_ channel: SignalingChannelProtocol, didChangeState state: SignalingChannelState) {
		if state == .established {
			self.state = .connected
		}
	}
	
	func signalingChannel(_ channel: SignalingChannelProtocol, didReceiveMessage message: SignalingMessage, fromOpponent: SVUser, withSessionDetails sessionDetails: SessionDetails?) {
		
	}
}

// Video switcher
extension CallService: CallServiceCameraSwitcherProtocol {

	/// Switch device position(front or back camera) and return new state
	///
	/// - Parameters:
	///   - localVideoTrack: local video track
	///   - renderer: rendered to render a video
	/// - Returns: new state
	func switchCamera(forActivePeerConnectionWithLocalVideoTrack localVideoTrack: RTCVideoTrack, renderer: RenderableView) -> AVCaptureDevice.Position? {
		let peerConnections = connections.flatMap({$0.1})
		let activeConnections = peerConnections.filter { (peerConnection) -> Bool in
			let isIncluded = peerConnection.state == .initial
			return isIncluded
		}
		for activeConnection in activeConnections {
			guard activeConnection.localVideoTrack == localVideoTrack else {
				continue
			}
			guard let activeDevicePosition = activeConnection.localVideoCapturePosition() else {
				continue
			}
			let newPosition = activeDevicePosition == .front ? AVCaptureDevice.Position.back : AVCaptureDevice.Position.front
			activeConnection.startCaptureLocalVideo(renderer: renderer, position: newPosition)
			return newPosition
		}
		return nil
	}

	/// Switch device position and start rendering and return new state
	///
	/// - Parameters:
	///   - localVideoTrack: local video track
	///   - renderer: rendered to render a video
	/// - Returns: new state
	func setCamera(forActivePeerConnectionWithLocalVideoTrack localVideoTrack: RTCVideoTrack, renderer: RenderableView, position: AVCaptureDevice.Position) -> AVCaptureDevice.Position? {
		let peerConnections = connections.flatMap({$0.1})
		let activeConnections = peerConnections.filter { (peerConnection) -> Bool in
			let isIncluded = peerConnection.state == .initial
			return isIncluded
		}
		for activeConnection in activeConnections {
			guard activeConnection.localVideoTrack == localVideoTrack else {
				continue
			}
			activeConnection.startCaptureLocalVideo(renderer: renderer, position: position)
			guard let activeDevicePosition = activeConnection.localVideoCapturePosition() else {
				return nil
			}
			return activeDevicePosition
		}
		return nil
	}
}
