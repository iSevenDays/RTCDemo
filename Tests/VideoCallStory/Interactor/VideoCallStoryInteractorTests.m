//
//  VideoCallStoryInteractorTests.m
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 01/12/2016.
//  Copyright 2016 Anton Sokolchenko. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "VideoCallStoryInteractor.h"

#import "VideoCallStoryInteractorOutput.h"

@interface VideoCallStoryInteractorTests : XCTestCase

@property (strong, nonatomic) VideoCallStoryInteractor *interactor;

@property (strong, nonatomic) id mockOutput;

@end

@implementation VideoCallStoryInteractorTests

#pragma mark - Настройка окружения для тестирования

- (void)setUp {
    [super setUp];

    self.interactor = [[VideoCallStoryInteractor alloc] init];

    self.mockOutput = OCMProtocolMock(@protocol(VideoCallStoryInteractorOutput));

    self.interactor.output = self.mockOutput;
}

- (void)tearDown {
    self.interactor = nil;

    self.mockOutput = nil;

    [super tearDown];
}

#pragma mark - Тестирование методов VideoCallStoryInteractorInput

@end