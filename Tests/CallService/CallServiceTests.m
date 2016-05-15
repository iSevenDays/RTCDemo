//
//  CallServiceTests.m
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 2/9/16.
//  Copyright © 2016 anton. All rights reserved.
//

#import "BaseTestCase.h"
#import <OCMock.h>

#import <RTCICECandidate.h>
#import <RTCSessionDescription.h>
#import <RTCPeerConnection.h>

#import "CallService.h"
#import "CallService_Private.h"
#import "CallServiceHelpers.h"

#import "CallServiceDelegate.h"
#import "FakeSignalingChannel.h"

#import "SVSignalingMessage.h"
#import "SVSignalingMessageSDP.h"
#import "SVSignalingMessageICE.h"
#import "SVSignalingParams.h"

@interface CallServiceTests : BaseTestCase

@property (nonatomic, strong) CallService<SVSignalingChannelDelegate, CallServiceProtocol, CallServiceDataChannelAdditionsProtocol> *callService;
@property (nonatomic, strong) id mockOutput;
@property (nonatomic, strong) id mockCallService;

@property (nonatomic, strong) SVUser *user1;
@property (nonatomic, strong) SVUser *user2;
@property (nonatomic, strong) SVUser *user3;
@property (nonatomic, strong) FakeSignalingChannel *signalingChannel;

@end

@implementation CallServiceTests

- (void)setUp {
	[super setUp];
	self.user1 = [CallServiceHelpers user1];
	self.user2 = [CallServiceHelpers user2];
	self.user3 = [[SVUser alloc] initWithID:@1 login:@"login" password:@""];
	
	self.mockOutput = OCMProtocolMock(@protocol(CallServiceDelegate));
	self.signalingChannel = [FakeSignalingChannel new];
	
	self.callService = [[CallService alloc] initWithSignalingChannel:self.signalingChannel callServiceDelegate:self.mockOutput];
	
	self.mockCallService = OCMPartialMock(self.callService);
}

- (void)tearDown {
	[self.callService hangup];
	self.callService = nil;
	self.mockCallService = nil;
	self.mockOutput = nil;
}

- (void)testCanConnectWithUserAndHaveConnectedState {
	// given
	XCTestExpectation *expectation = [self currentSelectorTestExpectation];
	// when
	[self.callService connectWithUser:self.user1 completion:^(NSError * _Nullable error) {
		XCTAssertNil(error);
		XCTAssertEqual(self.callService.state, kClientStateConnected);
		[expectation fulfill];
	}];
	
	// then
	[self waitForTestExpectations];
}

#pragma mark CallClientDelegate tests

- (void)testHasLocalVideoTrackAfterStartCall {
	// given
	
	// when
	[self.callService connectWithUser:self.user1 completion:nil];
	
	[self.callService startCallWithOpponent:self.user2];

	// then
	OCMVerify([self.mockOutput callService:[OCMArg any] didReceiveLocalVideoTrack:[OCMArg any]]);
}

- (void)testCorrectlyChangesClientStateToConnected {
	// given
	
	// when
	[self.callService connectWithUser:self.user1 completion:nil];
	
	// then
	OCMVerify([self.mockOutput callService:[OCMArg any] didChangeState:kClientStateConnected]);
}

- (void)testCorrectlyChangesClientStateToDisconnectedAfterDisconnectFromChat {
	// given
	
	// when
	[self.callService connectWithUser:self.user1 completion:nil];
	[self.callService disconnectWithCompletion:nil];
	
	// then
	OCMVerify([self.mockOutput callService:[OCMArg any] didChangeState:kClientStateDisconnected]);
}

- (void)testStaysConnectedAfterHangup {
	// given
	
	// when
	[self.callService connectWithUser:self.user1 completion:nil];
	[self.callService hangup];

	// then
	OCMVerify([self.mockOutput callService:[OCMArg any] didChangeState:kClientStateConnected]);
}

- (void)testSendsRejectIfAlreadyHasActiveCall {
	// given
	[[self.mockCallService reject] peerConnection:[OCMArg any] didSetSessionDescriptionWithError:[OCMArg isNotNil]];
	
	RTCSessionDescription *rtcofferSDP = [[RTCSessionDescription alloc] initWithType:SVSignalingMessageType.offer sdp:[CallServiceHelpers offerSDP]];
	SVSignalingMessage *offer = [[SVSignalingMessageSDP alloc] initWithSessionDescription:rtcofferSDP];
	offer.sender = self.user3;
	
	OCMExpect([self.mockCallService sendRejectToUser:self.user3 completion:[OCMArg any]]);
	
	// when
	[self.callService connectWithUser:self.user1 completion:nil];
	[self.callService startCallWithOpponent:self.user2];
	
	[self.callService channel:self.callService.signalingChannel didReceiveMessage:offer];
	
	// then
	OCMVerifyAll(self.mockCallService);
}

#pragma mark Signaling messages processing

- (void)testCorrectlyProcessesHangupSignalingMessage {
	// given
	[[self.mockCallService reject] peerConnection:[OCMArg any] didSetSessionDescriptionWithError:[OCMArg isNotNil]];
	
	SVSignalingMessage *hangup = [SVSignalingMessage messageWithType:SVSignalingMessageType.hangup params:nil];
	
	// when
	[self.callService connectWithUser:self.user1 completion:nil];
	[self.callService startCallWithOpponent:self.user2];
	
	[self.callService processSignalingMessage:hangup];
	
	// then
	OCMVerify([self.mockCallService clearSession]);
}

- (void)testCorrectlyProcessesSignalingMessageIceWithAudioAndVideoFromOpponent {
	// given
	[[self.mockCallService reject] peerConnection:[OCMArg any] didSetSessionDescriptionWithError:[OCMArg isNotNil]];
	
	RTCICECandidate *rtcIceCandidateAudio = [[RTCICECandidate alloc] initWithMid:@"audio" index:0 sdp:@"candidate:1009584571 1 udp 2122260223 192.168.8.197 58130 typ host generation 0 ufrag 0+C/nsdLdjk3x5eG"];
	
	RTCICECandidate *rtcIceCandidateVideo = [[RTCICECandidate alloc] initWithMid:@"video" index:1 sdp:@"candidate:1009584571 1 udp 2122260223 192.168.8.197 62216 typ host generation 0 ufrag 0+C/nsdLdjk3x5eG"];
	
	SVSignalingMessage *iceAudio = [[SVSignalingMessageICE alloc] initWithICECandidate:rtcIceCandidateAudio];
	SVSignalingMessage *iceVideo = [[SVSignalingMessageICE alloc] initWithICECandidate:rtcIceCandidateVideo];
	
	iceAudio.sender = self.user2;
	iceVideo.sender = self.user2;
	
	OCMExpect([self.mockCallService drainMessageQueueIfReady]);
	
	// when
	[self.callService connectWithUser:self.user1 completion:nil];
	[self.callService startCallWithOpponent:self.user2];
	
	[self.callService channel:self.callService.signalingChannel didReceiveMessage:iceAudio];
	[self.callService channel:self.callService.signalingChannel didReceiveMessage:iceVideo];
	
	// then
	OCMVerifyAll(self.mockCallService);
}

- (void)testCorrectlyProcessesSignalingMessageOfferFromOpponent_andSavesCallRequest {
	// given
	[[self.mockCallService reject] peerConnection:[OCMArg any] didSetSessionDescriptionWithError:[OCMArg isNotNil]];
	[[self.mockCallService reject] processSignalingMessage:[OCMArg any]]; // we shouldn't accept call immediately
	
	RTCSessionDescription *rtcofferSDP = [[RTCSessionDescription alloc] initWithType:SVSignalingMessageType.offer sdp:[CallServiceHelpers offerSDP]];
	
	SVSignalingMessage *offerSDP = [[SVSignalingMessageSDP alloc] initWithSessionDescription:rtcofferSDP];
	
	offerSDP.sender = self.user2;
	
	OCMExpect([[self.mockCallService peerConnection] createAnswerWithDelegate:[OCMArg any] constraints:[OCMArg any]]);
	
	// when
	[self.callService connectWithUser:self.user1 completion:nil];
	
	[self.callService channel:self.callService.signalingChannel didReceiveMessage:offerSDP];
	
	// then
	[self.mockOutput callService:self.callService didReceiveCallRequestFromOpponent:offerSDP.sender];
	
	OCMVerifyAll(self.mockCallService);
}

- (void)testCorrectlyAcceptsSavedCallRequest {
	// given
	[[self.mockCallService reject] peerConnection:[OCMArg any] didSetSessionDescriptionWithError:[OCMArg isNotNil]];
	
	RTCSessionDescription *rtcofferSDP = [[RTCSessionDescription alloc] initWithType:SVSignalingMessageType.offer sdp:[CallServiceHelpers offerSDP]];
	
	SVSignalingMessage *offerSDP = [[SVSignalingMessageSDP alloc] initWithSessionDescription:rtcofferSDP];
	
	offerSDP.sender = self.user2;
	
	OCMExpect([[self.mockCallService peerConnection] createAnswerWithDelegate:[OCMArg any] constraints:[OCMArg any]]);
	
	// when
	[self.callService connectWithUser:self.user1 completion:nil];
	
	[self.callService channel:self.callService.signalingChannel didReceiveMessage:offerSDP];
	
	[self.callService acceptCallFromOpponent:offerSDP.sender];
	
	
	// then
	OCMVerify([self.mockCallService processSignalingMessage:offerSDP]);
	
	OCMVerifyAll(self.mockCallService);
}

- (void)testCorrectlyProcessesSignalingMessageOfferFromOpponent_andThenHisIceCandidates {
	// given
	[[self.mockCallService reject] peerConnection:[OCMArg any] didSetSessionDescriptionWithError:[OCMArg isNotNil]];
	
	RTCSessionDescription *rtcofferSDP = [[RTCSessionDescription alloc] initWithType:SVSignalingMessageType.offer sdp:[CallServiceHelpers offerSDP]];
	
	SVSignalingMessage *offerSDP = [[SVSignalingMessageSDP alloc] initWithSessionDescription:rtcofferSDP];
	
	offerSDP.sender = self.user2;
	
	RTCICECandidate *rtcIceCandidateAudio = [[RTCICECandidate alloc] initWithMid:@"audio" index:0 sdp:@"candidate:1009584571 1 udp 2122260223 192.168.8.197 58130 typ host generation 0 ufrag 0+C/nsdLdjk3x5eG"];
	
	RTCICECandidate *rtcIceCandidateVideo = [[RTCICECandidate alloc] initWithMid:@"video" index:1 sdp:@"candidate:1009584571 1 udp 2122260223 192.168.8.197 62216 typ host generation 0 ufrag 0+C/nsdLdjk3x5eG"];
	
	SVSignalingMessage *iceAudio = [[SVSignalingMessageICE alloc] initWithICECandidate:rtcIceCandidateAudio];
	SVSignalingMessage *iceVideo = [[SVSignalingMessageICE alloc] initWithICECandidate:rtcIceCandidateVideo];
	
	iceAudio.sender = self.user2;
	iceVideo.sender = self.user2;
	
	OCMExpect([[self.mockCallService peerConnection] createAnswerWithDelegate:[OCMArg any] constraints:[OCMArg any]]);
	
	// when
	[self.callService connectWithUser:self.user1 completion:nil];
	
	[self.callService channel:self.callService.signalingChannel didReceiveMessage:offerSDP];
	
	[self.callService acceptCallFromOpponent:offerSDP.sender];
	
	[self.callService channel:self.callService.signalingChannel didReceiveMessage:iceAudio];
	[self.callService channel:self.callService.signalingChannel didReceiveMessage:iceVideo];
	
	// then
	OCMVerify([self.mockCallService processSignalingMessage:offerSDP]);
	OCMVerify([self.mockCallService processSignalingMessage:iceAudio]);
	OCMVerify([self.mockCallService processSignalingMessage:iceVideo]);
	
	OCMVerifyAll(self.mockCallService);
}

- (void)testCallsDidError_onFailedSignalingMessage {
	// given
	self.signalingChannel.shouldSendMessagesSuccessfully = NO;
	
	// when
	[self.callService sendSignalingMessage:[SVSignalingMessage messageWithType:SVSignalingMessageType.offer params:nil]];
	
	// then
	OCMVerify([self.mockOutput callService:self.callService didError:[OCMArg any]]);
}

@end