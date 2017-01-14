//
//  QBSignalingChannel.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 11.12.16.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import Foundation
import Quickblox

protocol SignalingChannelObserver: class {
	func signalingChannel(channel: SignalingChannelProtocol, didReceiveMessage message: SignalingMessage, fromOpponent: SVUser, withSessionDetails sessionDetails: SessionDetails?)
	func signalingChannel(channel: SignalingChannelProtocol, didChangeState state: SignalingChannelState)
}

class QBSignalingChannel: NSObject {
	var observers: MulticastDelegate<SignalingChannelObserver>?
	
	let signalingMessagesFactory = SignalingMessagesFactory()
	var state = SignalingChannelState.open {
		didSet {
			observers => { $0.signalingChannel(self, didChangeState: self.state) }
		}
	}
	
	var user: SVUser?
	override init() {
		super.init()
		QBChat.instance().addDelegate(self)
	}
	
	func addObserver(observer: SignalingChannelObserver) {
		observers += observer
	}
}

extension QBSignalingChannel: SignalingChannelProtocol {
	
	var isConnected: Bool {
		return QBChat.instance().isConnected
	}
	
	var isConnecting: Bool {
		return QBChat.instance().isConnecting
	}
	
	func connectWithUser(user: SVUser, completion: ((error: NSError?) -> Void)?) throws {
		guard let userID = user.ID else {
			throw SignalingChannelError.missingUserID
		}
		guard userID != 0 else {
			throw SignalingChannelError.missingUserID
		}
		state = .open
		
		QBChat.instance().connectWithUser(QBUUser(SVUser: user)) { [unowned self] (error) in
			if error != nil {
				self.state = .error
			} else {
				self.user = user
				QBChat.instance().currentUser()?.password = user.password
				QBChat.instance().currentUser()?.ID = userID.unsignedIntegerValue
				self.state = .established
			}
			completion?(error: error)
		}
	}   
	
	func sendMessage(message: SignalingMessage, withSessionDetails sessionDetails: SessionDetails?, toUser user: SVUser, completion: ((error: NSError?) -> Void)?) {
		guard let currentUser = self.user else {
			NSLog("%@", "Error failed to send message, current user is nil")
			return
		}
		let qbMessage = try? signalingMessagesFactory.qbMessageFromSignalingMessage(message, sender: currentUser, sessionDetails: sessionDetails)
		qbMessage!.recipientID = user.ID!.unsignedIntegerValue
		
		QBChat.instance().sendSystemMessage(qbMessage!, completion: completion)
	}
	
	func disconnectWithCompletion(completion: ((error: NSError?) -> Void)?) {
		QBChat.instance().disconnectWithCompletionBlock { [unowned self] (error) in
			if error == nil {
				self.state = .closed
			} else {
				self.state = .error
			}
			completion?(error: nil)
		}
	}
}

extension QBSignalingChannel: QBChatDelegate {
	func chatDidReconnect() {
		self.state = .established
	}
	func chatDidConnect() {
		self.state = .established
	}
	
	func chatDidAccidentallyDisconnect() {
		self.state = .error
	}
	
	func chatDidReceiveSystemMessage(message: QBChatMessage) {
		do {
			let (message, sender, sessionDetails) = try signalingMessagesFactory.signalingMessageFromQBMessage(message)
			
			self.observers => { $0.signalingChannel(self, didReceiveMessage: message, fromOpponent: sender, withSessionDetails: sessionDetails) }
			
		} catch SignalingMessagesFactoryError.failedToDecompressMessage(message: message) {
			NSLog("%@", "Error: failed to decompress message \(message)")
		} catch SignalingMessagesFactoryError.incorrectParamsType {
			NSLog("%@", "Error: incorrect params type")
		} catch SignalingMessagesFactoryError.incorrectSignalingMessage(message: message) {
			NSLog("%@", "Error: incorrect signaling message \(message)")
		} catch SignalingMessagesFactoryError.missingInitiatorID {
			NSLog("%@", "Error: missing initiator ID")
		} catch let error {
			NSLog("%@", "Error signaling message \(error)")
		}
	}
}
