//
//  SignalingMessage.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 11.12.16.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import Foundation

enum SignalingMessage {
	case offer(sdp: RTCSessionDescription)
	case answer(sdp: RTCSessionDescription)
	case hangup
	case reject
	case candidates(candidates: [RTCICECandidate])
}
