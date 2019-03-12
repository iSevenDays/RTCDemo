//
//  PushNotificationsServiceProtocol.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 15.12.16.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import Foundation

protocol PushNotificationsServiceProtocol: class {
	func addObserver(_ observer: PushNotificationsServiceObserver)
	
	func registerForPushNotificationsWithDeviceToken(_ deviceToken: Data)
	func sendPushNotificationMessage(_ message: String, toOpponent opponent: SVUser)
}
