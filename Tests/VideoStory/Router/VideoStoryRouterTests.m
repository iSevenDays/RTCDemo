//
//  VideoStoryRouterTests.m
//  RTCDemo
//
//  Created by Anton Sokolchenko on 20/01/2016.
//  Copyright 2016 Anton Sokolchenko. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "VideoStoryAssembly.h"
#import "VideoStoryRouter.h"
#import <ViperMcFlurry/ViperMcFlurry.h>

@interface VideoStoryRouterTests : XCTestCase

@property (strong, nonatomic) VideoStoryRouter *router;
@property (strong, nonatomic) VideoStoryAssembly *assembly;
@end

@implementation VideoStoryRouterTests

#pragma mark - Setup environment for testing

- (void)setUp {
    [super setUp];

	self.assembly = [VideoStoryAssembly new];
	[self.assembly activate];
	
    self.router = [self.assembly routerVideoStoryModule];
	
}

- (void)tearDown {
    self.router = nil;

    [super tearDown];
}

- (void)testRouterOpensImageGalleryCallsTransitionHandler {
	// given
	id mockTransitionHandler = OCMPartialMock(self.router.transitionHandler);
	// when
	[self.router openImageGallery];
	
	// then
	OCMVerify([mockTransitionHandler openModuleUsingSegue:[OCMArg any]]);
}

@end
