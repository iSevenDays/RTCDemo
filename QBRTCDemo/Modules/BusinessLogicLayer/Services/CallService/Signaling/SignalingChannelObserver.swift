//
//  SignalingChannelObserver.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 3/13/19.
//  Copyright © 2019 Anton Sokolchenko. All rights reserved.
//

import Foundation

protocol SignalingChannelObserver: class {
	func signalingChannel(_ channel: SignalingChannelProtocol, didReceiveMessage message: SignalingMessage, fromOpponent: SVUser, withSessionDetails sessionDetails: SessionDetails?)
	func signalingChannel(_ channel: SignalingChannelProtocol, didChangeState state: SignalingChannelState)
}
