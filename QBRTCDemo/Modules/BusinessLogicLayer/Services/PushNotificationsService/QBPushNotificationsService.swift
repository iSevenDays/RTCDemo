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
	internal var observers = MulticastDelegate<PushNotificationsServiceObserver>()
	internal weak var cacheService: CacheServiceProtocol!
	
	internal let pushNotificationsKey = "pushNotificationsKey"
	
	func addObserver(_ observer: PushNotificationsServiceObserver) {
		observers += observer
	}
	
	// MARK: - PushNotificationsServiceProtocol
	
	func registerForPushNotificationsWithDeviceToken(_ deviceToken: Data) {
		guard !cacheService.bool(forKey: pushNotificationsKey) else {
			// already registered
			return
		}
		
		let deviceIdentifier = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
		let subscription = QBMSubscription()
		
		subscription.notificationChannel = .APNS
		subscription.deviceUDID = deviceIdentifier
		subscription.deviceToken = deviceToken
		QBRequest.createSubscription(subscription, successBlock: { [cacheService, pushNotificationsKey] (response: QBResponse!, objects: [QBMSubscription]?) in

			cacheService?.set(true, forKey: pushNotificationsKey)
		}) { (response: QBResponse!) in
		}
	}
	
	// located here because we should be able to override the class
	func sendPushNotificationMessage(_ message: String, toOpponent opponent: SVUser) {
		guard let opponentID = opponent.id else {
			NSLog("Error sending push notification: opponentID is nil")
			return
		}
		
		let event = QBMEvent()
		event.notificationType = .push
		event.usersIDs = String(opponentID.intValue)
		event.type = .oneShot
		
		// custom params
		let pushCustomParams = ["message" : message,
		                        //"ios_badge": "1",
			"ios_sound": "default"]
		do {
			let data = try JSONSerialization.data(withJSONObject: pushCustomParams, options: .prettyPrinted)
			let json = String(data: data, encoding: String.Encoding.utf8)
			event.message = json
		} catch let error {
			observers |> { $0.pushNotificationsService(self, didFailToSendMessage: message, toOpponent: opponent, error: error) }
		}
		
		guard event.message != nil else {
			return
		}
		
		QBRequest.createEvent(event, successBlock: { [unowned self] (response, events) in
			
			self.observers |> { $0.pushNotificationsService(self, didSendMessage: message, toOpponent: opponent) }
			
			})
		{ [unowned self] (response) in
			if let error = response.error?.error {
				self.observers |> { $0.pushNotificationsService(self, didFailToSendMessage: message, toOpponent: opponent, error: error) }
			}
		}
	}
}
