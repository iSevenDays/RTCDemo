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
	
	func addObserver(_ observer: SignalingChannelObserver)
	
	func connectWithUser(_ user: SVUser, completion: ((_ error: Error?) -> Void)?) throws
	
	func sendMessage(_ message: SignalingMessage, withSessionDetails: SessionDetails?, toUser user: SVUser, completion: ((_ error: Error?) -> Void)?)
	
	func disconnectWithCompletion(_ completion: ((_ error: Error?) -> Void)?)
}

enum SignalingChannelError: Error {
	case missingUserID
	case chatError(error: Error)
}
