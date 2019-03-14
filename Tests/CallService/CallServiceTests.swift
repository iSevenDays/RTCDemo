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

class CallServiceTests: BaseTestCase {
	
	let user1 = TestsStorage.svuserRealUser1
	let user2 = TestsStorage.svuserRealUser2
	let user3 = SVUser(ID: 1, login: "login", fullName: "full_name", password: "", tags: ["tag1"])
	
	var fakeSignalingChannel: FakeSignalingChannel!
	var callService: CallService!
	var mockOutput: MockOutput!
	var mockOutputChatRoom: MockOutputChatRoom!
	
	override func setUp() {
		fakeSignalingChannel = FakeSignalingChannel()
		callService = CallService()
		ServicesConfigurator().configureCallService(callService)
		callService.signalingChannel = fakeSignalingChannel
		
		mockOutput = MockOutput()
		callService.addObserver(mockOutput)

		mockOutputChatRoom = MockOutputChatRoom()
		callService.addObserver(mockOutputChatRoom)
	}
	
	func currentSelectorTestExpectation() -> XCTestExpectation {
		var selectorName = "testExpectation"
		if let invocation = invocation{
			selectorName = NSStringFromSelector(invocation.selector)
		}
		return expectation(description: selectorName)
	}
	
	func waitForTestExpectations() {
		waitForExpectations(timeout: 10.0) { (error) in
			XCTAssertNil(error)
		}
	}
	
	func testCanConnectWithUserAndHaveConnectedState() {
		// given
		let expectation = currentSelectorTestExpectation()
		
		// when
		callService.connectWithUser(user1) { (error) in
			XCTAssertNil(error)
			XCTAssertEqual(self.callService.state, CallServiceState.connected)
			expectation.fulfill()
		}
		
		// then
		waitForTestExpectations()
	}
	
	
	//MARK: - CallClientObserver tests
	
	func testHasLocalVideoTrackAfterStartCall() {
		// when
		callService.connectWithUser(user1, completion: nil)
		
		XCTAssertNotNil(try? callService.startCallWithOpponent(user2))
		
		// then
		XCTAssertTrue(mockOutput.didReceiveLocalVideoTrackGotCalled)
		XCTAssertNotNil(mockOutput.videoTrack)
	}
	
	func testCorrectlyChangesClientStateToConnected() {
		// when
		callService.connectWithUser(user1, completion: nil)
		
		// then
		XCTAssertTrue(mockOutput.didChangeStateGotCalled)
		XCTAssertEqual(mockOutput.callServiceState, CallServiceState.connected)
	}
	
	func testCorrectlyChangesClientStateToDisconnectedAfterDisconnectFromChat() {
		// when
		callService.connectWithUser(user1, completion: nil)
		callService.disconnectWithCompletion(nil)
		
		// then
		XCTAssertTrue(mockOutput.didChangeStateGotCalled)
		XCTAssertEqual(mockOutput.callServiceState, CallServiceState.disconnected)
	}
	
	func testCorrectlyHangupsJustStartedCall() {
		// when
		callService.connectWithUser(user1, completion: nil)
		XCTAssertNotNil(try? callService.startCallWithOpponent(user2))
		waitForTimeInterval(50)
		callService.hangup()
		
		// then
		XCTAssertTrue(mockOutput.didStartDialingOpponentGotCalled)
		XCTAssertTrue(mockOutput.didStopDialingOpponentGotCalled)
		XCTAssertTrue(mockOutput.didSendHangupToOpponentGotCalled)
		XCTAssertFalse(mockOutput.didErrorGotCalled)
		XCTAssertEqual(callService.dialingTimers.count, 0)

		let peerConnections: [PeerConnection] = callService.connections.flatMap({$0.value})
		let peerConnectionsStates = peerConnections.compactMap({$0.state})
		XCTAssertFalse(peerConnectionsStates.contains(where: {$0 == PeerConnectionState.initial}))
	}
	
	func testCorrectlySendsMessageCurrentUserEnteredChatRoom() {
		// given
		let chatName = "chat name"
		
		// when
		callService.connectWithUser(user1, completion: nil)
		callService.sendMessageCurrentUserEnteredChatRoom(chatName, toUser: user2)
		
		// then
		XCTAssertTrue(mockOutputChatRoom.didSendUserEnteredChatRoomNameGotCalled)
		XCTAssertEqual(mockOutputChatRoom.opponent, user2)
		XCTAssertEqual(mockOutputChatRoom.chatRoomName, chatName)
	}
	
	//MARK: - Signaling Processor observer methods processing
 
	func testSendsRejectIfAlreadyHasActiveCall() {
		// given
		let rtcOfferSDP = RTCSessionDescription(type: .offer, sdp: CallServiceHelpers.offerSDP)
		
		let sessionDetails = SessionDetails(initiatorID: UInt(user1.ID!), membersIDs: [1])
		
		// when
		callService.connectWithUser(user1, completion: nil)
		XCTAssertNotNil(try? callService.startCallWithOpponent(user2))
		
		callService.didReceiveOffer(callService.signalingProcessor, offer: rtcOfferSDP, fromOpponent: user3, sessionDetails: sessionDetails)
		
		// then
		XCTAssertFalse(mockOutput.didReceiveCallRequestFromOpponentGotCalled)
	}
	
	/**
	Do not reject double offer, user may send many message with offer SDP
	*/
	func testDoesntSendRejectIfAlreadyHasActiveCallWithTheSameUserAndSessionID() {
		// given
		let rtcOfferSDP = RTCSessionDescription(type: .offer, sdp: CallServiceHelpers.offerSDP)
		
		let sessionDetails = SessionDetails(initiatorID: UInt(user2.ID!), membersIDs: [UInt(user2.ID!)])
		
		// when
		callService.connectWithUser(user1, completion: nil)
		callService.didReceiveOffer(callService.signalingProcessor, offer: rtcOfferSDP, fromOpponent: user2, sessionDetails: sessionDetails)
		waitForTimeInterval(50)
		XCTAssertNotNil(try? callService.acceptCallFromOpponent(user2))
		waitForTimeInterval(50)
		callService.didReceiveOffer(callService.signalingProcessor, offer: rtcOfferSDP, fromOpponent: user2, sessionDetails: sessionDetails)
		
		// then
		XCTAssertTrue(mockOutput.didReceiveCallRequestFromOpponentGotCalled)
		XCTAssertFalse(mockOutput.didSendRejectToOpponentGotCalled)
		XCTAssertEqual(callService.pendingRequests.count, 0)
	}
	
	func testCorrectlyAcceptsOfferFromOpponent() {
		// given
		let rtcOfferSDP = RTCSessionDescription(type: .offer, sdp: CallServiceHelpers.offerSDP)
	
		let sessionDetails = SessionDetails(initiatorID: UInt(user1.ID!), membersIDs: [1])
		
		// when
		callService.connectWithUser(user1, completion: nil)
		callService.didReceiveOffer(callService.signalingProcessor, offer: rtcOfferSDP, fromOpponent: user1, sessionDetails: sessionDetails)
		XCTAssertNotNil(try? callService.acceptCallFromOpponent(user1))
		
		// then
		XCTAssertTrue(mockOutput.didReceiveCallRequestFromOpponentGotCalled)
		XCTAssertEqual(callService.sessions.count, 1)
		XCTAssertEqual(callService.connections.count, 1)
		XCTAssert(callService.sessions[sessionDetails.sessionID]! == sessionDetails)
		XCTAssertEqual(callService.pendingRequests.count, 0)
	}
	
	func testCorrectlyProcessesHangupMessage_whenHangupIsReceivedForActiveCall() {
		// when
		callService.connectWithUser(user1, completion: nil)
		XCTAssertNotNil(try? callService.startCallWithOpponent(user2))
		guard let createdConnectionWithUser2 = callService.connections.values.first?.first else {
			XCTFail()
			return
		}
		
		callService.didReceiveHangup(callService.signalingProcessor, fromOpponent: user2, sessionDetails: callService.sessions[createdConnectionWithUser2.sessionID]!)
		
		// then
		XCTAssertTrue(mockOutput.didReceiveHangupFromOpponentGotCalled)
		XCTAssertEqual(callService.dialingTimers.count, 0)
		XCTAssertEqual(callService.pendingRequests.count, 0)
	}
	
	func testCorrectlyProcessesRejectMessage_whenRejectIsReceivedForSentOffer() {
		// when
		callService.connectWithUser(user1, completion: nil)
		do {
			try callService.startCallWithOpponent(user2)
		} catch let error {
			XCTAssertNil(error)
		}
		XCTAssertNotNil(try? callService.startCallWithOpponent(user2))
		guard let createdConnectionWithUser2 = callService.connections.values.first?.first else {
			XCTFail()
			return
		}
		
		callService.didReceiveReject(callService.signalingProcessor, fromOpponent: user2, sessionDetails: callService.sessions[createdConnectionWithUser2.sessionID]!)
		
		
		// then
		XCTAssertTrue(mockOutput.didReceiveRejectFromOpponentGotCalled)
		XCTAssertEqual(createdConnectionWithUser2.state, PeerConnectionState.closed)
		XCTAssertTrue(mockOutput.didStartDialingOpponentGotCalled)
		XCTAssertTrue(mockOutput.didStopDialingOpponentGotCalled)
		XCTAssertEqual(callService.dialingTimers.count, 0)
		XCTAssertEqual(callService.pendingRequests.count, 0)
	}
	
	func testRejectsIncomingCallOfferForTheAlreadyRejectedCall_andTheSameSession() {
		// given
		let rtcOfferSDP = RTCSessionDescription(type: .offer, sdp: CallServiceHelpers.offerSDP)
		
		let sessionDetails = SessionDetails(initiatorID: UInt(user1.ID!), membersIDs: [1])
		sessionDetails.sessionState = .rejected
		callService.sessions[sessionDetails.sessionID] = sessionDetails
		
		// when
		callService.connectWithUser(user1, completion: nil)
		callService.didReceiveOffer(callService.signalingProcessor, offer: rtcOfferSDP, fromOpponent: user1, sessionDetails: sessionDetails)
		
		// then
		XCTAssertFalse(mockOutput.didReceiveCallRequestFromOpponentGotCalled)
		XCTAssertEqual(callService.sessions.count, 1)
		XCTAssertEqual(callService.connections.count, 0)
		XCTAssert(callService.sessions[sessionDetails.sessionID]! == sessionDetails)
		XCTAssertEqual(callService.pendingRequests.count, 0)
	}
	
	func testCorrectlyProcessesAnswerMessage_whenAnswerIsReceivedForActiveCall() {
		// given
		let unusedSessionSDP = RTCSessionDescription(type: .answer, sdp: CallServiceHelpers.answerSDP)
		
		// when
		callService.connectWithUser(user1, completion: nil)
		do {
			try callService.startCallWithOpponent(user2)
		} catch let error {
			XCTFail("\(error)")
		}
		guard let createdConnectionWithUser2 = callService.connections.values.first?.first else {
			XCTFail()
			return
		}
		
		waitForTimeInterval(50)
		
		callService.didReceiveAnswer(callService.signalingProcessor, answer: unusedSessionSDP, fromOpponent: user2, sessionDetails: callService.sessions[createdConnectionWithUser2.sessionID]!)
		
		// then
		XCTAssertTrue(mockOutput.didStartDialingOpponentGotCalled)
		XCTAssertTrue(mockOutput.didStopDialingOpponentGotCalled)
		XCTAssertFalse(mockOutput.didAnswerTimeoutForOpponentGotCalled)
		XCTAssertTrue(mockOutput.didReceiveAnswerFromOpponentGotCalled)
		XCTAssertEqual(callService.dialingTimers.count, 0)
		XCTAssertEqual(callService.pendingRequests.count, 0)
	}
	
	func testNotifiesAboutReceivedUserForChatRoom() {
		// when
		callService.didReceiveUser(callService.signalingProcessor, user: user2, forChatRoomName: "roomName")
		
		// then
		XCTAssertTrue(mockOutputChatRoom.didReceiveUserGotCalled)
	}
	
	func testStoresRejectedSession() {
		// given
		let rtcOfferSDP = RTCSessionDescription(type: .offer, sdp: CallServiceHelpers.offerSDP)
		
		let sessionDetails = SessionDetails(initiatorID: UInt(user1.ID!), membersIDs: [UInt(user1.ID!), UInt(user2.ID!)])
		
		// when
		callService.connectWithUser(user1, completion: nil)
		callService.didReceiveOffer(callService.signalingProcessor, offer: rtcOfferSDP, fromOpponent: user2, sessionDetails: sessionDetails)
		
		XCTAssertNotNil(try? callService.sendRejectCallToOpponent(user2))
		
		// then
		XCTAssertEqual(callService.sessions.count, 1)
		XCTAssertEqual(callService.connections.count, 0)
		XCTAssertEqual(callService.sessions[sessionDetails.sessionID]!.sessionState, SessionDetailsState.rejected)
		XCTAssertEqual(callService.pendingRequests.count, 0)
	}
	
	//MARK: - PeerConnection observer tests
	
	func testsStartsDialingOpponentWithLocalSessionDescription() {
		// given
		let localSDP = RTCSessionDescription(type: .offer, sdp: CallServiceHelpers.offerSDP)
		
		// when
		callService.connectWithUser(user1, completion: nil)
		XCTAssertNotNil(try? callService.startCallWithOpponent(user2))
		
		guard let createdConnectionWithUser2 = callService.connections.values.first?.first else {
			XCTFail()
			return
		}
		let peerConnection = PeerConnection(opponent: user2, sessionID: createdConnectionWithUser2.sessionID, ICEServers: callService.ICEServers, factory: callService.factory, mediaStreamConstraints: callService.defaultMediaStreamConstraints, peerConnectionConstraints: callService.defaultPeerConnectionConstraints, offerAnswerConstraints: callService.defaultOfferConstraints)
		
		callService.peerConnection(peerConnection, didSetLocalSessionOfferDescription: localSDP)
		
		// then
		XCTAssertTrue(mockOutput.didStartDialingOpponentGotCalled)
		XCTAssertFalse(mockOutput.didStopDialingOpponentGotCalled)
		
		XCTAssertEqual(callService.dialingTimers.count, 1)
		XCTAssertEqual(callService.connections.count, 1)
		XCTAssertEqual(callService.sessions.count, 1)
	}
	
	func testsSendsLocalICECandidates() {
		// given
		let localICECandidateAudio = RTCIceCandidate(sdp: "candidate:1009584571 1 udp 2122260223 192.168.8.197 58130 typ host generation 0 ufrag 0+C/nsdLdjk3x5eG", sdpMLineIndex: 0, sdpMid: "audio")
		
		let sessionDetails = SessionDetails(initiatorID: 1, membersIDs: [1])
		callService.sessions[sessionDetails.sessionID] = sessionDetails
		
		let peerConnection = PeerConnection(opponent: user2, sessionID: sessionDetails.sessionID, ICEServers: callService.ICEServers, factory: callService.factory, mediaStreamConstraints: callService.defaultMediaStreamConstraints, peerConnectionConstraints: callService.defaultPeerConnectionConstraints, offerAnswerConstraints: callService.defaultOfferConstraints)
		
		// when
		callService.connectWithUser(user1, completion: nil)
		XCTAssertNotNil(try? callService.startCallWithOpponent(user2))
		callService.peerConnection(peerConnection, didSetLocalICECandidates: localICECandidateAudio)
		
		// then
		XCTAssertTrue(mockOutput.didSendLocalICECandidatesGotCalled)
		XCTAssertFalse(mockOutput.didErrorSendingLocalICECandidatesGotCalled)
	}
	
	class MockOutput: CallServiceObserver {
		var didReceiveCallRequestFromOpponentGotCalled = false
		var didReceiveAnswerFromOpponentGotCalled = false
		var didReceiveHangupFromOpponentGotCalled = false
		var didReceiveRejectFromOpponentGotCalled = false
		var didAnswerTimeoutForOpponentGotCalled = false
		var didChangeConnectionStateGotCalled = false
		var didChangeStateGotCalled = false
		var didReceiveLocalVideoTrackGotCalled = false
		var didReceiveRemoteVideoTrackGotCalled = false
		var didErrorGotCalled = false

		var didStartDialingOpponentGotCalled = false
		var didStopDialingOpponentGotCalled = false
		var opponent: SVUser?
		
		var didSendLocalICECandidatesGotCalled = false
		var didErrorSendingLocalICECandidatesGotCalled = false
		
		var didSendRejectToOpponentGotCalled = false
		var didSendHangupToOpponentGotCalled = false
		
		var callServiceState = CallServiceState.undefined
		var videoTrack: RTCVideoTrack?
		
		func callService(_ callService: CallServiceProtocol, didReceiveCallRequestFromOpponent opponent: SVUser) {
			didReceiveCallRequestFromOpponentGotCalled = true
		}
		func callService(_ callService: CallServiceProtocol, didReceiveAnswerFromOpponent opponent: SVUser) {
			didReceiveAnswerFromOpponentGotCalled = true
		}
		func callService(_ callService: CallServiceProtocol, didReceiveHangupFromOpponent opponent: SVUser) {
			didReceiveHangupFromOpponentGotCalled = true
		}
		func callService(_ callService: CallServiceProtocol, didReceiveRejectFromOpponent opponent: SVUser) {
			didReceiveRejectFromOpponentGotCalled = true
		}
		func callService(_ callService: CallServiceProtocol, didAnswerTimeoutForOpponent opponent: SVUser) {
			didAnswerTimeoutForOpponentGotCalled = true
		}
		func callService(_ callService: CallServiceProtocol, didChangeConnectionState state: RTCIceConnectionState) {
			didChangeConnectionStateGotCalled = true
		}
		func callService(_ callService: CallServiceProtocol, didChangeState state: CallServiceState) {
			didChangeStateGotCalled = true
			callServiceState = state
		}
		func callService(_ callService: CallServiceProtocol, didReceiveLocalVideoTrack localVideoTrack: RTCVideoTrack) {
			didReceiveLocalVideoTrackGotCalled = true
			videoTrack = localVideoTrack
		}
		func callService(_ callService: CallServiceProtocol, didReceiveRemoteVideoTrack remoteVideoTrack: RTCVideoTrack) {
			didReceiveRemoteVideoTrackGotCalled = true
			videoTrack = remoteVideoTrack
		}
		func callService(_ callService: CallServiceProtocol, didError error: Error) {
			didErrorGotCalled = true
		}
		
		func callService(_ callService: CallServiceProtocol, didStartDialingOpponent opponent: SVUser) {
			self.opponent = opponent
			didStartDialingOpponentGotCalled = true
		}
		
		func callService(_ callService: CallServiceProtocol, didStopDialingOpponent opponent: SVUser) {
			self.opponent = opponent
			didStopDialingOpponentGotCalled = true
		}
		
		// Sending local ICE candidates
		func callService(_ callService: CallServiceProtocol, didSendLocalICECandidates: [RTCIceCandidate], toOpponent opponent: SVUser) {
			didSendLocalICECandidatesGotCalled = true
		}
		func callService(_ callService: CallServiceProtocol, didErrorSendingLocalICECandidates: [RTCIceCandidate], toOpponent opponent: SVUser, error: NSError) {
			didErrorSendingLocalICECandidatesGotCalled = true
		}
		
		func callService(_ callService: CallServiceProtocol, didSendRejectToOpponent opponent: SVUser) {
			didSendRejectToOpponentGotCalled = true
		}
		
		func callService(_ callService: CallServiceProtocol, didSendHangupToOpponent opponent: SVUser) {
			didSendHangupToOpponentGotCalled = true
		}
		

	}

	class MockOutputChatRoom: CallServiceChatRoomObserver {
		var didReceiveUserGotCalled = false
		var didSendUserEnteredChatRoomNameGotCalled = false
		var chatRoomName: String?
		var opponent: SVUser?

		func callService(_ callService: CallServiceProtocol, didReceiveUser user: SVUser, forChatRoomName chatRoomName: String) {
			didReceiveUserGotCalled = true
		}

		func callService(_ callService: CallServiceProtocol, didSendUserEnteredChatRoomName chatRoomName: String, toUser: SVUser) {
			self.chatRoomName = chatRoomName
			didSendUserEnteredChatRoomNameGotCalled = true
			opponent = toUser
		}
	}
	
}
