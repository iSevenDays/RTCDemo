//
//  CallService.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 09.12.16.
//  Copyright © 2016 anton. All rights reserved.
//

import Foundation

enum CallServiceState {
	case Undefined
	case Connecting
	case Connected
	case Disconnected
	case Error
}

public class CallService: NSObject {
	
	internal var observers: MulticastDelegate<CallServiceObserver>?
	
	internal var sessions: [String: SessionDetails] = [:]
	/// SessionID: Connections
	var connections: [String: [PeerConnection]] = [:]
	var pendingRequests: [SVUser: CallServicePendingRequest] = [:]
	
	var state = CallServiceState.Undefined {
		didSet(oldValue) {
			assert(state != oldValue)
			observers => { $0.callService(self, didChangeState: self.state) }
		}
	}
	
	var signalingProcessor: SignalingProcessor!
	var timersFactory: TimersFactory!
	
	// MARK: - RTC properties
	internal let factory = RTCPeerConnectionFactory()
	
	// Injected dependencies
	var cacheService: CacheServiceProtocol!
	var defaultOfferConstraints: RTCMediaConstraints!
	var defaultAnswerConstraints: RTCMediaConstraints!
	var defaultPeerConnectionConstraints: RTCMediaConstraints!
	var defaultMediaStreamConstraints: RTCMediaConstraints!
	var defaultConfigurationWithCurrentICEServers: RTCConfiguration!
	var signalingChannel: SignalingChannelProtocol!
	var ICEServers: [RTCICEServer]!
	
	internal var dialingTimers: [SVUser: SVTimer] = [:]
	
	/// Return active connection for opponenID with given session ID
	func connectionWithSessionID(sessionID: String, opponent: SVUser) -> PeerConnection? {
		return connections[sessionID]?.filter({$0.opponent.ID == opponent.ID}).first
	}
}

enum CallServiceError: ErrorType {
	case notLogined
}

extension CallService: CallServiceProtocol {
	var isConnected: Bool {
		return signalingChannel.isConnected
	}
	
	var isConnecting: Bool {
		return signalingChannel.isConnecting
	}
	
	var currentUser: SVUser? {
		return signalingChannel.user
	}
	
	var hasActiveCall: Bool {
		let peerConnections = connections.flatMap({$0.1})
		return peerConnections.contains({$0.state == PeerConnectionState.Initial})
	}
	
	func addObserver(observer: CallServiceObserver) {
		observers += observer
	}
	
	func connectWithUser(user: SVUser, completion: ((error: NSError?) -> Void)?) {
		assert(user.password != nil)
		state = .Connecting
		
		do{
			try signalingChannel.connectWithUser(user) { [unowned self] (error) in
				self.state = (error == nil) ? .Connected : .Error
				completion?(error: error)
			}
		} catch let error {
			NSLog("%@", "Error conencting with user \(error)")
		}
	}
	
	func disconnectWithCompletion(completion: ((error: NSError?) -> Void)?) {
		signalingChannel.disconnectWithCompletion { [unowned self] (error) in
			if error == nil {
				self.state = .Disconnected
			}
			completion?(error: error)
		}
	}
	
	func startCallWithOpponent(user: SVUser) throws {
		guard let currentUserID = self.currentUser?.ID?.unsignedIntegerValue else {
			throw CallServiceError.notLogined
		}
		let sessionDetails = SessionDetails(initiatorID: currentUserID, membersIDs: [currentUserID, user.ID!.unsignedIntegerValue])
		sessions[sessionDetails.sessionID] = sessionDetails
		
		let connection = PeerConnection(opponent: user, sessionID: sessionDetails.sessionID, ICEServers: ICEServers, factory: factory, mediaStreamConstraints: defaultMediaStreamConstraints, peerConnectionConstraints: defaultPeerConnectionConstraints, offerAnswerConstraints: defaultOfferConstraints)
		connection.addObserver(self)
		connections[sessionDetails.sessionID] = [connection]
		
		connection.startCall()
	}
	
	func acceptCallFromOpponent(opponent: SVUser) {
		guard let pendingRequest = pendingRequests[opponent] else {
			NSLog("Error: no pending offer for opponent")
			return
		}
		
		let sessionDetails = pendingRequest.sessionDetails
		sessions[sessionDetails.sessionID] = sessionDetails
		
		let connection = PeerConnection(opponent: opponent, sessionID: sessionDetails.sessionID, ICEServers: ICEServers, factory: factory, mediaStreamConstraints: defaultMediaStreamConstraints, peerConnectionConstraints: defaultPeerConnectionConstraints, offerAnswerConstraints: defaultOfferConstraints)
		connection.addObserver(self)
		connections[sessionDetails.sessionID] = [connection]
		
		connection.acceptCall()
		connection.applyRemoteSDP(pendingRequest.pendingSessionDescription)
	}
	
	func hangup() {
		let peerConnections = connections.flatMap({$0.1})
		peerConnections.filter({$0.state == PeerConnectionState.Initial}).forEach({ $0.close() })
		dialingTimers.forEach { [unowned self] (user, timer) in
			self.stopDialingOpponent(user)
		}
	}
	
	func sendRejectCallToOpponent(opponent: SVUser) {
		guard let pendingRequest = pendingRequests[opponent] else {
			NSLog("Error: can not reject a call, no pending offer for opponent")
			return
		}
		let sessionDetails = pendingRequest.sessionDetails
		sessionDetails.sessionState = .Rejected
		sessions[sessionDetails.sessionID] = sessionDetails
		
		signalingChannel.sendMessage(SignalingMessage.reject, withSessionDetails: sessionDetails, toUser: opponent, completion: nil)
		
		pendingRequests[opponent] = nil
	}
	
	// MARK: - Repeated actions
	func startDialingOpponent(opponent: SVUser, withMessage message: SignalingMessage, sessionDetails: SessionDetails) {
		let sendMessageBlock = { [weak self] in
			self?.signalingChannel.sendMessage(message, withSessionDetails: sessionDetails, toUser: opponent, completion: nil)
		}
		sendMessageBlock()
		
		observers => { $0.callService(self, didStartDialingOpponent: opponent) }
		
		let dialingTimer = timersFactory.createDialingTimerWithExpirationTime(20000, block: sendMessageBlock) { [unowned self] in
			self.observers => { $0.callService(self, didAnswerTimeoutForOpponent: opponent) }
		}
		dialingTimer.start()
		sendMessageBlock()
		dialingTimers[opponent] = dialingTimer
	}
	
	func stopDialingOpponent(opponent: SVUser) {
		if let timer = dialingTimers[opponent] {
			if timer.isValid {
				timer.cancel()
			}
			dialingTimers[opponent] = nil
			observers => { $0.callService(self, didStopDialingOpponent: opponent) }
		}
	}
}

extension CallService: SignalingProcessorObserver {
	func didReceiveICECandidates(signalingProcessor: SignalingProcessor, ICECandidates: [RTCICECandidate], fromOpponent opponent: SVUser, sessionDetails: SessionDetails) {
		connectionWithSessionID(sessionDetails.sessionID, opponent: opponent)?.applyICECandidates(ICECandidates)
	}
	
	func didReceiveOffer(signalingProcessor: SignalingProcessor, offer: RTCSessionDescription, fromOpponent opponent: SVUser, sessionDetails: SessionDetails) {
		NSLog("didReceiveOffer")
		pendingRequests[opponent] = CallServicePendingRequest(initiator: opponent, pendingSessionDescription: offer, sessionDetails: sessionDetails)
		
		guard !hasActiveCall else {
			sendRejectCallToOpponent(opponent)
			return
		}
		
		if let session = sessions[sessionDetails.sessionID] {
			guard session.sessionState != SessionDetailsState.Rejected else {
				NSLog("declined rejected session")
				return
			}
		} else {
			observers => { $0.callService(self, didReceiveCallRequestFromOpponent: opponent) }
		}
	}
	
	func didReceiveAnswer(signalingProcessor: SignalingProcessor, answer: RTCSessionDescription, fromOpponent opponent: SVUser, sessionDetails: SessionDetails) {
		NSLog("didReceiveAnswer")
		if let connection = connectionWithSessionID(sessionDetails.sessionID, opponent: opponent) {
			connection.applyRemoteSDP(answer)
			observers => { $0.callService(self, didReceiveAnswerFromOpponent: opponent) }
			stopDialingOpponent(opponent)
		}
	}
	
	func didReceiveHangup(signalingProcessor: SignalingProcessor, fromOpponent opponent: SVUser, sessionDetails: SessionDetails) {
		NSLog("didReceiveHangup")
		pendingRequests[opponent] = nil
		if let activeConnection = connectionWithSessionID(sessionDetails.sessionID, opponent: opponent) {
			activeConnection.close()
			observers => { $0.callService(self, didReceiveHangupFromOpponent: opponent) }
			stopDialingOpponent(opponent)
		}
	}
	
	func didReceiveReject(signalingProcessor: SignalingProcessor, fromOpponent opponent: SVUser, sessionDetails: SessionDetails) {
		NSLog("didReceiveReject")
		pendingRequests[opponent] = nil
		if let activeConnection = connectionWithSessionID(sessionDetails.sessionID, opponent: opponent) {
			activeConnection.close()
			observers => { $0.callService(self, didReceiveRejectFromOpponent: opponent) }
			stopDialingOpponent(opponent)
		}
	}
}

extension CallService: PeerConnectionObserver {
	
	// Current User has an offer to send
	func peerConnection(peerConnection: PeerConnection, didSetLocalSessionOfferDescription localSessionOfferDescription: RTCSessionDescription) {
		let sessionDetails = sessions[peerConnection.sessionID]!
		let opponent = peerConnection.opponent
		let offerSDP = RTCSessionDescription(type: SignalingMessageType.offer.rawValue, sdp: localSessionOfferDescription.description)
		let offerMessage = SignalingMessage.offer(sdp: offerSDP)
		startDialingOpponent(opponent, withMessage: offerMessage, sessionDetails: sessionDetails)
	}
	
	// Current User has an answer to send
	func peerConnection(peerConnection: PeerConnection, didSetLocalSessionAnswerDescription localSessionAnswerDescription: RTCSessionDescription) {
		let sessionDetails = sessions[peerConnection.sessionID]!
		let answerSDP = RTCSessionDescription(type: SignalingMessageType.answer.rawValue, sdp: localSessionAnswerDescription.description)
		let opponent = peerConnection.opponent
		sendSignalingMessageSDP(SignalingMessage.answer(sdp: answerSDP), withSessionDetails: sessionDetails, toOpponent: opponent)
	}
	
	func sendSignalingMessageSDP(message: SignalingMessage, withSessionDetails sessionDetails: SessionDetails, toOpponent opponent: SVUser) {
		signalingChannel.sendMessage(message, withSessionDetails: sessionDetails, toUser: opponent) { [unowned self] (error) in
			if let error = error {
				self.observers => { $0.callService(self, didErrorSendingLocalSessionDescriptionMessage: message, toOpponent: opponent, error: error) }
			} else {
				self.observers => { $0.callService(self, didSendLocalSessionDescriptionMessage: message, toOpponent: opponent) }
			}
		}
	}
	
	func peerConnection(peerConnection: PeerConnection, didSetLocalICECandidates localICECandidates: RTCICECandidate) {
		let sessionDetails = sessions[peerConnection.sessionID]!
		let signalingMessage = SignalingMessage.candidates(candidates: [localICECandidates])
		let opponent = peerConnection.opponent
		
		signalingChannel.sendMessage(signalingMessage, withSessionDetails: sessionDetails, toUser: opponent) { [unowned self] (error) in
			if let error = error {
				self.observers => { $0.callService(self, didErrorSendingLocalICECandidates: [localICECandidates], toOpponent: opponent, error: error) }
			} else {
				self.observers => { $0.callService(self, didSendLocalICECandidates: [localICECandidates], toOpponent: opponent) }
			}
		}
	}
	
	func peerConnection(peerConnection: PeerConnection, didReceiveLocalVideoTrack localVideoTrack: RTCVideoTrack) {
		observers => { $0.callService(self, didReceiveLocalVideoTrack: localVideoTrack) }
	}
	func peerConnection(peerConnection: PeerConnection, didReceiveRemoteVideoTrack remoteVideoTrack: RTCVideoTrack) {
		observers => { $0.callService(self, didReceiveRemoteVideoTrack: remoteVideoTrack) }
	}
	func peerConnection(peerConnection: PeerConnection, didCreateSessionWithError error: NSError) {
		observers => { $0.callService(self, didError: error) }
	}
}
