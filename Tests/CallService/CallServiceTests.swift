//
//  CallServiceTests.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 10.12.16.
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

class CallServiceTests: XCTestCase {
	
	let user1 = CallServiceHelpers.user1()
	let user2 = CallServiceHelpers.user2()
	let user3 = SVUser(ID: 1, login: "login", fullName: "full_name", password: "", tags: ["tag1"])
	
	var fakeSignalingChannel: FakeSignalingChannel!
	var callService: CallService!
	var mockOutput: MockOutput!
	
	override func setUp() {
		fakeSignalingChannel = FakeSignalingChannel()
		callService = CallService()
		ServicesConfigurator().configureCallService(callService)
		callService.signalingChannel = fakeSignalingChannel
		
		mockOutput = MockOutput()
		callService.addObserver(mockOutput)
	}
	
	func currentSelectorTestExpectation() -> XCTestExpectation {
		var selectorName = "testExpectation"
		if let invocation = invocation{
			selectorName = NSStringFromSelector(invocation.selector)
		}
		return expectationWithDescription(selectorName)
	}
	
	func waitForTestExpectations() {
		waitForExpectationsWithTimeout(10.0) { (error) in
			XCTAssertNil(error)
		}
	}
	
	func testCanConnectWithUserAndHaveConnectedState() {
		// given
		let expectation = currentSelectorTestExpectation()
		
		// when
		callService.connectWithUser(user1) { (error) in
			XCTAssertNil(error)
			XCTAssertEqual(self.callService.state, CallServiceState.Connected)
			expectation.fulfill()
		}
		
		// then
		waitForTestExpectations()
	}
	
	//MARK: - CallClientObserver tests
	
	func testHasLocalVideoTrackAfterStartCall() {
		// when
		callService.connectWithUser(user1, completion: nil)
		
		_ = try? callService.startCallWithOpponent(user2)
		
		// then
		XCTAssertTrue(mockOutput.didReceiveLocalVideoTrackGotCalled)
		XCTAssertNotNil(mockOutput.videoTrack)
	}
	
	func testCorrectlyChangesClientStateToConnected() {
		// when
		callService.connectWithUser(user1, completion: nil)
		
		// then
		XCTAssertTrue(mockOutput.didChangeStateGotCalled)
		XCTAssertEqual(mockOutput.callServiceState, CallServiceState.Connected)
	}
	
	func testCorrectlyChangesClientStateToDisconnectedAfterDisconnectFromChat() {
		// when
		callService.connectWithUser(user1, completion: nil)
		callService.disconnectWithCompletion(nil)
		
		// then
		XCTAssertTrue(mockOutput.didChangeStateGotCalled)
		XCTAssertEqual(mockOutput.callServiceState, CallServiceState.Disconnected)
	}
	
//	func testSendsRejectIfAlreadyHasActiveCall() {
//		// given
//		let rtcOfferSDP = RTCSessionDescription(type: SVSignalingMessageType.offer.takeUnretainedValue() as String, sdp: CallServiceHelpers.offerSDP())
//		
//		let signalingOffer = SVSignalingMessageSDP(sessionDescription: rtcOfferSDP)
//		signalingOffer.sender = user3
//		signalingOffer.sessionID = NSUUID().UUIDString
//		
//		let sessionDetails = SessionDetails(signalingMessage: signalingOffer)
//		
//		// when
//		callService.connectWithUser(user1, completion: nil)
//		_ = try? callService.startCallWithOpponent(user2)
//		
//		callService.didReceiveOffer(callService.signalingProcessor, fromOpponent: user3, sessionDetails: sessionDetails, signalingMessage: signalingOffer)
//		
//		// then
//		XCTAssertFalse(mockOutput.didReceiveCallRequestFromOpponentGotCalled)
//	}
	
	func testCorrectlyProcessesSignalingMessageOfferFromOpponent_andSavesCallRequest() {
		// given
		let rtcOfferSDP = RTCSessionDescription(type: SignalingMessageType.offer.rawValue, sdp: CallServiceHelpers.offerSDP())
	
		let sessionDetails = SessionDetails(initiatorID: user1.ID!.unsignedIntegerValue, membersIDs: [1])
		
		// when
		callService.connectWithUser(user1, completion: nil)
		callService.didReceiveOffer(callService.signalingProcessor, offer: rtcOfferSDP, fromOpponent: user1, sessionDetails: sessionDetails)
		
		// then
		XCTAssertTrue(mockOutput.didReceiveCallRequestFromOpponentGotCalled)
	}
	
	// PeerConnection observer tests
	
	func testsSendsLocalSessionDescription() {
		// given
		let localSDP = RTCSessionDescription(type: SignalingMessageType.offer.rawValue, sdp: CallServiceHelpers.offerSDP())
		
		let sessionDetails = SessionDetails(initiatorID: 1, membersIDs: [1])
		callService.sessions[sessionDetails.sessionID] = sessionDetails
		
		let peerConnection = PeerConnection(opponent: user2, sessionID: sessionDetails.sessionID, ICEServers: callService.ICEServers, factory: callService.factory, mediaStreamConstraints: callService.defaultMediaStreamConstraints, peerConnectionConstraints: callService.defaultPeerConnectionConstraints, offerAnswerConstraints: callService.defaultOfferConstraints)
		
		// when
		callService.connectWithUser(user1, completion: nil)
		_ = try? callService.startCallWithOpponent(user2)
		callService.peerConnection(peerConnection, didSetLocalSessionOfferDescription: localSDP)
		
		// then
		XCTAssertTrue(mockOutput.didSendLocalSessionDescriptionMessageGotCalled)
		XCTAssertFalse(mockOutput.didErrorSendingLocalSessionDescriptionMessageGotCalled)
	}
	
	func testsSendsLocalICECandidates() {
		// given
		
		let localICECandidateAudio = RTCICECandidate(mid: "audio", index: 0, sdp: "candidate:1009584571 1 udp 2122260223 192.168.8.197 58130 typ host generation 0 ufrag 0+C/nsdLdjk3x5eG")
		
		let sessionDetails = SessionDetails(initiatorID: 1, membersIDs: [1])
		callService.sessions[sessionDetails.sessionID] = sessionDetails
		
		let peerConnection = PeerConnection(opponent: user2, sessionID: sessionDetails.sessionID, ICEServers: callService.ICEServers, factory: callService.factory, mediaStreamConstraints: callService.defaultMediaStreamConstraints, peerConnectionConstraints: callService.defaultPeerConnectionConstraints, offerAnswerConstraints: callService.defaultOfferConstraints)
		
		// when
		callService.connectWithUser(user1, completion: nil)
		_ = try? callService.startCallWithOpponent(user2)
		callService.peerConnection(peerConnection, didSetLocalICECandidates: localICECandidateAudio)
		
		// then
		XCTAssertTrue(mockOutput.didSendLocalICECandidatesGotCalled)
		XCTAssertFalse(mockOutput.didErrorSendingLocalICECandidatesGotCalled)
	}
	
	class MockOutput: CallServiceObserver {
		var didReceiveCallRequestFromOpponentGotCalled = false
		var didReceiveHangupFromOpponentGotCalled = false
		var didReceiveRejectFromOpponentGotCalled = false
		var didAnswerTimeoutForOpponentGotCalled = false
		var didChangeConnectionStateGotCalled = false
		var didChangeStateGotCalled = false
		var didReceiveLocalVideoTrackGotCalled = false
		var didReceiveRemoteVideoTrackGotCalled = false
		var didErrorGotCalled = false
		
		var didSendLocalSessionDescriptionMessageGotCalled = false
		var didErrorSendingLocalSessionDescriptionMessageGotCalled = false
		
		var didSendLocalICECandidatesGotCalled = false
		var didErrorSendingLocalICECandidatesGotCalled = false
		
		var callServiceState = CallServiceState.Undefined
		var videoTrack: RTCVideoTrack?
		
		func callService(callService: CallServiceProtocol, didReceiveCallRequestFromOpponent opponent: SVUser) {
			didReceiveCallRequestFromOpponentGotCalled = true
		}
		func callService(callService: CallServiceProtocol, didReceiveHangupFromOpponent opponent: SVUser) {
			didReceiveHangupFromOpponentGotCalled = true
		}
		func callService(callService: CallServiceProtocol, didReceiveRejectFromOpponent opponent: SVUser) {
			didReceiveRejectFromOpponentGotCalled = true
		}
		func callService(callService: CallServiceProtocol, didAnswerTimeoutForOpponent opponent: SVUser) {
			didAnswerTimeoutForOpponentGotCalled = true
		}
		func callService(callService: CallServiceProtocol, didChangeConnectionState state: RTCICEConnectionState) {
			didChangeConnectionStateGotCalled = true
		}
		func callService(callService: CallServiceProtocol, didChangeState state: CallServiceState) {
			didChangeStateGotCalled = true
			callServiceState = state
		}
		func callService(callService: CallServiceProtocol, didReceiveLocalVideoTrack localVideoTrack: RTCVideoTrack) {
			didReceiveLocalVideoTrackGotCalled = true
			videoTrack = localVideoTrack
		}
		func callService(callService: CallServiceProtocol, didReceiveRemoteVideoTrack remoteVideoTrack: RTCVideoTrack) {
			didReceiveRemoteVideoTrackGotCalled = true
			videoTrack = remoteVideoTrack
		}
		func callService(callService: CallServiceProtocol, didError error: NSError) {
			didErrorGotCalled = true
		}
		
		// Sending local SDP
		func callService(callService: CallServiceProtocol, didSendLocalSessionDescriptionMessage: SignalingMessage, toOpponent opponent: SVUser) {
			didSendLocalSessionDescriptionMessageGotCalled = true
		}
		func callService(callService: CallServiceProtocol, didErrorSendingLocalSessionDescriptionMessage: SignalingMessage, toOpponent opponent: SVUser, error: NSError) {
			didErrorSendingLocalSessionDescriptionMessageGotCalled = true
		}
		// Sending local ICE candidates
		func callService(callService: CallServiceProtocol, didSendLocalICECandidates: [RTCICECandidate], toOpponent opponent: SVUser) {
			didSendLocalICECandidatesGotCalled = true
		}
		func callService(callService: CallServiceProtocol, didErrorSendingLocalICECandidates: [RTCICECandidate], toOpponent opponent: SVUser, error: NSError) {
			didErrorSendingLocalICECandidatesGotCalled = true
		}
	}
	
}
