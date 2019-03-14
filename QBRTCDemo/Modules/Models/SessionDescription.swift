//
//  SessionDescription.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 3/13/19.
//  Copyright © 2019 Anton Sokolchenko. All rights reserved.
//

import Foundation

/// This enum is a swift wrapper over `RTCSdpType` for easy encode and decode
enum SdpType: String, Codable {
	case offer, prAnswer, answer

	var rtcSdpType: RTCSdpType {
		switch self {
		case .offer:    return .offer
		case .answer:   return .answer
		case .prAnswer: return .prAnswer
		}
	}
}

/// This struct is a swift wrapper over `RTCSessionDescription` for easy encode and decode
struct SessionDescription: Codable {
	let sdp: String
	let type: SdpType

	init(from rtcSessionDescription: RTCSessionDescription) {
		self.sdp = rtcSessionDescription.sdp

		switch rtcSessionDescription.type {
		case .offer:    self.type = .offer
		case .prAnswer: self.type = .prAnswer
		case .answer:   self.type = .answer
		}
	}

	var rtcSessionDescription: RTCSessionDescription {
		return RTCSessionDescription(type: self.type.rtcSdpType, sdp: self.sdp)
	}
}
