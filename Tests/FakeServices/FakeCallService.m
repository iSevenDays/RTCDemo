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

- (BOOL)hasActiveCall {
	return NO;
}

- (void)startCallWithOpponent:(SVUser *)opponent {

	RTCPeerConnectionFactory *factory = [[RTCPeerConnectionFactory alloc] init];
	
	RTCVideoTrack *emptyVideoTrack = [[RTCVideoTrack alloc] initWithFactory:factory source:nil trackId:@"trackID"];
	
	[self.delegate client:self didReceiveLocalVideoTrack:emptyVideoTrack];
	
	[self.delegate client:self didReceiveRemoteVideoTrack:emptyVideoTrack];
}

@end
