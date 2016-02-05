//
//  BaseTestCase.h
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 2/4/16.
//  Copyright © 2016 anton. All rights reserved.
//


#import <XCTest/XCTest.h>

@interface BaseTestCase : XCTestCase

///--------------------------------------
#pragma mark - XCTestCase
///--------------------------------------


///--------------------------------------
#pragma mark - Expectations
///--------------------------------------

- (XCTestExpectation *)currentSelectorTestExpectation;
- (void)waitForTestExpectations;

@end
