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
	
	var observers = MulticastDelegate<SignalingChannelObserver>()
}

extension FakeSignalingChannel: SignalingChannelProtocol {
	
	func addObserver(_ observer: SignalingChannelObserver) {
		observers += observer
	}
	
	func connectWithUser(_ user: SVUser, completion: ((_ error: Error?) -> Void)?) {
		self.state = .open
		
		self.user = user
		
		self.state = .established
		
		completion?(nil)
	}
	
	func sendMessage(_ message: SignalingMessage, withSessionDetails: SessionDetails?, toUser user: SVUser, completion: ((_ error: Error?) -> Void)?) {
		let error: NSError? = shouldSensMessagesSuccessfully ? nil : NSError(domain: "", code: -1, userInfo: nil)
		completion?(error)
	}
	
	func disconnectWithCompletion(_ completion: ((_ error: Error?) -> Void)?) {
		self.state = .closed
		completion?(nil)
	}
	
	var isConnected: Bool {
		return true
	}
	
	var isConnecting: Bool {
		return false
	}
}
