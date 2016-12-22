//
//  CallServiceProtocol.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 09.12.16.
//  Copyright © 2016 anton. All rights reserved.
//

import Foundation

protocol CallServiceProtocol: class {
	var isConnected: Bool { get }
	var isConnecting: Bool { get }
	var currentUser: SVUser? { get }
	var hasActiveCall: Bool { get }
	
	var observers: MulticastDelegate<CallServiceObserver>? { get }
	
	func addObserver(observer: CallServiceObserver)
	func connectWithUser(user: SVUser, completion: ((error: NSError?) -> Void)?)
	func disconnectWithCompletion(completion: ((error: NSError?) -> Void)?)
	func startCallWithOpponent(user: SVUser) throws
	func acceptCallFromOpponent(opponent: SVUser) throws
	func hangup()
	func sendRejectCallToOpponent(user: SVUser) throws
}
