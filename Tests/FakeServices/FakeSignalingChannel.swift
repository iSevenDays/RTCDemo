//
//  FakeSignalingChannel.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 09.12.16.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import Foundation

#if QBRTCDemo_s
	@testable
	import QBRTCDemo_s
#elseif QBRTCDemo
	@testable
	import QBRTCDemo
#endif

class FakeSignalingChannel: NSObject {
	
	/// Should send messages successfully or with error
	var shouldSensMessagesSuccessfully = true
	
	var state = SignalingChannelState.open
	var user: SVUser?
	
	var observer: MulticastDelegate<SignalingChannelObserver>?
}

extension FakeSignalingChannel: SignalingChannelProtocol {
	
	func connectWithUser(user: SVUser, completion: ((error: NSError?) -> Void)?) {
		self.state = .open
		
		self.user = user
		
		self.state = .established
		
		completion?(error: nil)
	}
	
	func sendMessage(message: SignalingMessage, withSessionDetails: SessionDetails, toUser user: SVUser, completion: ((error: NSError?) -> Void)?) {
		let error: NSError? = shouldSensMessagesSuccessfully ? nil : NSError(domain: "", code: -1, userInfo: nil)
		completion?(error: error)
	}
	
	func disconnectWithCompletion(completion: ((error: NSError?) -> Void)?) {
		self.state = .closed
		completion?(error: nil)
	}
	
	var isConnected: Bool {
		return true
	}
	
	var isConnecting: Bool {
		return false
	}
}
