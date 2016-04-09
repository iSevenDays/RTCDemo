//
//  SVSignalingMessageTests.m
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 11/21/15.
//  Copyright © 2015 anton. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCHamcrest/OCHamcrest.h>

#import "SVUser.h"
#import "TestsStorage.h"

#import "SVSignalingMessage.h"
#import "SVSignalingMessage+QBChatMessage.h"
#import "SVSignalingMessageICE.h"
#import "SVSignalingMessageSDP.h"
#import "SVSignalingParams.h"
#import "CallServiceHelpers.h"

@interface SVSignalingMessageTests : XCTestCase

@end

@implementation SVSignalingMessageTests

- (void)testMessagesHaveCorrectType {
	SVSignalingMessage *answer = [SVSignalingMessage messageWithType:SVSignalingMessageType.answer params:nil];
	
	SVSignalingMessage *offer = [SVSignalingMessage messageWithType:SVSignalingMessageType.offer params:nil];
	
	SVSignalingMessage *candidate = [SVSignalingMessage messageWithType:SVSignalingMessageType.candidate params:nil];
	
	SVSignalingMessage *hangup = [SVSignalingMessage messageWithType:SVSignalingMessageType.hangup params:nil];
	
	assertThat(answer.type, equalTo(SVSignalingMessageType.answer));
	assertThat(offer.type, equalTo(SVSignalingMessageType.offer));
	assertThat(candidate.type, equalTo(SVSignalingMessageType.candidate));
	assertThat(hangup.type, equalTo(SVSignalingMessageType.hangup));
}

- (void)testMessagesFromQBChatMessageHaveCorrectType {
	// given
	SVSignalingMessage *answer = [SVSignalingMessage messageWithType:SVSignalingMessageType.answer params:nil];
	QBChatMessage *offerMsg = [QBChatMessage message];
	QBChatMessage *candidateMsg = [QBChatMessage message];
	QBChatMessage *hangupMsg = [QBChatMessage message];
	
	offerMsg.text = SVSignalingMessageType.offer;
	offerMsg.customParameters = [NSMutableDictionary dictionary];
	offerMsg.customParameters[SVSignalingParams.sdp] = [CallServiceHelpers offerSDP];
	
	candidateMsg.text = SVSignalingMessageType.candidate;
	candidateMsg.customParameters = [NSMutableDictionary dictionary];
	candidateMsg.customParameters[SVSignalingParams.sdp] = @"candidate:1009584571 1 udp 2122260223 192.168.8.197 58130 typ host generation 0 ufrag 0+C/nsdLdjk3x5eG";
	candidateMsg.customParameters[SVSignalingParams.index] = @"3";
	candidateMsg.customParameters[SVSignalingParams.mid] = @"4";
	
	hangupMsg.text = SVSignalingMessageType.hangup;
	
	SVSignalingMessage *offer = [SVSignalingMessage messageWithQBChatMessage:offerMsg];
	
	SVSignalingMessage *candidate = [SVSignalingMessage messageWithQBChatMessage:candidateMsg];
	
	SVSignalingMessage *hangup = [SVSignalingMessage messageWithQBChatMessage:hangupMsg];
	
	assertThat(answer.type, equalTo(SVSignalingMessageType.answer));
	assertThat(offer.type, equalTo(SVSignalingMessageType.offer));
	assertThat(candidate.type, equalTo(SVSignalingMessageType.candidate));
	assertThat(hangup.type, equalTo(SVSignalingMessageType.hangup));
}

- (void)testMessagesSaveParamsDictionary {
	SVSignalingMessage *signalMessage = [SVSignalingMessage messageWithType:SVSignalingMessageType.answer params:@{@"custom_param":@"param"}];
	
	assertThat(signalMessage.type, equalTo(SVSignalingMessageType.answer));
	assertThat(signalMessage.params, notNilValue());
	
	assertThat(signalMessage.params[@"custom_param"], equalTo(@"param"));
	
}

@end