//
//  SignalingProcessor.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 08.12.16.
//  Copyright © 2016 anton. All rights reserved.
//

import Foundation

/// NOTE: Initiator User may not be equal to fromOpponent
@objc protocol SignalingProcessorObserver: class {
	func didReceiveICECandidates(signalingProcessor: SignalingProcessor, ICECandidates: [RTCICECandidate], fromOpponent opponent: SVUser, sessionDetails: SessionDetails)
	func didReceiveOffer(signalingProcessor: SignalingProcessor, offer: RTCSessionDescription, fromOpponent opponent: SVUser, sessionDetails: SessionDetails)
	func didReceiveAnswer(signalingProcessor: SignalingProcessor, answer: RTCSessionDescription, fromOpponent opponent: SVUser, sessionDetails: SessionDetails)
	func didReceiveHangup(signalingProcessor: SignalingProcessor, fromOpponent opponent: SVUser, sessionDetails: SessionDetails)
	func didReceiveReject(signalingProcessor: SignalingProcessor, fromOpponent opponent: SVUser, sessionDetails: SessionDetails)
}

/// Class to process SVSignaling messages
/// and forward them to CallService
class SignalingProcessor: NSObject {
	weak var observer: SignalingProcessorObserver?
}

extension SignalingProcessor: SignalingChannelObserver {
	func signalingChannel(channel: SignalingChannelProtocol, didReceiveMessage message: SignalingMessage, fromOpponent opponent: SVUser, withSessionDetails sessionDetails: SessionDetails) {
		
		switch message {
		case let .offer(sdp: sessionDescription) :
			observer?.didReceiveOffer(self, offer: sessionDescription, fromOpponent: opponent, sessionDetails: sessionDetails)
		case let .answer(sdp: sessionDescription):
			observer?.didReceiveAnswer(self, answer: sessionDescription, fromOpponent: opponent, sessionDetails: sessionDetails)
		case let .candidates(candidates: candidates):
			observer?.didReceiveICECandidates(self, ICECandidates: candidates, fromOpponent: opponent, sessionDetails: sessionDetails)
		case .hangup:
			observer?.didReceiveHangup(self, fromOpponent: opponent, sessionDetails: sessionDetails)
		case .reject:
			observer?.didReceiveReject(self, fromOpponent: opponent, sessionDetails: sessionDetails)
		}
	}
	func signalingChannel(channel: SignalingChannelProtocol, didChangeState state: SignalingChannelState) {
		
	}
}
