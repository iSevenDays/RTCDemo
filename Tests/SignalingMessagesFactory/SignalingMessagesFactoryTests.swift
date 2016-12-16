//
//  SignalingMessagesFactoryTests.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 11.12.16.
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

class SignalingMessagesFactoryTests: XCTestCase {
	
	var sender: SVUser!
	var testUser: SVUser!
	var signalingMessagesFactory: SignalingMessagesFactory!
	
	override func setUp() {
		sender = TestsStorage.svuserRealUser1
		testUser = TestsStorage.svuserTest
		signalingMessagesFactory = SignalingMessagesFactory()
	}
	
	func testConvertsSignalingHangupMessageToQBMessageAndBack() {
		// given
		let signalingMessage = SignalingMessage.hangup
		let sessionID = NSUUID().UUIDString
		let sessionDetails = SessionDetails(initiatorID: sender.ID!.unsignedIntegerValue, membersIDs: [sender.ID!.unsignedIntegerValue, testUser.ID!.unsignedIntegerValue], sessionID: sessionID)
		
		do {
			// when
			
			let convertedQBMessage = try signalingMessagesFactory.qbMessageFromSignalingMessage(signalingMessage, sender: sender, sessionDetails: sessionDetails)
			convertedQBMessage.senderID = sender.ID!.unsignedIntegerValue
			// then
			
			let (receivedSignalingMessage, receivedSender, receivedSessionDetails) = try signalingMessagesFactory.signalingMessageFromQBMessage(convertedQBMessage)
			
			XCTAssertNotNil(receivedSignalingMessage)
			XCTAssertNotNil(receivedSender)
			XCTAssertNotNil(receivedSessionDetails)
			
			XCTAssertEqual(sender.ID, receivedSender.ID)
			XCTAssertEqual(sender.fullName, receivedSender.fullName)
			XCTAssertEqual(sender.login, receivedSender.login)
			XCTAssert(sessionDetails == receivedSessionDetails)
			
			switch receivedSignalingMessage {
			case .answer(sdp: _): XCTFail()
			case .offer(sdp: _): XCTFail()
			case .reject: XCTFail()
			case .candidates(candidates: _): XCTFail()
			case .hangup: break
			}
			
		} catch let error {
			XCTAssertNil(error)
		}
	}
	
	func testConvertsSignalingICEMessageToQBMessageAndBack() {
		// given
		let rtcIceCandidateAudio = RTCICECandidate(mid: "audio", index: 0, sdp: "candidate:1009584571 1 udp 2122260223 192.168.8.197 58130 typ host generation 0 ufrag 0+C/nsdLdjk3x5eG")
		
		let rtcIceCandidateVideo = RTCICECandidate(mid: "video", index: 1, sdp: "candidate:1009584571 1 udp 2122260223 192.168.8.197 62216 typ host generation 0 ufrag 0+C/nsdLdjk3x5eG")
		
		let signalingMessage = SignalingMessage.candidates(candidates: [rtcIceCandidateAudio, rtcIceCandidateVideo])
		let sessionID = NSUUID().UUIDString
		let sessionDetails = SessionDetails(initiatorID: sender.ID!.unsignedIntegerValue, membersIDs: [sender.ID!.unsignedIntegerValue, testUser.ID!.unsignedIntegerValue], sessionID: sessionID)
		
		do {
			// when
			let convertedQBMessage = try signalingMessagesFactory.qbMessageFromSignalingMessage(signalingMessage, sender: sender, sessionDetails: sessionDetails)
			convertedQBMessage.senderID = sender.ID!.unsignedIntegerValue
			
			// then
			let (receivedSignalingMessage, receivedSender, receivedSessionDetails) = try signalingMessagesFactory.signalingMessageFromQBMessage(convertedQBMessage)
			
			XCTAssertNotNil(receivedSignalingMessage)
			XCTAssertNotNil(receivedSender)
			XCTAssertNotNil(receivedSessionDetails)
			
			XCTAssertEqual(sender.ID, receivedSender.ID)
			XCTAssertEqual(sender.fullName, receivedSender.fullName)
			XCTAssertEqual(sender.login, receivedSender.login)
			XCTAssert(sessionDetails == receivedSessionDetails)
			
			switch receivedSignalingMessage {
			case .answer(sdp: _): XCTFail()
			case .offer(sdp: _): XCTFail()
			case .hangup: XCTFail()
			case .reject: XCTFail()
				
			case let .candidates(candidates: candidates):
				XCTAssertEqual(candidates.count, 2)
				guard let receivedAudioCandidate = candidates.filter({$0.sdpMLineIndex == 0}).first else {
					XCTFail()
					return
				}
				XCTAssertEqual(receivedAudioCandidate.sdp, rtcIceCandidateAudio.sdp)
				XCTAssertEqual(receivedAudioCandidate.sdpMid, rtcIceCandidateAudio.sdpMid)
				XCTAssertEqual(receivedAudioCandidate.sdpMLineIndex, rtcIceCandidateAudio.sdpMLineIndex)
				
				
				guard let receivedVideoCandidate = candidates.filter({$0.sdpMLineIndex == 1}).first else {
					XCTFail()
					return
				}
				XCTAssertEqual(receivedVideoCandidate.sdp, rtcIceCandidateVideo.sdp)
				XCTAssertEqual(receivedVideoCandidate.sdpMid, rtcIceCandidateVideo.sdpMid)
				XCTAssertEqual(receivedVideoCandidate.sdpMLineIndex, rtcIceCandidateVideo.sdpMLineIndex)
				break
			}
			
		} catch let error {
			XCTAssertNil(error)
		}
	}
	
	func testConvertsSignalingOfferMessageToQBMessageAndBack() {
		// given
		let sessionDescription = RTCSessionDescription(type: "offer", sdp: CallServiceHelpers.offerSDP())
		let signalingMessage = SignalingMessage.offer(sdp: sessionDescription)
		let sessionID = NSUUID().UUIDString
		let sessionDetails = SessionDetails(initiatorID: sender.ID!.unsignedIntegerValue, membersIDs: [sender.ID!.unsignedIntegerValue, testUser.ID!.unsignedIntegerValue], sessionID: sessionID)
		
		do {
			// when
			let convertedQBMessage = try signalingMessagesFactory.qbMessageFromSignalingMessage(signalingMessage, sender: sender, sessionDetails: sessionDetails)
			convertedQBMessage.senderID = sender.ID!.unsignedIntegerValue
			
			// then
			let (receivedSignalingMessage, receivedSender, receivedSessionDetails) = try signalingMessagesFactory.signalingMessageFromQBMessage(convertedQBMessage)
			
			XCTAssertNotNil(receivedSignalingMessage)
			XCTAssertNotNil(receivedSender)
			XCTAssertNotNil(receivedSessionDetails)
			
			XCTAssertEqual(sender.ID, receivedSender.ID)
			XCTAssertEqual(sender.fullName, receivedSender.fullName)
			XCTAssertEqual(sender.login, receivedSender.login)
			XCTAssert(sessionDetails == receivedSessionDetails)
			
			switch receivedSignalingMessage {
			case .answer(sdp: _): XCTFail()
			case let .offer(sdp: offerSDP):
				XCTAssertEqual(sessionDescription.description, offerSDP.description)
			case .reject: XCTFail()
			case .candidates(candidates: _): XCTFail()
			case .hangup: XCTFail()
			}
			
		} catch let error {
			XCTAssertNil(error)
		}
	}
	
}
