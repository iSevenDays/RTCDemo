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

#pragma mark - Тестирование методов VideoStoryModuleInput

#pragma mark - Тестирование методов VideoStoryViewOutput

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


#pragma mark - Тестирование методов VideoStoryInteractorOutput

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

- (void)testThatPresenterHandlesErrors {
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

@end