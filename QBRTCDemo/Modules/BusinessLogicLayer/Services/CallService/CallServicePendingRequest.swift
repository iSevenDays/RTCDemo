//
//  CallServicePendingRequest.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 15/05/16.
//  Copyright © 2016 anton. All rights reserved.
//

import UIKit

class CallServicePendingRequest: NSObject {
	
	var pendingSessionDescription: RTCSessionDescription
	var initiator: SVUser
	
	init(initiator: SVUser, pendingSessionDescription: RTCSessionDescription) {
		assert(pendingSessionDescription.type == SignalingMessageType.offer.rawValue)
		
		self.initiator = initiator
		self.pendingSessionDescription = pendingSessionDescription
		
		super.init()
	}
	
}
