//
//  VideoCallStoryViewControllerTests.m
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 01/12/2016.
//  Copyright 2016 Anton Sokolchenko. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "VideoCallStoryViewController.h"

#import "VideoCallStoryViewOutput.h"

@interface VideoCallStoryViewControllerTests : XCTestCase

@property (strong, nonatomic) VideoCallStoryViewController *controller;

@property (strong, nonatomic) id mockOutput;

@end

@implementation VideoCallStoryViewControllerTests

#pragma mark - Настройка окружения для тестирования

- (void)setUp {
    [super setUp];

    self.controller = [[VideoCallStoryViewController alloc] init];

    self.mockOutput = OCMProtocolMock(@protocol(VideoCallStoryViewOutput));

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

#pragma mark - Тестирование методов VideoCallStoryViewInput

@end