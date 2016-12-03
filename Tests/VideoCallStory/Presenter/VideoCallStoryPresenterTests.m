//
//  VideoCallStoryPresenterTests.m
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 01/12/2016.
//  Copyright 2016 Anton Sokolchenko. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "VideoCallStoryPresenter.h"

#import "VideoCallStoryViewInput.h"
#import "VideoCallStoryInteractorInput.h"
#import "VideoCallStoryRouterInput.h"

@interface VideoCallStoryPresenterTests : XCTestCase

@property (strong, nonatomic) VideoCallStoryPresenter *presenter;

@property (strong, nonatomic) id mockInteractor;
@property (strong, nonatomic) id mockRouter;
@property (strong, nonatomic) id mockView;

@end

@implementation VideoCallStoryPresenterTests

#pragma mark - Настройка окружения для тестирования

- (void)setUp {
    [super setUp];

    self.presenter = [[VideoCallStoryPresenter alloc] init];

    self.mockInteractor = OCMProtocolMock(@protocol(VideoCallStoryInteractorInput));
    self.mockRouter = OCMProtocolMock(@protocol(VideoCallStoryRouterInput));
    self.mockView = OCMProtocolMock(@protocol(VideoCallStoryViewInput));

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

#pragma mark - Тестирование методов VideoCallStoryModuleInput

#pragma mark - Тестирование методов VideoCallStoryViewOutput

- (void)testThatPresenterHandlesViewReadyEvent {
    // given


    // when
    [self.presenter didTriggerViewReadyEvent];

    // then
    OCMVerify([self.mockView setupInitialState]);
}

#pragma mark - Тестирование методов VideoCallStoryInteractorOutput

@end