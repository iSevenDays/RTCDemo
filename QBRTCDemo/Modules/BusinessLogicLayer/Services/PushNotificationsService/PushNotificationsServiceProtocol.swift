//
//  PushNotificationsServiceProtocol.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 15.12.16.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import Foundation

protocol PushNotificationsServiceProtocol: class {
	func addObserver(observer: PushNotificationsServiceObserver)
	
	func registerForPushNotificationsWithDeviceToken(deviceToken: NSData)
	func sendPushNotificationMessage(message: String, toOpponent opponent: SVUser)
}
