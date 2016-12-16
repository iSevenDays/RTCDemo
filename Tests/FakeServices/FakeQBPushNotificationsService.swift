//
//  FakeQBPushNotificationsService.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 15.12.16.
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

class FakePushNotificationsService: QBPushNotificationsService {
	
	var shouldSendPushes = true
	
	override func sendPushNotificationMessage(message: String, toOpponent opponent: SVUser) {
		if shouldSendPushes {
			observers => { $0.pushNotificationsService(self, didSendMessage: message, toOpponent: opponent) }
		}
	}
	
}
