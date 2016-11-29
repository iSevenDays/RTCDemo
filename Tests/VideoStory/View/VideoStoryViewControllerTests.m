//
//  VideoStoryViewControllerTests.m
//  RTCDemo
//
//  Created by Anton Sokolchenko on 20/01/2016.
//  Copyright 2016 Anton Sokolchenko. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import <RTCCameraPreviewView.h>

#import "VideoStoryViewController.h"

#import "VideoStoryViewOutput.h"

@interface VideoStoryViewControllerTests : XCTestCase

@property (strong, nonatomic) VideoStoryViewController *controller;

@property (strong, nonatomic) id mockOutput;

@end

@implementation VideoStoryViewControllerTests

#pragma mark - Setup environment for testing

- (void)setUp {
    [super setUp];

	self.controller = [[UIStoryboard storyboardWithName:@"VideoStory" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([VideoStoryViewController class])];

    self.mockOutput = OCMProtocolMock(@protocol(VideoStoryViewOutput));

    self.controller.output = self.mockOutput;
}

- (void)tearDown {
    self.controller = nil;

    self.mockOutput = nil;

    [super tearDown];
}

#pragma mark - Testing life cycle

- (void)testThatViewNotifiesPresenterOnDidLoad {
	// given

	// when
	[self.controller viewDidLoad];

	// then
	OCMVerify([self.mockOutput didTriggerViewReadyEvent]);
}

#pragma mark - IBActions testing

- (void)testStartCallButtonTriggersAction {
	// given
	
	// when
	[self.controller didTapButtonStartCall:nil];
	
	// then
	OCMVerify([self.mockOutput didTriggerStartCallButtonTaped]);
}

- (void)testHangupButtonTriggersAction {
	// given
	
	// when
	[self.controller didTapButtonHangup:nil];
	
	// then
	OCMVerify([self.mockOutput didTriggerHangupButtonTaped]);
}

- (void)testSuccessDataChannelButton_ImageGalleryTriggersAction {
	// given
	
	// when
	[self.controller didTapButtonDataChannelImageGallery:nil];
	
	// then
	OCMVerify([self.mockOutput didTriggerDataChannelButtonTaped]);
}

#pragma mark - Testing methods VideoStoryViewInput

- (void)testSetLocalVideoCaptureSession_setsCaptureSession {
	// given
	[self.controller loadView];
	
	AVCaptureSession *testSession = [[AVCaptureSession alloc] init];
	
	// when
	[self.controller setLocalVideoCaptureSession:testSession];
	
	// then
	OCMVerify([self.controller.viewLocal setCaptureSession:testSession]);
}

@end
