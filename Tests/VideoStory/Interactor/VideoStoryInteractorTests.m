//
//  VideoStoryInteractorTests.m
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 20/01/2016.
//  Copyright 2016 Anton Sokolchenko. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <TyphoonPatcher.h>
#import "FakeCallService.h"

#import "VideoStoryInteractor.h"

#import "VideoStoryInteractorOutput.h"

@interface VideoStoryInteractorTests : XCTestCase

@property (strong, nonatomic) VideoStoryInteractor *interactor;

@property (strong, nonatomic) id mockOutput;

@end

@implementation VideoStoryInteractorTests

#pragma mark - Настройка окружения для тестирования

- (void)setUp {
    [super setUp];
	
    self.interactor = [[VideoStoryInteractor alloc] init];
	
	self.interactor.callService = [FakeCallService new];
	
    self.mockOutput = OCMProtocolMock(@protocol(VideoStoryInteractorOutput));

    self.interactor.output = self.mockOutput;
	
}

- (void)tearDown {
    self.interactor = nil;

    self.mockOutput = nil;

    [super tearDown];
}

#pragma mark - Тестирование методов VideoStoryInteractorInput

- (void)testThatCanConnectWithUser1 {
	// given
	
	// when
	[self.interactor connectToChatWithUser1];
	
	// then
	OCMVerify([self.mockOutput didConnectToChatWithUser1]);
}

- (void)testThatCanConnectWithUser2 {
	// given
	
	// when
	[self.interactor connectToChatWithUser2];
	
	// then
	OCMVerify([self.mockOutput didConnectToChatWithUser2]);
}

@end