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
	func didReceiveICECandidates(signalingProcessor: SignalingProcessor, fromOpponent opponent: SVUser, sessionDetails: SessionDetails, signalingMessage: SVSignalingMessageICE)
	func didReceiveOffer(signalingProcessor: SignalingProcessor, fromOpponent opponent: SVUser, sessionDetails: SessionDetails, signalingMessage: SVSignalingMessageSDP)
	func didReceiveAnswer(signalingProcessor: SignalingProcessor, fromOpponent opponent: SVUser, sessionDetails: SessionDetails, signalingMessage: SVSignalingMessageSDP)
	func didReceiveHangup(signalingProcessor: SignalingProcessor, fromOpponent opponent: SVUser, sessionDetails: SessionDetails, signalingMessage: SVSignalingMessage)
	func didReceiveReject(signalingProcessor: SignalingProcessor, fromOpponent opponent: SVUser, sessionDetails: SessionDetails, signalingMessage: SVSignalingMessage)
}

/// Class to process SVSignaling messages
/// and forward them to CallService with SessionDetails
class SignalingProcessor: NSObject {
	
	weak var observer: SignalingProcessorObserver?
	
	func processSignalingMessage(message: SVSignalingMessage) {
		
		let sessionDetails = SessionDetails(signalingMessage: message)
		let opponent = message.sender
		
		if message.type == SVSignalingMessageType.candidates.takeUnretainedValue() {
			observer?.didReceiveICECandidates(self, fromOpponent: opponent, sessionDetails: sessionDetails, signalingMessage: message as! SVSignalingMessageICE)
			
		} else if message.type == SVSignalingMessageType.offer.takeUnretainedValue() {
			observer?.didReceiveOffer(self, fromOpponent: opponent, sessionDetails: sessionDetails, signalingMessage: message as! SVSignalingMessageSDP)
			
		} else if message.type == SVSignalingMessageType.answer.takeUnretainedValue() {
			observer?.didReceiveAnswer(self, fromOpponent: opponent, sessionDetails: sessionDetails, signalingMessage: message as! SVSignalingMessageSDP)
			
		} else if message.type == SVSignalingMessageType.hangup.takeUnretainedValue() {
			observer?.didReceiveHangup(self, fromOpponent: opponent, sessionDetails: sessionDetails, signalingMessage: message)
			
		} else if message.type == SVSignalingMessageType.reject.takeUnretainedValue() {
			observer?.didReceiveReject(self, fromOpponent: opponent, sessionDetails: sessionDetails, signalingMessage: message)
			
		}
	}
}

extension SignalingProcessor: SVSignalingChannelDelegate {
	func channel(channel: SVSignalingChannelProtocol, didReceiveMessage message: SVSignalingMessage) {
		processSignalingMessage(message)
	}
}
