//
//  SignalingMessagesFactory+SendBird.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 3/13/19.
//  Copyright © 2019 Anton Sokolchenko. All rights reserved.
//

import Foundation
import SendBirdSDK

struct SignalingBirdMessageContent: Codable {
	var message: SignalingMessage
	var sender: SVUser
	var sessionDetails: SessionDetails?

	init(message: SignalingMessage, sender: SVUser, sessionDetails: SessionDetails?) {
		self.message = message
		self.sender = sender
		self.sessionDetails = sessionDetails
	}
}

extension SignalingMessagesFactory {
	func sendBirdMessageFromSignalingMessage(_ message: SignalingMessage, sender: SVUser, sessionDetails: SessionDetails?) throws -> String {

		let signalingObject = SignalingBirdMessageContent(message: message, sender: sender, sessionDetails: sessionDetails)
		let encodedString = try JSONEncoder().encode(signalingObject).base64EncodedString()
		return encodedString
	}

	/**
	Parses SignalingMessage from SBDUserMessage

	- parameter message: SBDUserMessage instance

	- throws: SignalingMessagesFactoryError type

	- returns: return message, sender, sessionDetails(nil for chat room SignalingMessage)
	*/
	func signalingMessageFromSendBirdUserMessage(_ message: String) throws -> (message: SignalingMessage, sender: SVUser, sessionDetails: SessionDetails?) {
		let base64Representation = message
		guard let decodedBase64Data = Data(base64Encoded: base64Representation) else {
			throw SignalingMessagesFactoryError.incorrectSignalingMessage(message: .sendBird(message))
		}

		let signalingObject = try JSONDecoder().decode(SignalingBirdMessageContent.self, from: decodedBase64Data)
		return (signalingObject.message, signalingObject.sender, signalingObject.sessionDetails)
	}
}


