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


public class FakeCallSevice: CallService {
	
	var shouldBeConnected = false
	
	override var isConnected: Bool {
		return shouldBeConnected
	}
	
	override func startCallWithOpponent(user: SVUser) throws {
		let factory = RTCPeerConnectionFactory()
		
		let videoSourceClass: AnyClass = RTCVideoSource.self
		let videoSourceInitializable = videoSourceClass as! NSObject.Type
		let videoSource = videoSourceInitializable.init() as! RTCVideoSource
		
		let emptyVideoTrack = RTCVideoTrack(factory: factory, source: videoSource, trackId: "trackID")
		
		
		observers => { $0.callService(self, didReceiveLocalVideoTrack: emptyVideoTrack) }
		
		observers => { $0.callService(self, didReceiveRemoteVideoTrack: emptyVideoTrack) }
	}
	
}
