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
	
	var state: String = SVSignalingChannelState.open.takeRetainedValue() as String
	var user: SVUser?
	
	var observer: MulticastDelegate<SVSignalingChannelDelegate>?
	
	override init() {
		super.init()
	}
	
}

extension FakeSignalingChannel: SVSignalingChannelProtocol {
	func addDelegate(delegate: SVSignalingChannelDelegate) {
		observer += delegate
	}
	
	func delegates() -> [SVSignalingChannelDelegate]? {
		return self.delegates()
	}
	
	func connectWithUser(user: SVUser, completion: ((NSError?) -> Void)?) {
		self.state = SVSignalingChannelState.open.takeRetainedValue() as String
		
		self.user = user
		
		self.state = SVSignalingChannelState.established.takeRetainedValue() as String
		
		completion?(nil)
	}
	
	func disconnectWithCompletion(user: SVUser, completion: ((NSError?) -> Void)?) {
		completion?(nil)
	}
	
	func sendMessage(message: SVSignalingMessage, toUser user: SVUser, completion: ((NSError?) -> Void)?) {
		completion?(shouldSensMessagesSuccessfully ? nil : NSError(domain: "", code: -1, userInfo: nil))
	}
	
	func isConnected() -> Bool {
		return true
	}
}
