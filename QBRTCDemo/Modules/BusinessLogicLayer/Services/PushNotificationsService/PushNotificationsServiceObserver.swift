//
//  PushNotificationsServiceObserver.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 15.12.16.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import Foundation

protocol PushNotificationsServiceObserver: class {
	func pushNotificationsService(_ service: PushNotificationsServiceProtocol, didSendMessage message: String, toOpponent: SVUser)
	func pushNotificationsService(_ service: PushNotificationsServiceProtocol, didFailToSendMessage message: String, toOpponent: SVUser, error: Error)
}
