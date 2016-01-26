//
//  FakeCallService.m
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 1/26/16.
//  Copyright © 2016 anton. All rights reserved.
//

#import "FakeCallService.h"

#import "CallServiceProtocol.h"
#import "SVClientDelegate.h"

@implementation FakeCallService


- (instancetype)initWithSignalingChannel:(id<SVSignalingChannelProtocol>)signalingChannel clientDelegate:(id<SVClientDelegate>)clientDelegate {
	self = [super init];
	if (self) {
		
	}
	return self;
}

- (void)connectWithUser:(SVUser *)user completion:(void (^)(NSError * _Nullable))completion {
	if (completion) {
		completion(nil);
	}
}

- (void)startCallWithOpponent:(SVUser *)opponent {
	
}

- (void)hangup {
	
}

- (void)openDataChannel {
	
}

@end
