//
//  SignalingMessage.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 11.12.16.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import Foundation

enum SignalingMessage {
	case offer(sdp: SessionDescription)
	case answer(sdp: SessionDescription)
	case system(SystemMessage)
	case candidates(candidates: [IceCandidate])
	case user(enteredChatRoomName: String)
}


extension SignalingMessage: Codable {
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let type = try container.decode(String.self, forKey: .type)
		switch type {
		case "offer":
			self = .offer(sdp: try container.decode(SessionDescription.self, forKey: .payload))
		case "answer":
			self = .answer(sdp: try container.decode(SessionDescription.self, forKey: .payload))
		case String(describing: IceCandidate.self):
			self = .candidates(candidates: try container.decode([IceCandidate].self, forKey: .payload))
		case String(describing: SystemMessage.self):
			self = .system(try container.decode(SystemMessage.self, forKey: .payload))
		case "enteredChatRoomName":
			self = .user(enteredChatRoomName: try container.decode(String.self, forKey: .payload))
		default:
			throw DecodeError.unknownType
		}
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		switch self {
		case .offer(let sessionDescription):
			try container.encode(sessionDescription, forKey: .payload)
			try container.encode("offer", forKey: .type)
		case .answer(let sessionDescription):
			try container.encode(sessionDescription, forKey: .payload)
			try container.encode("answer", forKey: .type)
		case .candidates(let iceCandidate):
			try container.encode(iceCandidate, forKey: .payload)
			try container.encode(String(describing: IceCandidate.self), forKey: .type)
		case .system(let systemMessage):
			try container.encode(systemMessage, forKey: .payload)
			try container.encode(String(describing: SystemMessage.self), forKey: .type)
		case .user(let enteredChatRoomName):
			try container.encode(enteredChatRoomName, forKey: .payload)
			try container.encode("enteredChatRoomName", forKey: .type)
		}
	}

	enum DecodeError: Error {
		case unknownType
	}

	enum CodingKeys: String, CodingKey {
		case type, payload
	}
}
