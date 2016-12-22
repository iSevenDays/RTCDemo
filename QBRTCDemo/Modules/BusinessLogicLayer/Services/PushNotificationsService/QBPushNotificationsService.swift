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
	internal weak var cacheService: CacheServiceProtocol!
	
	internal let pushNotificationsKey = "pushNotificationsKey"
	
	func addObserver(observer: PushNotificationsServiceObserver) {
		observers += observer
	}
	
	// MARK: - PushNotificationsServiceProtocol
	
	func registerForPushNotificationsWithDeviceToken(deviceToken: NSData) {
		guard !cacheService.boolForKey(pushNotificationsKey) else {
			// already registered
			return
		}
		
		let deviceIdentifier = UIDevice.currentDevice().identifierForVendor?.UUIDString ?? NSUUID().UUIDString
		let subscription = QBMSubscription()
		
		subscription.notificationChannel = .APNS
		subscription.deviceUDID = deviceIdentifier
		subscription.deviceToken = deviceToken
		QBRequest.createSubscription(subscription, successBlock: { [cacheService, pushNotificationsKey] (response: QBResponse!, objects: [QBMSubscription]?) in
			cacheService.setBool(true, forKey: pushNotificationsKey)
		}) { (response: QBResponse!) in
		}
	}
	
	// located here because we should be able to override the class
	func sendPushNotificationMessage(message: String, toOpponent opponent: SVUser) {
		guard let opponentID = opponent.ID else {
			NSLog("Error sending push notification: opponentID is nil")
			return
		}
		
		let event = QBMEvent()
		event.notificationType = .Push
		event.usersIDs = String(opponentID)
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
