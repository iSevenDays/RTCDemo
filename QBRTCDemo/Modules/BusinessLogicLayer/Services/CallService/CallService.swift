//
//  CallService.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 09.12.16.
//  Copyright © 2016 anton. All rights reserved.
//

import Foundation

enum CallServiceState {
	case Undefined
	case Connecting
	case Connected
	case Error
}

class CallService: NSObject {
	
	internal var observers: MulticastDelegate<CallServiceObserver>?
	
	private var sessions: [String: SessionDetails] = [:]
	/// SessionID: Connections
	var connections: [String: [PeerConnection]] = [:]
	var pendingRequests: [SVUser: CallServicePendingRequest] = [:]
	
	var state = CallServiceState.Undefined
	
	// MARK: - RTC properties
	private let factory = RTCPeerConnectionFactory()
	private let signalingProcessor = SignalingProcessor()
	private var messagesQueue: [SVSignalingMessage] = []
	
	// Injected dependencies
	var cacheService: CacheServiceProtocol!
	var defaultOfferConstraints: RTCMediaConstraints!
	var defaultAnswerConstraints: RTCMediaConstraints!
	var defaultPeerConnectionConstraints: RTCMediaConstraints!
	var defaultMediaStreamConstraints: RTCMediaConstraints!
	var defaultConfigurationWithCurrentICEServers: RTCConfiguration!
	var signalingChannel: SVSignalingChannelProtocol!
	var ICEServers: [RTCICEServer]!
	
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
		return signalingChannel.isConnected()
	}
	
	var currentUser: SVUser? {
		return signalingChannel.user
	}
	
	func addObserver(observer: CallServiceObserver) {
		observers += observer
	}
	
	func connectWithUser(user: SVUser, completion: ((error: NSError?) -> Void)?) {
		assert(user.password != nil)
		state = .Connecting
		
		signalingChannel.connectWithUser(user) { [unowned self] (error) in
			self.state = (error == nil) ? .Connected : .Error
			completion?(error: error)
		}
	}
	
	func startCallWithOpponent(user: SVUser) throws {
		guard let currentUser = self.currentUser else {
			throw CallServiceError.notLogined
		}
		let sessionDetails = SessionDetails(initiator: currentUser, membersIDs: [currentUser.ID!.unsignedIntegerValue, user.ID!.unsignedIntegerValue])
		sessions[sessionDetails.sessionID] = sessionDetails
		
		let connection = PeerConnection(opponent: user, sessionID: sessionDetails.sessionID, ICEServers: ICEServers, factory: factory, mediaStreamConstraints: defaultMediaStreamConstraints, peerConnectionConstraints: defaultPeerConnectionConstraints, offerAnswerConstraints: defaultOfferConstraints)
		connection.addObserver(self)
		connections[sessionDetails.sessionID] = [connection]
		
		connection.startCall()
	}
	
	func acceptCallFromOpponent(opponent: SVUser) {
		let sessionDetails = SessionDetails(initiator: opponent, membersIDs: [currentUser!.ID!.unsignedIntegerValue, opponent.ID!.unsignedIntegerValue])
		sessions[sessionDetails.sessionID] = sessionDetails
		
		let connection = PeerConnection(opponent: opponent, sessionID: sessionDetails.sessionID, ICEServers: ICEServers, factory: factory, mediaStreamConstraints: defaultMediaStreamConstraints, peerConnectionConstraints: defaultPeerConnectionConstraints, offerAnswerConstraints: defaultOfferConstraints)
		connection.addObserver(self)
		connections[sessionDetails.sessionID] = [connection]
		
		connection.acceptCall()
		guard let pendingRequest = pendingRequests[opponent] else {
			NSLog("Error: no pending offer for opponent")
			return
		}
		guard let sdp = pendingRequest.offerSignalingMessage.sdp else {
			NSLog("Error: pending offer for opponent has no SDP")
			return
		}
		connection.applyRemoteSDP(sdp)
	}
}

extension CallService: SignalingProcessorObserver {
	func didReceiveICECandidates(signalingProcessor: SignalingProcessor, fromOpponent opponent: SVUser, sessionDetails: SessionDetails, signalingMessage: SVSignalingMessageICE) {
		connectionWithSessionID(sessionDetails.sessionID, opponent: opponent)?.applyICECandidates([signalingMessage.iceCandidate])
	}
	
	func didReceiveOffer(signalingProcessor: SignalingProcessor, fromOpponent opponent: SVUser, sessionDetails: SessionDetails, signalingMessage: SVSignalingMessageSDP) {
		NSLog("didReceiveOffer")
		if let session = sessions[sessionDetails.sessionID] {
			guard session.sessionState != SessionDetailsState.Rejected else {
				// Skip
				NSLog("declined rejected session")
				return
			}
		} else {
			pendingRequests[opponent] = CallServicePendingRequest(offerSignalingMessage: signalingMessage)
			observers => { $0.callService(self, didReceiveCallRequestFromOpponent: opponent) }
		}
	}
	
	func didReceiveAnswer(signalingProcessor: SignalingProcessor, fromOpponent opponent: SVUser, sessionDetails: SessionDetails, signalingMessage: SVSignalingMessageSDP) {
		NSLog("didReceiveAnswer")
		guard let sdp = signalingMessage.sdp else {
			NSLog("Error: answer offer for opponent has no SDP")
			return
		}
		connectionWithSessionID(sessionDetails.sessionID, opponent: opponent)?.applyRemoteSDP(sdp)
	}
	
	func didReceiveHangup(signalingProcessor: SignalingProcessor, fromOpponent opponent: SVUser, sessionDetails: SessionDetails, signalingMessage: SVSignalingMessage) {
		NSLog("didReceiveHangup")
		pendingRequests[opponent] = nil
	}
	
	func didReceiveReject(signalingProcessor: SignalingProcessor, fromOpponent opponent: SVUser, sessionDetails: SessionDetails, signalingMessage: SVSignalingMessage) {
		NSLog("didReceiveReject")
		pendingRequests[opponent] = nil
	}
}

extension CallService: PeerConnectionObserver {
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
