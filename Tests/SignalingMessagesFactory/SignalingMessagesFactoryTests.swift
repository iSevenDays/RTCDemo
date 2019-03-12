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
		let sessionID = UUID().uuidString
		let sessionDetails = SessionDetails(initiatorID: sender.id!.uintValue, membersIDs: [sender.id!.uintValue, testUser.id!.uintValue], sessionID: sessionID)
		
		do {
			// when
			
			let convertedQBMessage = try signalingMessagesFactory.qbMessageFromSignalingMessage(signalingMessage, sender: sender, sessionDetails: sessionDetails)
			convertedQBMessage.senderID = sender.id!.uintValue
			// then
			
			let (receivedSignalingMessage, receivedSender, receivedSessionDetails) = try signalingMessagesFactory.signalingMessageFromQBMessage(convertedQBMessage)
			
			XCTAssertNotNil(receivedSignalingMessage)
			XCTAssertNotNil(receivedSender)
			XCTAssertNotNil(receivedSessionDetails)
			
			XCTAssertEqual(sender.id, receivedSender.id)
			XCTAssertEqual(sender.fullName, receivedSender.fullName)
			XCTAssertEqual(sender.login, receivedSender.login)
			XCTAssert(sessionDetails == receivedSessionDetails!)
			
			switch receivedSignalingMessage {
			case .answer(sdp: _): XCTFail()
			case .offer(sdp: _): XCTFail()
			case .reject: XCTFail()
			case .candidates(candidates: _): XCTFail()
			case .hangup: break
			case .user(enteredChatRoomName: _): XCTFail()
			}
			
		} catch let error {
			XCTAssertNil(error)
		}
	}
	
	func testConvertsSignalingUserMessageToQBMessageAndBack() {
		// given
		let roomName = "test chat toom name"
		let signalingMessage = SignalingMessage.user(enteredChatRoomName: roomName)
		
		do {
			// when
			
			let convertedQBMessage = try signalingMessagesFactory.qbMessageFromSignalingMessage(signalingMessage, sender: sender, sessionDetails: nil)
			convertedQBMessage.senderID = sender.id!.uintValue
			// then
			
			let (receivedSignalingMessage, receivedSender, receivedSessionDetails) = try signalingMessagesFactory.signalingMessageFromQBMessage(convertedQBMessage)
			
			XCTAssertNotNil(receivedSignalingMessage)
			XCTAssertNotNil(receivedSender)
			XCTAssertNil(receivedSessionDetails)
			
			XCTAssertEqual(sender.id, receivedSender.id)
			XCTAssertEqual(sender.fullName, receivedSender.fullName)
			XCTAssertEqual(sender.login, receivedSender.login)
			
			switch receivedSignalingMessage {
			case .answer(sdp: _): XCTFail()
			case .offer(sdp: _): XCTFail()
			case .reject: XCTFail()
			case .candidates(candidates: _): XCTFail()
			case .hangup: break
			case let .user(enteredChatRoomName: chatRoomName): XCTAssertEqual(chatRoomName, roomName)
			}
			
		} catch let error {
			XCTAssertNil(error)
		}
	}
	
	func testConvertsSignalingICEMessageToQBMessageAndBack() {
		// given
		let rtcIceCandidateAudio = RTCIceCandidate(sdp: "candidate:1009584571 1 udp 2122260223 192.168.8.197 58130 typ host generation 0 ufrag 0+C/nsdLdjk3x5eG", sdpMLineIndex: 0, sdpMid: "audio")
		
		let rtcIceCandidateVideo = RTCIceCandidate(sdp: "candidate:1009584571 1 udp 2122260223 192.168.8.197 62216 typ host generation 0 ufrag 0+C/nsdLdjk3x5eG", sdpMLineIndex: 1, sdpMid: "video")
		
		let signalingMessage = SignalingMessage.candidates(candidates: [rtcIceCandidateAudio, rtcIceCandidateVideo])
		let sessionID = UUID().uuidString
		let sessionDetails = SessionDetails(initiatorID: sender.id!.uintValue, membersIDs: [sender.id!.uintValue, testUser.id!.uintValue], sessionID: sessionID)
		
		do {
			// when
			let convertedQBMessage = try signalingMessagesFactory.qbMessageFromSignalingMessage(signalingMessage, sender: sender, sessionDetails: sessionDetails)
			convertedQBMessage.senderID = sender.id!.uintValue
			
			// then
			let (receivedSignalingMessage, receivedSender, receivedSessionDetails) = try signalingMessagesFactory.signalingMessageFromQBMessage(convertedQBMessage)
			
			XCTAssertNotNil(receivedSignalingMessage)
			XCTAssertNotNil(receivedSender)
			XCTAssertNotNil(receivedSessionDetails)
			
			XCTAssertEqual(sender.id, receivedSender.id)
			XCTAssertEqual(sender.fullName, receivedSender.fullName)
			XCTAssertEqual(sender.login, receivedSender.login)
			XCTAssert(sessionDetails == receivedSessionDetails!)
			
			switch receivedSignalingMessage {
			case .answer(sdp: _): XCTFail()
			case .offer(sdp: _): XCTFail()
			case .hangup: XCTFail()
			case .reject: XCTFail()
			case .user(enteredChatRoomName: _): XCTFail()
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
		let sessionDescription = RTCSessionDescription(type: .offer, sdp: CallServiceHelpers.offerSDP)
		let signalingMessage = SignalingMessage.offer(sdp: sessionDescription)
		let sessionID = UUID().uuidString
		let sessionDetails = SessionDetails(initiatorID: sender.id!.uintValue, membersIDs: [sender.id!.uintValue, testUser.id!.uintValue], sessionID: sessionID)
		
		do {
			// when
			let convertedQBMessage = try signalingMessagesFactory.qbMessageFromSignalingMessage(signalingMessage, sender: sender, sessionDetails: sessionDetails)
			convertedQBMessage.senderID = sender.id!.uintValue
			
			// then
			let (receivedSignalingMessage, receivedSender, receivedSessionDetails) = try signalingMessagesFactory.signalingMessageFromQBMessage(convertedQBMessage)
			
			XCTAssertNotNil(receivedSignalingMessage)
			XCTAssertNotNil(receivedSender)
			XCTAssertNotNil(receivedSessionDetails)
			
			XCTAssertEqual(sender.id, receivedSender.id)
			XCTAssertEqual(sender.fullName, receivedSender.fullName)
			XCTAssertEqual(sender.login, receivedSender.login)
			XCTAssert(sessionDetails == receivedSessionDetails!)
			
			switch receivedSignalingMessage {
			case .answer(sdp: _): XCTFail()
			case let .offer(sdp: offerSDP):
				XCTAssertEqual(sessionDescription.sdp, offerSDP.sdp)
			case .reject: XCTFail()
			case .candidates(candidates: _): XCTFail()
			case .hangup: XCTFail()
			case .user(enteredChatRoomName: _): XCTFail()
			}
			
		} catch let error {
			XCTAssertNil(error)
		}
	}
	
}
