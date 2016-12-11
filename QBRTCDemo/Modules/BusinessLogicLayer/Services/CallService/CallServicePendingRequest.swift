//
//  CallServicePendingRequest.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 15/05/16.
//  Copyright © 2016 anton. All rights reserved.
//

import UIKit

class CallServicePendingRequest: NSObject {
	
	private(set) var pendingSessionDescription: RTCSessionDescription
	private(set) var initiator: SVUser
	private(set) var sessionDetails: SessionDetails
	
	init(initiator: SVUser, pendingSessionDescription: RTCSessionDescription, sessionDetails: SessionDetails) {
		assert(pendingSessionDescription.type == SignalingMessageType.offer.rawValue)
		
		self.initiator = initiator
		self.pendingSessionDescription = pendingSessionDescription
		self.sessionDetails = sessionDetails
		
		super.init()
	}
	
}
