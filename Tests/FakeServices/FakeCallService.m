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
#import "CallServiceDataChannelAdditionsDelegate.h"
#import "CallServiceDelegate.h"

#import <RTCPeerConnectionFactory.h>
#import <RTCPeerConnectionInterface.h>
#import <RTCMediaConstraints.h>
#import <RTCVideoSource.h>
#import "SVSignalingChannelState.h"

@interface FakeCallService()
@property (nonatomic, strong) id<SVSignalingChannelProtocol> signalingChannel;
@end

@implementation FakeCallService

- (void)startCallWithOpponent:(SVUser *)opponent {

	RTCPeerConnectionFactory *factory = [[RTCPeerConnectionFactory alloc] init];
	
	RTCVideoTrack *emptyVideoTrack = [[RTCVideoTrack alloc] initWithFactory:factory source:[RTCVideoSource new] trackId:@"trackID"];
	
	if ([self.multicastDelegate respondsToSelector:@selector(callService:didReceiveLocalVideoTrack:)]) {
		[self.multicastDelegate callService:self didReceiveLocalVideoTrack:emptyVideoTrack];
	}
	
	if ([self.multicastDelegate respondsToSelector:@selector(callService:didReceiveRemoteVideoTrack:)]) {
		[self.multicastDelegate callService:self didReceiveRemoteVideoTrack:emptyVideoTrack];
	}
	
	if ([self.multicastDataChannelDelegate respondsToSelector:@selector(callService:didOpenDataChannel:)]) {
		[self.multicastDataChannelDelegate callService:self didOpenDataChannel:nil];
	}
}

- (BOOL)isInitiator {
	return YES;
}

- (BOOL)isDataChannelReady {
	return YES;
}

- (BOOL)sendText:(NSString *)text {
	return YES;
}

- (BOOL)sendData:(NSData *)data {
	return YES;
}

@end
