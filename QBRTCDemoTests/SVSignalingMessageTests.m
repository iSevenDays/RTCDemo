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
#import "SVSignalingMessageICE.h"
#import "SVSignalingMessageSDP.h"


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

- (void)testMessagesSaveParamsDictionary {
	SVSignalingMessage *signalMessage = [SVSignalingMessage messageWithType:SVSignalingMessageType.answer params:@{@"custom_param":@"param"}];
	
	assertThat(signalMessage.type, equalTo(SVSignalingMessageType.answer));
	assertThat(signalMessage.params, notNilValue());
	
	assertThat(signalMessage.params[@"custom_param"], equalTo(@"param"));
	
}

@end