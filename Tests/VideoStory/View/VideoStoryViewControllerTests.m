//
//  VideoStoryViewControllerTests.m
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 20/01/2016.
//  Copyright 2016 Anton Sokolchenko. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "VideoStoryViewController.h"

#import "VideoStoryViewOutput.h"

@interface VideoStoryViewControllerTests : XCTestCase

@property (strong, nonatomic) VideoStoryViewController *controller;

@property (strong, nonatomic) id mockOutput;

@end

@implementation VideoStoryViewControllerTests

#pragma mark - Настройка окружения для тестирования

- (void)setUp {
    [super setUp];

    self.controller = [[VideoStoryViewController alloc] init];

    self.mockOutput = OCMProtocolMock(@protocol(VideoStoryViewOutput));

    self.controller.output = self.mockOutput;
}

- (void)tearDown {
    self.controller = nil;

    self.mockOutput = nil;

    [super tearDown];
}

#pragma mark - Тестирование жизненного цикла

- (void)testThatViewNotifiesPresenterOnDidLoad {
	// given

	// when
	[self.controller viewDidLoad];

	// then
	OCMVerify([self.mockOutput didTriggerViewReadyEvent]);
}

#pragma mark - Тестирование методов интерфейса

- (void)testSuccessDidTapConnectToChatWithUser1Button {
	// given
	
	// when
	[self.controller didTapButtonConnectWithUser1:nil];
	
	// then
	OCMVerify([self.mockOutput didTriggerConnectWithUser1ButtonTaped]);
}

- (void)testSuccessDidTapConnectToChatWithUser2Button {
	// given
	
	// when
	[self.controller didTapButtonConnectWithUser2:nil];
	
	// then
	OCMVerify([self.mockOutput didTriggerConnectWithUser2ButtonTaped]);
}

- (void)testSuccessDidTapStartCallButton {
	// given
	
	// when
	[self.controller didTapButtonStartCall:nil];
	
	// then
	OCMVerify([self.mockOutput didTriggerStartCallButtonTaped]);
}

- (void)testSuccessDidTapHangupButton {
	// given
	
	// when
	[self.controller didTapButtonHangup:nil];
	
	// then
	OCMVerify([self.mockOutput didTriggerHangupButtonTaped]);
}

#pragma mark - Тестирование методов VideoStoryViewInput

@end