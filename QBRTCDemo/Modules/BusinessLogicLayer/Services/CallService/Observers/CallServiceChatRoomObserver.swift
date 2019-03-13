//
//  CallServiceChatRoomObserver.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 3/13/19.
//  Copyright © 2019 Anton Sokolchenko. All rights reserved.
//

import Foundation

protocol CallServiceChatRoomObserver: class {
	func callService(_ callService: CallServiceProtocol, didReceiveUser user: SVUser, forChatRoomName chatRoomName: String)
	func callService(_ callService: CallServiceProtocol, didSendUserEnteredChatRoomName chatRoomName: String, toUser: SVUser)
}
extension CallServiceChatRoomObserver {
	func callService(_ callService: CallServiceProtocol, didReceiveUser user: SVUser, forChatRoomName chatRoomName: String) {}
	func callService(_ callService: CallServiceProtocol, didSendUserEnteredChatRoomName chatRoomName: String, toUser: SVUser) {}
}
