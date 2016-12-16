//
//  PeerConnectionTests.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 15.12.16.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import Foundation

import XCTest

#if QBRTCDemo_s
	@testable
	import QBRTCDemo_s
#elseif QBRTCDemo
	@testable
	import QBRTCDemo
#endif

class PeerConnectionTests: BaseTestCase {
	
	let user1 = TestsStorage.svuserRealUser1
	
	// Always PeerConnection opponent
	let user2 = TestsStorage.svuserRealUser2
	
	let user3 = SVUser(ID: 1, login: "login", fullName: "full_name", password: "", tags: ["tag1"])
	
	var peerConnection: PeerConnection!
	let sessionID = "session_unique_ID"
	var emptyCallService: CallService!
	var mockOutput: MockOutput!
	
	override func setUp() {
		emptyCallService = CallService()
		ServicesConfigurator().configureCallService(emptyCallService)
		mockOutput = MockOutput()
		peerConnection = PeerConnection(opponent: user2, sessionID: sessionID, ICEServers: emptyCallService.ICEServers, factory: emptyCallService.factory, mediaStreamConstraints: emptyCallService.defaultMediaStreamConstraints, peerConnectionConstraints: emptyCallService.defaultPeerConnectionConstraints, offerAnswerConstraints: emptyCallService.defaultOfferConstraints)
		peerConnection.addObserver(mockOutput)
	}
	
	func testDoesntCreateAnswerSDPWhenPeerConnectionIsClosed() {
		// given
		let rtcOfferSDP = RTCSessionDescription(type: "offer", sdp: CallServiceHelpers.offerSDP)
		
		// when
		peerConnection.acceptCall()
		peerConnection.applyRemoteSDP(rtcOfferSDP)
		peerConnection.close()
		
		// then
		XCTAssertFalse(mockOutput.didSetLocalSessionAnswerDescriptionGotCalled)
	}
	
	class MockOutput: PeerConnectionObserver {
		var didReceiveLocalVideoTrackGotCalled = false
		var didReceiveRemoteVideoTrackGotCalled = false
		var didCreateSessionWithErrorGotCalled = false
		var didSetLocalICECandidatesGotCalled = false
		var didSetLocalSessionOfferDescriptionGotCalled = false
		var didSetLocalSessionAnswerDescriptionGotCalled = false
		
		func peerConnection(peerConnection: PeerConnection, didReceiveLocalVideoTrack localVideoTrack: RTCVideoTrack) {
			didReceiveLocalVideoTrackGotCalled = true
		}
		func peerConnection(peerConnection: PeerConnection, didReceiveRemoteVideoTrack remoteVideoTrack: RTCVideoTrack) {
			didReceiveRemoteVideoTrackGotCalled = true
		}
		func peerConnection(peerConnection: PeerConnection, didCreateSessionWithError error: NSError) {
			didCreateSessionWithErrorGotCalled = true
		}
		func peerConnection(peerConnection: PeerConnection, didSetLocalICECandidates localICECandidates: RTCICECandidate) {
			didSetLocalICECandidatesGotCalled = true
		}
		
		// User has an offer to send
		func peerConnection(peerConnection: PeerConnection, didSetLocalSessionOfferDescription localSessionDescription: RTCSessionDescription) {
			didSetLocalSessionOfferDescriptionGotCalled = true
		}
		
		// User has an answer to send
		func peerConnection(peerConnection: PeerConnection, didSetLocalSessionAnswerDescription localSessionDescription: RTCSessionDescription) {
			didSetLocalSessionAnswerDescriptionGotCalled = true
		}
	}
	
}
