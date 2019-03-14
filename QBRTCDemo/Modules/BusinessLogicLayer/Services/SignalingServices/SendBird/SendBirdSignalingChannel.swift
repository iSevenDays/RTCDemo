//
//  SendBirdSignalingChannel.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 3/13/19.
//  Copyright © 2019 Anton Sokolchenko. All rights reserved.
//

import Foundation
import SendBirdSDK

class SendBirdSignalingChannel: NSObject {
	var observers = MulticastDelegate<SignalingChannelObserver>()
	var state: SignalingChannelState = .open {
		didSet {
			observers |> { $0.signalingChannel(self, didChangeState: self.state) }
		}
	}

	var user: SVUser?
	var isConnecting: Bool = false

	private let channelURL = "sendbird_open_channel_48838_5d740a234fc82da3c77ad2194c31062a2887d95f"
	private var connectedChannel: SBDOpenChannel?
	fileprivate let signalingMessagesFactory = SignalingMessagesFactory()
}

extension SendBirdSignalingChannel: SignalingChannelProtocol {
	var isConnected: Bool {
		return connectedChannel != nil
	}

	func addObserver(_ observer: SignalingChannelObserver) {
		observers += observer
	}

	func connectWithUser(_ user: SVUser, completion: ((Error?) -> Void)?) throws {
		guard let userLogin = user.login else {
			throw SignalingChannelError.missingUserLogin
		}
		isConnecting = true
		self.user = user
		SBDMain.add(self, identifier: channelURL)

		SBDMain.connect(withUserId: userLogin) { [weak self] (sbuser, error) in
			guard let `self` = self else { return }
			guard error == nil else {
				self.isConnecting = false
				NSLog("Error connecting: \(error.debugDescription)")
				self.user = nil
				completion?(error)
				return
			}
			SBDOpenChannel.getWithUrl(self.channelURL) { (channel, error) in
				guard error == nil else {
					self.isConnecting = false
					NSLog("Error getting channel URL: \(error.debugDescription)")
					self.user = nil
					completion?(error)
					return
				}
				self.connectedChannel = channel
				channel?.enter(completionHandler: { (error) in
					guard error == nil else {
						self.isConnecting = false
						self.user = nil
						NSLog("Error entering channel: \(error.debugDescription)")
						self.observers |> { $0.signalingChannel(self, didChangeState: SignalingChannelState.error)}
						completion?(error)
						return
					}
					self.isConnecting = false
					NSLog("Entered signaling chat with login: \(userLogin)")
					self.observers |> { $0.signalingChannel(self, didChangeState: SignalingChannelState.established)}
					completion?(nil)
				})
			}
		}
	}

	func sendMessage(_ message: SignalingMessage, withSessionDetails: SessionDetails?, toUser user: SVUser, completion: ((Error?) -> Void)?) {
		guard let sender = self.user else {
			completion?(nil)
			return
		}
		do {
			let signalingMessage = try signalingMessagesFactory.sendBirdMessageFromSignalingMessage(message, sender: sender, sessionDetails: withSessionDetails)
			connectedChannel?.sendUserMessage(signalingMessage, completionHandler: { (userMessage, error) in
				if error == nil {
					NSLog("Sent message \(message)")
				}
				completion?(error)
			})
		} catch let error {
			completion?(error)
		}
	}

	func disconnectWithCompletion(_ completion: ((Error?) -> Void)?) {
		connectedChannel?.exitChannel(completionHandler: { [weak self] (error) in
			guard error == nil else {
				completion?(error)
				return
			}
			guard let `self` = self else { return }
			NSLog("Disconnected signaling channel SendBird")
			self.connectedChannel = nil
			self.user = nil
			self.observers |> { $0.signalingChannel(self, didChangeState: SignalingChannelState.closed) }
			completion?(nil)
		})
	}


}

extension SendBirdSignalingChannel: SBDChannelDelegate {

	/// Propagates received message text down to observers
	///
	/// - Parameters:
	///   - sender: sender
	///   - message: base message
	func channel(_ sender: SBDBaseChannel, didReceive message: SBDBaseMessage) {
		if let message = message as? SBDUserMessage {
			guard let text = message.message else {
				NSLog("Got empty message")
				return
			}
			do {
				let messageComponents = try signalingMessagesFactory.signalingMessageFromSendBirdUserMessage(text)

				observers |> { $0.signalingChannel(self, didReceiveMessage: messageComponents.message, fromOpponent: messageComponents.sender, withSessionDetails: messageComponents.sessionDetails)}
			} catch let error {
				NSLog("Error parsing sendbird message: \(error)")
			}
		}
	}
}
