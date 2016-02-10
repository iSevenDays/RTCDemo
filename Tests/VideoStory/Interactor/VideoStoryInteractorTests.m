//
//  VideoStoryInteractorTests.m
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 20/01/2016.
//  Copyright 2016 Anton Sokolchenko. All rights reserved.
//

#import "BaseTestCase.h"
#import <OCMock/OCMock.h>
#import <OCMStubRecorder.h>
#import <TyphoonPatcher.h>
#import "CallService.h"

#import "FakeCallService.h"
#import "FakeSignalingChannel.h"

#import "VideoStoryInteractor.h"

#import "VideoStoryInteractorOutput.h"

@interface CallService()

@property (nonatomic, assign, readwrite) CallClientState state;

@end

@interface VideoStoryInteractorTests : BaseTestCase

@property (strong, nonatomic) VideoStoryInteractor *interactor;

@property (strong, nonatomic) id mockOutput;

@end

@implementation VideoStoryInteractorTests

#pragma mark - Настройка окружения для тестирования

- (void)setUp {
    [super setUp];
	
    self.interactor = [[VideoStoryInteractor alloc] init];
	
    self.mockOutput = OCMProtocolMock(@protocol(VideoStoryInteractorOutput));
	
    self.interactor.output = self.mockOutput;
	
}

// Use when using real CallService is not possible
- (void)useFakeCallService {
	if ([self.interactor.callService isKindOfClass:[FakeCallService class]]) {
		return; // already set
	}
	self.interactor.callService = [[FakeCallService alloc] initWithSignalingChannel:[FakeSignalingChannel new] clientDelegate:self.interactor];
}

- (void)useRealCallService {
	if ([self.interactor.callService isKindOfClass:[CallService class]]) {
		return; // already set
	}
	self.interactor.callService = [[CallService alloc] initWithSignalingChannel:[FakeSignalingChannel new] clientDelegate:self.interactor];
}

- (void)tearDown {
    self.interactor = nil;

    self.mockOutput = nil;

    [super tearDown];
}

#pragma mark - Тестирование методов VideoStoryInteractorInput

- (void)testConnectingWithUser1 {
	// given
	[self useRealCallService];
	// when
	[self.interactor connectToChatWithUser1];
	
	// then
	OCMVerify([self.mockOutput didConnectToChatWithUser1]);
}

- (void)testConnectingWithUser2 {
	// given
	[self useRealCallService];
	// when
	[self.interactor connectToChatWithUser2];
	
	// then
	OCMVerify([self.mockOutput didConnectToChatWithUser2]);
}

- (void)testHangup {
	// given
	[self useRealCallService];
	
	((CallService *) self.interactor.callService).state = kClientStateConnected;
	
	// when
	[self.interactor hangup];
	
	// then
	OCMVerify([self.mockOutput didHangup]);
}

- (void)testSuccessfulSetLocalCaptureSession {
	// given
	[self useRealCallService];
	
	id mockedInteractor = OCMPartialMock(self.interactor);
	
	OCMStub([mockedInteractor client:[OCMArg any] didReceiveLocalVideoTrack:[OCMArg any]]).andCall(self.interactor.output, @selector(didSetLocalCaptureSession:));
	
	OCMExpect([self.mockOutput didSetLocalCaptureSession:[OCMArg any]]);
	
	// when
	[mockedInteractor connectToChatWithUser1];
	[mockedInteractor startCall];
	
	// then
	OCMVerifyAllWithDelay(self.mockOutput, 10);
}

- (void)testReceiveRemoteVideoTrack_whenConnectedAndStartedCall {
	// given
	[self useFakeCallService];
	
	// when
	[self.interactor connectToChatWithUser1];
	[self.interactor startCall];
	
	// then
	OCMVerify([self.mockOutput didReceiveRemoteVideoTrackWithConfigurationBlock:[OCMArg any]]);
}


@end