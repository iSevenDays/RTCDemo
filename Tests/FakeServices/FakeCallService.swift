//
//  FakeCallService.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 09.12.16.
//  Copyright © 2016 anton. All rights reserved.
//

import Foundation


#if QBRTCDemo_s
	@testable
	import QBRTCDemo_s
#elseif QBRTCDemo
	@testable
	import QBRTCDemo
#endif


class FakeCallService: CallService {
	
	var shouldBeConnected = false
	var shouldBeConnecting = false

	override var isConnected: Bool {
		return shouldBeConnected
	}
	
	override var isConnecting: Bool {
		return shouldBeConnecting
	}
	
	override func startCallWithOpponent(_ user: SVUser) throws {
		let factory = RTCPeerConnectionFactory()

		let videoSource = factory.videoSource()
		let emptyVideoTrack = factory.videoTrack(with: videoSource, trackId: "trackID")
		
		observers |> { $0.callService(self, didReceiveLocalVideoTrack: emptyVideoTrack) }
		
		observers |> { $0.callService(self, didReceiveRemoteVideoTrack: emptyVideoTrack) }
	}
	
}
