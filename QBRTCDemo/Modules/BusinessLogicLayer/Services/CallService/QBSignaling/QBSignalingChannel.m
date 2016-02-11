//
//  QBSignalingChannel.m
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 11/16/15.
//  Copyright © 2015 anton. All rights reserved.
//

#import "QBSignalingChannel.h"
#import "QBChatMessage+SVSignalingMessage.h"
#import "SVSignalingMessage+QBChatMessage.h"

@interface QBSignalingChannel() <QBChatDelegate>

@end

@implementation QBSignalingChannel
@synthesize state = _state;
@synthesize delegate;
@synthesize user;

- (instancetype)init {
	self = [super init];
	if (self) {
		self.state = SVSignalingChannelState.closed;
		[[QBChat instance] addDelegate:self];
	}
	return self;
}

- (void)connectWithUser:(SVUser *)svuser completion:(void (^)(NSError *error))completion {
	NSCAssert(self.state == SVSignalingChannelState.error || SVSignalingChannelState.closed, @"Invalid channel state");
	
	self.state = SVSignalingChannelState.open;
	
	[[QBChat instance] connectWithUser:[QBUUser userWithSVUser:svuser] completion:^(NSError *error) {
		if (error) {
			self.state = SVSignalingChannelState.error;
		} else {
			[QBChat instance].currentUser.password = svuser.password;
			self.state = SVSignalingChannelState.established;
		}
		
		[self notifyDelegateWithCurrentState];
		
		if (completion) {
			completion(error);
		}
	}];
}

- (void)sendMessage:(SVSignalingMessage *)message toUser:(SVUser *)svuser completion:(void (^)(NSError *error))completion {
	NSParameterAssert(svuser);
	NSCAssert([self.state isEqualToString:SVSignalingChannelState.established], @"Connection is not established");
	
	message.sender = self.user;
	
	QBChatMessage *signalMessage = [QBChatMessage messageWithSVSignalingMessage:message];
	signalMessage.recipientID = svuser.ID.unsignedIntegerValue;
	
	[[QBChat instance] sendSystemMessage:signalMessage completion:completion];
}

- (BOOL)isConnected {
	return [[QBChat instance] isConnected];
}

- (SVUser *)user {
	QBUUser *currentUser = [[QBChat instance] currentUser];
	if (currentUser) {
		return [SVUser userWithID:@(currentUser.ID) login:currentUser.login password:currentUser.password];
	}
	return nil;
}

- (void)disconnectWithCompletion:(void (^)(NSError * _Nullable))completion {
	[[QBChat instance] disconnectWithCompletionBlock:^(NSError * _Nullable error) {
		if (!error) {
			self.state = SVSignalingChannelState.closed;
			
			[[QBChat instance] removeDelegate:self];
		} else {
			self.state = SVSignalingChannelState.error;
		}
		
		if (completion) {
			completion(error);
		}
	}];
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

#pragma mark QBChatDelegate methods

- (void)chatDidAccidentallyDisconnect {
	self.state = SVSignalingChannelState.closed;
}

- (void)chatDidFailWithStreamError:(NSError *)error {
	self.state = SVSignalingChannelState.error;
}

- (void)chatDidNotConnectWithError:(NSError *)error {
	self.state = SVSignalingChannelState.error;
}

- (void)chatDidReceiveSystemMessage:(QBChatMessage *)message {
	NSString *type = message.text;
	
	if ([type isEqualToString:SVSignalingMessageType.answer] ||
		[type isEqualToString:SVSignalingMessageType.offer] ||
		[type isEqualToString:SVSignalingMessageType.hangup] ||
		[type isEqualToString:SVSignalingMessageType.candidate]) {
		[self.delegate channel:self didReceiveMessage:[SVSignalingMessage messageWithQBChatMessage:message]];
	}
}


@end