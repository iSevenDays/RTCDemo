//
//  VideoStoryRouterTests.m
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 20/01/2016.
//  Copyright 2016 Anton Sokolchenko. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "VideoStoryRouter.h"

@interface VideoStoryRouterTests : XCTestCase

@property (strong, nonatomic) VideoStoryRouter *router;

@end

@implementation VideoStoryRouterTests

#pragma mark - Настройка окружения для тестирования

- (void)setUp {
    [super setUp];

    self.router = [[VideoStoryRouter alloc] init];
}

- (void)tearDown {
    self.router = nil;

    [super tearDown];
}

@end