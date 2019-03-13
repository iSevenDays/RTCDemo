//
//  SignalingProcessorChatRoomObserver.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 3/13/19.
//  Copyright © 2019 Anton Sokolchenko. All rights reserved.
//

import Foundation

protocol SignalingProcessorChatRoomObserver: class {
	func didReceiveUser(_ signalingProcessor: SignalingProcessor, user: SVUser, forChatRoomName chatRoomName: String)
}
