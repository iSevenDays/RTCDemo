//
//  VideoStoryPresenterTests.m
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 20/01/2016.
//  Copyright 2016 Anton Sokolchenko. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "VideoStoryPresenter.h"

#import "VideoStoryViewInput.h"
#import "VideoStoryInteractorInput.h"
#import "VideoStoryRouterInput.h"

@interface VideoStoryPresenterTests : XCTestCase

@property (strong, nonatomic) VideoStoryPresenter *presenter;

@property (strong, nonatomic) id mockInteractor;
@property (strong, nonatomic) id mockRouter;
@property (strong, nonatomic) id mockView;

@end

@implementation VideoStoryPresenterTests

#pragma mark - Настройка окружения для тестирования

- (void)setUp {
    [super setUp];

    self.presenter = [[VideoStoryPresenter alloc] init];

    self.mockInteractor = OCMProtocolMock(@protocol(VideoStoryInteractorInput));
    self.mockRouter = OCMProtocolMock(@protocol(VideoStoryRouterInput));
    self.mockView = OCMProtocolMock(@protocol(VideoStoryViewInput));

    self.presenter.interactor = self.mockInteractor;
    self.presenter.router = self.mockRouter;
    self.presenter.view = self.mockView;
}

- (void)tearDown {
    self.presenter = nil;

    self.mockView = nil;
    self.mockRouter = nil;
    self.mockInteractor = nil;

    [super tearDown];
}

#pragma mark - Testing methods VideoStoryModuleInput

#pragma mark - Testing methods VideoStoryViewOutput

- (void)testThatPresenterHandlesViewReadyEvent {
    // given

    // when
    [self.presenter didTriggerViewReadyEvent];

    // then
    OCMVerify([self.mockView setupInitialState]);
}

- (void)testThatPresenterHandlesConnectWitUser1ButtonTapped {
	// given
	
	// when
	[self.presenter didTriggerConnectWithUser1ButtonTaped];
	
	// then
	OCMVerify([self.mockInteractor connectToChatWithUser1]);
}

- (void)testThatPresenterHandlesConnectWitUser2ButtonTapped {
	// given
	
	// when
	[self.presenter didTriggerConnectWithUser2ButtonTaped];
	
	// then
	OCMVerify([self.mockInteractor connectToChatWithUser2]);
}

- (void)testThatPresenterHandlesStartCallButtonTapped {
	// given
	
	// when
	[self.presenter didTriggerStartCallButtonTaped];
	
	// then
	OCMVerify([self.mockInteractor startCall]);
}

- (void)testThatPresenterHandlesHangupButtonTapped {
	// given
	
	// when
	[self.presenter didTriggerHangupButtonTaped];
	
	// then
	OCMVerify([self.mockInteractor hangup]);
}

- (void)testThatPresenterHandlesDataChannelButtonTapped_and {
	// given
	
	// when
	[self.presenter didTriggerDataChannelButtonTaped];
	
	// then
	OCMVerify([self.mockInteractor requestDataChannelState]);
}


#pragma mark - Testing methods VideoStoryInteractorOutput

- (void)testThatPresenterHandlesDidConnectToChatWithUser1 {
	// given
	
	// when
	[self.presenter didConnectToChatWithUser1];
	
	// then
	OCMVerify([self.mockView configureViewWithUser1]);
}

- (void)testThatPresenterHandlesDidConnectToChatWithUser2 {
	// given
	
	// when
	[self.presenter didConnectToChatWithUser2];
	
	// then
	OCMVerify([self.mockView configureViewWithUser2]);
}

- (void)testThatPresenterHandlesConnectionError {
	// given
	
	// when
	[self.presenter didFailToConnectToChat];
	
	// then
	OCMVerify([self.mockView showErrorConnect]);
}

- (void)testThatPresenterHandlesLocalVideoTrack {
	// given
	
	// when
	[self.presenter didSetLocalCaptureSession:[OCMArg any]];
	
	// then
	OCMVerify([self.mockView setLocalVideoCaptureSession:[OCMArg any]]);
}

- (void)testThatPresenterHandlesRemoteVideoTrack {
	// given
	
	// when
	[self.presenter didReceiveRemoteVideoTrackWithConfigurationBlock:nil];
	
	// then
	OCMVerify([self.mockView configureRemoteVideoViewWithBlock:nil]);
}

- (void)testPresenterHandlesDataChannelNotReadyState {
	// given
	
	// when
	[self.presenter didReceiveDataChannelStateNotReady];
	
	// then
	OCMVerify([self.mockView showErrorDataChannelNotReady]);
}

- (void)testPresenterHandlesDataChannelReadyState_andOpensImageGallery {
	// given
	
	// when
	[self.presenter didReceiveDataChannelStateReady];
	
	// then
	OCMVerify([self.mockRouter openImageGallery]);
}

@end