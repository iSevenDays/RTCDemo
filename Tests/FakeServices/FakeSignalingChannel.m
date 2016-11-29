//
//  FakeSignalingChannel.m
//  RTCDemo
//
//  Created by Anton Sokolchenko on 1/28/16.
//  Copyright © 2016 anton. All rights reserved.
//

#import "FakeSignalingChannel.h"
#import "SVSignalingChannelProtocol.h"


@implementation FakeSignalingChannel

@synthesize user = _user;

@synthesize delegate;

- (instancetype)init {
	self = [super init];
	if (self) {
		self.shouldSendMessagesSuccessfully = YES;
	}
	return self;
}

- (void)connectWithUser:(SVUser *)user completion:(void (^)(NSError * _Nullable))completion {
	self.state = SVSignalingChannelState.open;
	
	self.user = user;
	
	self.state = SVSignalingChannelState.established;
	
	if (completion) {
		completion(nil);
	}
}

- (void)notifyDelegateWithCurrentState {
	if (self.delegate) {
		if ([self.delegate respondsToSelector:@selector(channel:didChangeState:)]) {
			[self.delegate channel:self didChangeState:self.state];
		}
	}
}

- (void)setState:(NSString *)state {
	if (![_state isEqualToString:state]) {
		_state = state;
		[self notifyDelegateWithCurrentState];
	}
}


- (BOOL)isConnected {
	return YES;
}

- (void)sendMessage:(__kindof SVSignalingMessage *)message toUser:(SVUser *)user completion:(void (^)(NSError * _Nullable))completion {
	if (completion) {
		if (self.shouldSendMessagesSuccessfully) {
			completion(nil);
		} else {
			completion([[NSError alloc] init]);
		}
		
	}
}

- (void)disconnectWithCompletion:(void (^)(NSError * _Nullable))completion {
	if (completion) {
		completion(nil);
	}
}

@end
