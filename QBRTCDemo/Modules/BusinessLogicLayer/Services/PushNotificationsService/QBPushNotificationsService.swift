//
//  QBPushNotificationsService.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 15.12.16.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import Foundation
import Quickblox

class QBPushNotificationsService: PushNotificationsServiceProtocol {
	internal var observers: MulticastDelegate<PushNotificationsServiceObserver>?
	
	func addObserver(observer: PushNotificationsServiceObserver) {
		observers += observer
	}
	
	// MARK: - PushNotificationsServiceProtocol
	
	// located here because we should be able to override the class
	func sendPushNotificationMessage(message: String, toOpponent opponent: SVUser) {
		let event = QBMEvent()
		event.notificationType = .Push
		event.usersIDs = String(opponent.ID)
		event.type = .OneShot
		
		// custom params
		let pushCustomParams = ["message" : message,
		                        //"ios_badge": "1",
			"ios_sound": "default"]
		do {
			let data = try NSJSONSerialization.dataWithJSONObject(pushCustomParams, options: .PrettyPrinted)
			let json = String(data: data, encoding: NSUTF8StringEncoding)
			event.message = json
		} catch let error {
			observers => { $0.pushNotificationsService(self, didFailToSendMessage: message, toOpponent: opponent, error: error as NSError) }
		}
		
		guard event.message != nil else {
			return
		}
		
		QBRequest.createEvent(event, successBlock: { [unowned self] (response, events) in
			
			self.observers => { $0.pushNotificationsService(self, didSendMessage: message, toOpponent: opponent) }
			
			})
		{ [unowned self] (response) in
			if let error = response.error?.error {
				self.observers => { $0.pushNotificationsService(self, didFailToSendMessage: message, toOpponent: opponent, error: error) }
			}
		}
	}
}
