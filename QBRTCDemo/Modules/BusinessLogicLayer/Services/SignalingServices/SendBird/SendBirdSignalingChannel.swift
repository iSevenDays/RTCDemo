//
//  SendBirdSignalingChannel.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 3/13/19.
//  Copyright © 2019 Anton Sokolchenko. All rights reserved.
//

import Foundation
import SendBirdSDK

class SendBirdSignalingChannel {
	var observers = MulticastDelegate<SignalingChannelObserver>()
	var state: SignalingChannelState = .open {
		didSet {
			observers |> { $0.signalingChannel(self, didChangeState: self.state) }
		}
	}

	var user: SVUser?

	private let channelURL = "sendbird_open_channel_48838_5d740a234fc82da3c77ad2194c31062a2887d95f"
	private var connectedChannel: SBDOpenChannel?
}

extension SendBirdSignalingChannel: SignalingChannelProtocol {
	var isConnected: Bool {
		return false
	}

	var isConnecting: Bool {
		return false
	}

	func addObserver(_ observer: SignalingChannelObserver) {
		observers += observer
	}

	func connectWithUser(_ user: SVUser, completion: ((Error?) -> Void)?) throws {
		guard let userLogin = user.login else {
			throw SignalingChannelError.missingUserLogin
		}
		SBDMain.connect(withUserId: userLogin) { [weak self] (sbuser, error) in
			guard error == nil else {
				NSLog("Error connecting: \(error.debugDescription)")
				return
			}

			guard let `self` = self else { return }
			SBDOpenChannel.getWithUrl(self.channelURL) { (channel, error) in
				guard error == nil else {
					NSLog("Error getting channel URL: \(error.debugDescription)")
					return
				}
				self.connectedChannel = channel
				channel?.enter(completionHandler: { (error) in
					guard error == nil else {
						NSLog("Error entering channel: \(error.debugDescription)")
						return
					}

					NSLog("Entered signaling chat with login: \(userLogin)")
				})
			}
		}
	}

	func sendMessage(_ message: SignalingMessage, withSessionDetails: SessionDetails?, toUser user: SVUser, completion: ((Error?) -> Void)?) {

	}

	func disconnectWithCompletion(_ completion: ((Error?) -> Void)?) {
		
	}


}
