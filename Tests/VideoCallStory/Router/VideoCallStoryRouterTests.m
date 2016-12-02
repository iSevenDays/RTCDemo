//
//  VideoCallStoryRouterTests.m
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 01/12/2016.
//  Copyright 2016 Anton Sokolchenko. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "VideoCallStoryRouter.h"

@interface VideoCallStoryRouterTests : XCTestCase

@property (strong, nonatomic) VideoCallStoryRouter *router;

@end

@implementation VideoCallStoryRouterTests

#pragma mark - Настройка окружения для тестирования

- (void)setUp {
    [super setUp];

    self.router = [[VideoCallStoryRouter alloc] init];
}

- (void)tearDown {
    self.router = nil;

    [super tearDown];
}

@end