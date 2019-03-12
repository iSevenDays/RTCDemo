//
//  CallServicePendingRequest.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 15/05/16.
//  Copyright © 2016 anton. All rights reserved.
//

import UIKit

class CallServicePendingRequest {
	
	fileprivate(set) var pendingSessionDescription: RTCSessionDescription
	fileprivate(set) var initiator: SVUser
	fileprivate(set) var sessionDetails: SessionDetails
	
	init(initiator: SVUser, pendingSessionDescription: RTCSessionDescription, sessionDetails: SessionDetails) {
		assert(pendingSessionDescription.type == .offer)
		
		self.initiator = initiator
		self.pendingSessionDescription = pendingSessionDescription
		self.sessionDetails = sessionDetails
	}
}
