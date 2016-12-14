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
	func activeConnectionWithSessionID(sessionID: String, opponent: SVUser) -> PeerConnection? {
		return connections[sessionID]?.filter({$0.opponent.ID == opponent.ID && $0.state == PeerConnectionState.Initial}).first
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
	
	/**
	Return true when at least one connection is active (not closed)
	Currently if hasActiveCall is true, incoming calls are rejected
	*/
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
			NSLog("%@", "Error connecting with user \(error)")
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
	
	// MARK: - Call start
	
	/**
	Start call with an opponent
	
	Creates SessionDetails instance, creates new PeerConnection
	After PeerConnection initialized, peerConnection:didSetLocalSessionOfferDescription: will be called
	And then method startDialing with the opponent will be executed
	
	- parameter user: SVUser instance
	
	- throws: throws CallServiceError.notLogined exception in case user is not logged in
	*/
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
	
	// MARK: - Dialing
	
	/**
	Start dialing an opponent with a message and session details
	
	The message will be repeatedly sent to the opponent
	If the opponent will not answer within 20 seconds, didAnswerTimeoutForOpponent: will be called
	
	- parameter opponent:       SVUser instance
	- parameter message:        SignalingMessage instance
	- parameter sessionDetails: SessionDetails instance
	*/
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
	
	/**
	Stop dialing an opponent
	In case there was a dialing, didStopDialingOpponent: will be called
	
	- parameter opponent: SVUser instance
	*/
	func stopDialingOpponent(opponent: SVUser) {
		if let timer = dialingTimers[opponent] {
			if timer.isValid {
				timer.cancel()
			}
			dialingTimers[opponent] = nil
			observers => { $0.callService(self, didStopDialingOpponent: opponent) }
		}
	}
	
	// MARK: - Ending a call
	
	/**
	Reject an incoming call
	Marks a session details for the incoming call as .Rejected
	Messages for the rejected session will be ignored
	
	- parameter opponent: SVUser instance
	*/
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
		
		observers => { $0.callService(self, didSendRejectToOpponent: opponent) }
	}
	
	func hangup() {
		for user in dialingTimers.keys {
			self.stopDialingOpponent(user)
		}
		
		for connection in connections.values.flatten() where connection.state == PeerConnectionState.Initial {
			connection.close()
			guard let sessionDetails = sessions[connection.sessionID] else {
				NSLog("Error: no session details for connection with session ID: \(connection.sessionID))")
				continue
			}
			signalingChannel.sendMessage(SignalingMessage.hangup, withSessionDetails: sessionDetails, toUser: connection.opponent, completion: nil)
			observers => { $0.callService(self, didSendHangupToOpponent: connection.opponent) }
		}
	}	
}

// MARK: - SignalingProcessorObserver
extension CallService: SignalingProcessorObserver {
	func didReceiveICECandidates(signalingProcessor: SignalingProcessor, ICECandidates: [RTCICECandidate], fromOpponent opponent: SVUser, sessionDetails: SessionDetails) {
		activeConnectionWithSessionID(sessionDetails.sessionID, opponent: opponent)?.applyICECandidates(ICECandidates)
	}
	
	func didReceiveOffer(signalingProcessor: SignalingProcessor, offer: RTCSessionDescription, fromOpponent opponent: SVUser, sessionDetails: SessionDetails) {
		NSLog("didReceiveOffer")
		guard activeConnectionWithSessionID(sessionDetails.sessionID, opponent: opponent) == nil else {
			// The second and further offer for a call for the same user for the same session
			// We already have connection, so just skip it
			// User may send many requests for one call in case some messages may be not delivered
			return
		}
		
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
		if let connection = activeConnectionWithSessionID(sessionDetails.sessionID, opponent: opponent) {
			connection.applyRemoteSDP(answer)
			observers => { $0.callService(self, didReceiveAnswerFromOpponent: opponent) }
			stopDialingOpponent(opponent)
		}
	}
	
	func didReceiveHangup(signalingProcessor: SignalingProcessor, fromOpponent opponent: SVUser, sessionDetails: SessionDetails) {
		NSLog("didReceiveHangup")
		pendingRequests[opponent] = nil
		if let connection = activeConnectionWithSessionID(sessionDetails.sessionID, opponent: opponent) {
			connection.close()
			observers => { $0.callService(self, didReceiveHangupFromOpponent: opponent) }
			stopDialingOpponent(opponent)
		}
	}
	
	func didReceiveReject(signalingProcessor: SignalingProcessor, fromOpponent opponent: SVUser, sessionDetails: SessionDetails) {
		NSLog("didReceiveReject")
		pendingRequests[opponent] = nil
		if let connection = activeConnectionWithSessionID(sessionDetails.sessionID, opponent: opponent) {
			connection.close()
			observers => { $0.callService(self, didReceiveRejectFromOpponent: opponent) }
			stopDialingOpponent(opponent)
		}
	}
}

// MARK: - PeerConnectionObserver

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
