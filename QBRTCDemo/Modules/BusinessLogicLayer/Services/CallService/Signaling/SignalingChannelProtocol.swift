//
//  SignalingChannelProtocol.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 11.12.16.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import Foundation

enum SignalingChannelState {
	case open
	case closed
	case established
	case error
}

protocol SignalingChannelProtocol {
	
	var isConnected: Bool { get }
	var isConnecting: Bool { get }
	var state: SignalingChannelState { get }
	var user: SVUser? { get }
	
	func addObserver(observer: SignalingChannelObserver)
	
	func connectWithUser(user: SVUser, completion: ((error: NSError?) -> Void)?) throws
	
	func sendMessage(message: SignalingMessage, withSessionDetails: SessionDetails?, toUser user: SVUser, completion: ((error: NSError?) -> Void)?)
	
	func disconnectWithCompletion(completion: ((error: NSError?) -> Void)?)
}

enum SignalingChannelError: ErrorType {
	case missingUserID
	case chatError(error: NSError)
}
