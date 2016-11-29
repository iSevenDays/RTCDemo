//
//  VideoStoryPresenterTests.m
//  RTCDemo
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
#import "TestsStorage.h"

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

- (void)testThatPresenterHandlesStartCallWithUserEventFromModuleInput {
	// given
	SVUser *testUser = [TestsStorage svuserRealUser1];
	SVUser *testUser2 = [TestsStorage svuserRealUser2];
	
	// when
	[self.presenter connectToChatWithUser:testUser callOpponent:testUser2];
	
	// then
	OCMVerify([self.mockInteractor connectToChatWithUser:testUser callOpponent:testUser2]);
}

#pragma mark - Testing methods VideoStoryViewOutput

- (void)testThatPresenterHandlesViewReadyEvent {
    // when
    [self.presenter didTriggerViewReadyEvent];

    // then
    OCMVerify([self.mockView setupInitialState]);
}

- (void)testThatPresenterHandlesStartCallButtonTapped {
	// when
	[self.presenter didTriggerStartCallButtonTaped];
	
	// then
	OCMVerify([self.mockInteractor startCallWithOpponent:nil]);
}

- (void)testThatPresenterHandlesHangupButtonTapped {
	// when
	[self.presenter didTriggerHangupButtonTaped];
	
	// then
	OCMVerify([self.mockInteractor hangup]);
}

- (void)testThatPresenterHandlesDataChannelButtonTapped_and {
	// when
	[self.presenter didTriggerDataChannelButtonTaped];
	
	// then
	OCMVerify([self.mockInteractor sendInvitationMessageAndOpenImageGallery]);
}


#pragma mark - Testing methods VideoStoryInteractorOutput

- (void)testThatPresenterHandlesDidConnectToChatWithTestUser {
	// given
	SVUser *testUser = [TestsStorage svuserTest];
	
	// when
	[self.presenter didConnectToChatWithUser:testUser];
	
	// then
	OCMVerify([self.mockView configureViewWithUser:testUser]);
}

- (void)testThatPresenterHandlesConnectionError {
	// when
	[self.presenter didFailToConnectToChat];
	
	// then
	OCMVerify([self.mockView showErrorConnect]);
}

- (void)testThatPresenterHandlesLocalVideoTrack {
	// when
	[self.presenter didSetLocalCaptureSession:[OCMArg any]];
	
	// then
	OCMVerify([self.mockView setLocalVideoCaptureSession:[OCMArg any]]);
}

- (void)testThatPresenterHandlesRemoteVideoTrack {
	// when
	[self.presenter didReceiveRemoteVideoTrackWithConfigurationBlock:nil];
	
	// then
	OCMVerify([self.mockView configureRemoteVideoViewWithBlock:nil]);
}

- (void)testPresenterHandlesDataChannelNotReadyState {
	// when
	[self.presenter didReceiveDataChannelStateNotReady];
	
	// then
	OCMVerify([self.mockView showErrorDataChannelNotReady]);
}

- (void)testPresenterHandlesIncomingDataChannelInvitationToOpenImageGallery_andOpensImageGallery {
	// when
	[self.presenter didReceiveInvitationToOpenImageGallery];
	
	// then
	OCMVerify([self.mockRouter openImageGallery]);
}

- (void)testPresenterHandlesOutgoingDataChannelInvitationToOpenImageGallery_andOpensImageGallery {
	// when
	[self.presenter didSendInvitationToOpenImageGallery];
	
	// then
	OCMVerify([self.mockRouter openImageGallery]);
}



@end
