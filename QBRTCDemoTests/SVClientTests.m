//
//  SVClientTests.m
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 11/21/15.
//  Copyright © 2015 anton. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCHamcrest/OCHamcrest.h>

#import "QBSignalingChannel.h"
#import "TestsStorage.h"
#import "SVClient.h"


// Using QBSignalingChannel as for now
@interface SVClientTests : XCTestCase

@property (nonatomic, strong) SVClient *client;

@end


@implementation SVClientTests

- (void)setUp {
	
//	QBSignalingChannel *
	
//	self.client = [SVClient alloc] initWithSignalingChannel:<#(nonnull id<SVSignalingChannelProtocol>)#> clientDelegate:<#(nonnull id<SVClientDelegate>)#>
}

- (void)testCorrectStateChange {
	
}

@end