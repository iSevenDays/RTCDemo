//
//  CallServicePendingRequest.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 15/05/16.
//  Copyright © 2016 anton. All rights reserved.
//

import UIKit

class CallServicePendingRequest: NSObject {
	
	var offerSignalingMessage: SVSignalingMessageSDP
	var initiator: SVUser
	
	init(offerSignalingMessage: SVSignalingMessageSDP) {
		assert(offerSignalingMessage.type == SVSignalingMessageType.offer.takeUnretainedValue())
		
		initiator = offerSignalingMessage.sender
		self.offerSignalingMessage = offerSignalingMessage
		
		super.init()
	}
	
}
