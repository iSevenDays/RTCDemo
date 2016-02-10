//
//  FakeCallService.m
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 1/26/16.
//  Copyright © 2016 anton. All rights reserved.
//

#import "FakeCallService.h"
#import "FakeSignalingChannel.h"

#import "CallServiceProtocol.h"
#import "CallClientDelegate.h"

#import <RTCPeerConnectionFactory.h>
#import <RTCPeerConnectionInterface.h>
#import <RTCMediaConstraints.h>
#import "SVSignalingChannelState.h"

@interface FakeCallService()
@property (nonatomic, strong) id<SVSignalingChannelProtocol> signalingChannel;
@end

@implementation FakeCallService

- (instancetype)initWithSignalingChannel:(id<SVSignalingChannelProtocol>)signalingChannel clientDelegate:(id<CallClientDelegate>)clientDelegate {
	self = [super init];
	if (self) {
		self.signalingChannel = signalingChannel;
		self.delegate = clientDelegate;
	}
	return self;
}

- (void)connectWithUser:(SVUser *)user completion:(void (^)(NSError * _Nullable))completion {
	[self.signalingChannel connectWithUser:user completion:completion];
}

- (BOOL)hasActiveCall {
	return NO;
}

- (void)startCallWithOpponent:(SVUser *)opponent {

	RTCPeerConnectionFactory *factory = [[RTCPeerConnectionFactory alloc] init];
	
	RTCVideoTrack *emptyVideoTrack = [[RTCVideoTrack alloc] initWithFactory:factory source:nil trackId:@""];
	
	[self.delegate client:self didReceiveLocalVideoTrack:emptyVideoTrack];
	
	[self.delegate client:self didReceiveRemoteVideoTrack:emptyVideoTrack];
}

- (void)hangup {
	
}

- (void)openDataChannel {
	
}

- (BOOL)isConnected {
	return self.signalingChannel.state == SVSignalingChannelState.established;
}

- (BOOL)isConnecting {
	return self.signalingChannel.state == SVSignalingChannelState.open;
}

@end
