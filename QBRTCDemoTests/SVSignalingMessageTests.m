//
//  SVSignalingMessageTests.m
//  RTCDemo
//
//  Created by Anton Sokolchenko on 11/21/15.
//  Copyright © 2015 anton. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "SVUser.h"
#import "TestsStorage.h"

#import "SVSignalingMessage.h"
#import "SVSignalingMessage+QBChatMessage.h"
#import "SVSignalingMessageICE.h"
#import "SVSignalingMessageSDP.h"
#import "SVSignalingParams.h"
#import "CallServiceHelpers.h"
#import "QBChatMessage+SVSignalingMessage.h"

@interface SVSignalingMessageTests : XCTestCase

@end

@implementation SVSignalingMessageTests

- (void)testMessagesHaveCorrectType {
	SVSignalingMessage *answer = [SVSignalingMessage messageWithType:SVSignalingMessageType.answer params:nil];
	
	SVSignalingMessage *offer = [SVSignalingMessage messageWithType:SVSignalingMessageType.offer params:nil];
	
	SVSignalingMessage *candidate = [SVSignalingMessage messageWithType:SVSignalingMessageType.candidates params:nil];
	
	SVSignalingMessage *hangup = [SVSignalingMessage messageWithType:SVSignalingMessageType.hangup params:nil];
	
	XCTAssertEqual(answer.type, SVSignalingMessageType.answer);
	XCTAssertEqual(offer.type, SVSignalingMessageType.offer);
	XCTAssertEqual(candidate.type, SVSignalingMessageType.candidates);
	XCTAssertEqual(hangup.type, SVSignalingMessageType.hangup);
}

- (void)testMessagesFromQBChatMessageHaveCorrectType {
	// given
	SVSignalingMessage *answer = [SVSignalingMessage messageWithType:SVSignalingMessageType.answer params:nil];
	QBChatMessage *offerMsg = [QBChatMessage message];
	QBChatMessage *candidateMsg = [QBChatMessage message];
	QBChatMessage *hangupMsg = [QBChatMessage message];
	
	NSString *initiatorID = @"1";
	NSString *messageIDs = @"1,2";
	NSString *sessionID = [NSUUID UUID].UUIDString;
	
	offerMsg.text = SVSignalingMessageType.offer;
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	params[SVSignalingParams.sdp] = [CallServiceHelpers offerSDP];
	params[SVSignalingParams.membersIDs] = messageIDs;
	params[SVSignalingParams.initiatorID] = initiatorID;
	params[SVSignalingParams.sessionID] = sessionID;
	offerMsg.customParameters[SVSignalingParams.compressedData] = [QBChatMessage compressedCustomParams:params];
	
	candidateMsg.text = SVSignalingMessageType.candidates;
	params = [NSMutableDictionary dictionary];
	params[SVSignalingParams.sdp] = @"candidate:1009584571 1 udp 2122260223 192.168.8.197 58130 typ host generation 0 ufrag 0+C/nsdLdjk3x5eG";
	params[SVSignalingParams.index] = @"3";
	params[SVSignalingParams.mid] = @"4";
	params[SVSignalingParams.membersIDs] = messageIDs;
	params[SVSignalingParams.initiatorID] = initiatorID;
	params[SVSignalingParams.sessionID] = sessionID;
	candidateMsg.customParameters[SVSignalingParams.compressedData] = [QBChatMessage compressedCustomParams:params];
	
	hangupMsg.text = SVSignalingMessageType.hangup;
	params = [NSMutableDictionary dictionary];
	params[SVSignalingParams.membersIDs] = messageIDs;
	params[SVSignalingParams.initiatorID] = initiatorID;
	params[SVSignalingParams.sessionID] = sessionID;
	hangupMsg.customParameters[SVSignalingParams.compressedData] = [QBChatMessage compressedCustomParams:params];
	
	SVSignalingMessage *offer = [SVSignalingMessage messageWithQBChatMessage:offerMsg];
	
	SVSignalingMessage *candidate = [SVSignalingMessage messageWithQBChatMessage:candidateMsg];
	
	SVSignalingMessage *hangup = [SVSignalingMessage messageWithQBChatMessage:hangupMsg];
	
	XCTAssertEqual(answer.type, SVSignalingMessageType.answer);
	XCTAssertEqual(offer.type, SVSignalingMessageType.offer);
	XCTAssertEqual(candidate.type, SVSignalingMessageType.candidates);
	XCTAssertEqual(hangup.type, SVSignalingMessageType.hangup);
}

- (void)testMessagesSaveParamsDictionary {
	SVSignalingMessage *signalMessage = [SVSignalingMessage messageWithType:SVSignalingMessageType.answer params:@{@"custom_param":@"param"}];
	
	XCTAssertEqual(signalMessage.type, SVSignalingMessageType.answer);
	XCTAssertNotNil(signalMessage.params);
	
	XCTAssertEqual(signalMessage.params[@"custom_param"], @"param");
}

- (void)testSVMessageFromQBChatMessageHasCorrectUserInformation {
	// given
	SVSignalingMessage *preparedToSendMessage = [SVSignalingMessage messageWithType:SVSignalingMessageType.hangup params:nil];
	preparedToSendMessage.initiatorID = @1;
	preparedToSendMessage.membersIDs = @[@1, @2];
	preparedToSendMessage.sessionID = [NSUUID UUID].UUIDString;
	SVUser *sender = [TestsStorage svuserRealUser1];
	sender.password = nil;
	sender.tags = nil;
	preparedToSendMessage.sender = sender;
	
	// when
	QBChatMessage *sentMessage = [QBChatMessage messageWithSVSignalingMessage:preparedToSendMessage];
	sentMessage.senderID = sender.ID.unsignedIntegerValue;
	sentMessage.recipientID = 111;
	
	SVSignalingMessage *receivedMessage = [SVSignalingMessage messageWithQBChatMessage:sentMessage];
	
	XCTAssertEqualObjects(sender, receivedMessage.sender);
}

@end
