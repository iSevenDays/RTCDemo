//
//  FakeSignalingChannel.m
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 1/28/16.
//  Copyright © 2016 anton. All rights reserved.
//

#import "FakeSignalingChannel.h"
#import "SVSignalingChannelProtocol.h"

@implementation FakeSignalingChannel

- (void)connectWithUser:(SVUser *)user completion:(void (^)(NSError * _Nullable))completion {
	self.state = SVSignalingChannelState.open;
	
	if (completion) {
		self.state = SVSignalingChannelState.established;
		completion(nil);
	}
}

- (BOOL)isConnected {
	return YES;
}

- (void)sendMessage:(__kindof SVSignalingMessage *)message toUser:(SVUser *)user completion:(void (^)(NSError * _Nullable))completion {
	if (completion) {
		completion(nil);
	}
}

- (void)disconnectWithCompletion:(void (^)(NSError * _Nullable))completion {
	if (completion) {
		completion(nil);
	}
}

@end
