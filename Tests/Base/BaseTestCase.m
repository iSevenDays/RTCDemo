//
//  BaseTestCase.m
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 2/4/16.
//  Copyright © 2016 anton. All rights reserved.
//

#import "BaseTestCase.h"

@implementation BaseTestCase

///--------------------------------------
#pragma mark - Helpers
///--------------------------------------

- (XCTestExpectation *)currentSelectorTestExpectation {
	NSInvocation *invocation = self.invocation;
	NSString *selectorName = invocation ? NSStringFromSelector(invocation.selector) : @"testExpectation";
	return [self expectationWithDescription:selectorName];
}

- (void)waitForTestExpectations {
	[self waitForExpectationsWithTimeout:10.0 handler:nil];
}

@end