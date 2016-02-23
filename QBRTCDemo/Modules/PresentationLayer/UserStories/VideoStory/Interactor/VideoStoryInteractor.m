//
//  VideoStoryInteractor.m
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 20/01/2016.
//  Copyright 2016 Anton Sokolchenko. All rights reserved.
//

#import "VideoStoryInteractor.h"

#import "VideoStoryInteractorOutput.h"

#import "SVUser.h"
#import "CallServiceProtocol.h"
#import "CallServiceDataChannelAdditionsProtocol.h"

#import "CallServiceDelegate.h"
#import "CallServiceHelpers.h"

#import <RTCAVFoundationVideoSource.h>
#import <RTCVideoTrack.h>
#import <RTCEAGLVideoView.h>

@interface VideoStoryInteractor()

@property (nonatomic, strong) SVUser *user1;
@property (nonatomic, strong) SVUser *user2;

@property (nonatomic, strong) SVUser *currentUser;

@property (nonatomic, strong) RTCVideoTrack *localVideoTrack;
@property (nonatomic, strong) RTCVideoTrack *remoteVideoTrack;

@property (nonatomic, assign, getter=isConnectingToChat) BOOL connectingToChat;
@end

@implementation VideoStoryInteractor

#pragma mark - Методы VideoStoryInteractorInput

- (instancetype)init {
	self = [super init];
	if (self) {
		self.user1 = [CallServiceHelpers user1];
		self.user2 = [CallServiceHelpers user2];
	}
	return self;
}

- (void)connectToChatWithUser1 {
	if (self.callService.isConnecting || self.callService.isConnected) {
		return;
	}
	
	SVUser *user = self.user1;
	
	[self.callService connectWithUser:user completion:^(NSError * _Nullable error) {
		if (!error) {
			self.currentUser = user;
			[self.output didConnectToChatWithUser1];
		} else {
			[self.output didFailToConnectToChat];
		}
	}];
}

- (void)connectToChatWithUser2 {
	if (self.callService.isConnecting || self.callService.isConnected) {
		return;
	}
	
	SVUser *user = self.user2;
	
	[self.callService connectWithUser:user completion:^(NSError * _Nullable error) {
		if (!error) {
			self.currentUser = user;
			[self.output didConnectToChatWithUser2];
		} else {
			[self.output didFailToConnectToChat];
		}
	}];
}

- (void)startCall {
	if ([self.callService hasActiveCall]) {
		NSLog(@"Can not call while already connecting");
		return;
	}
	
	if ([self.currentUser isEqual:self.user1]) {
		[self.callService startCallWithOpponent:self.user2];
	} else {
		[self.callService startCallWithOpponent:self.user1];
	}
}

- (void)hangup {
	[self.callService hangup];
	self.localVideoTrack = nil;
	self.remoteVideoTrack = nil;
	
	[self.output didHangup];
}

- (void)requestDataChannelState {
	if ([self isReadyForDataChannel]) {
		[self.output didReceiveDataChannelStateReady];
	} else {
		[self.output didReceiveDataChannelStateNotReady];
	}
}

- (BOOL)isReadyForDataChannel {
	return [self.callService isDataChannelEnabled] && [self.callService isDataChannelReady];
}

#pragma mark SVClientDelegate methods


- (void)callService:(id<CallServiceProtocol>)callService didChangeConnectionState:(RTCICEConnectionState)state {
	
}

- (void)callService:(id<CallServiceProtocol>)callService didChangeState:(enum CallServiceState)state {
	
}

- (void)callService:(id<CallServiceProtocol>)callService didError:(NSError *)error {
	
}

- (void)callService:(id<CallServiceProtocol>)callService didReceiveLocalVideoTrack:(RTCVideoTrack *)localVideoTrack {
	if (self.localVideoTrack == localVideoTrack) {
		return;
	}
	
	RTCAVFoundationVideoSource *source = nil;
	
	if ([localVideoTrack.source isKindOfClass:[RTCAVFoundationVideoSource class]]) {
		source = (RTCAVFoundationVideoSource*)localVideoTrack.source;
	}
	
	[self.output didSetLocalCaptureSession:source.captureSession];
}

- (void)callService:(id<CallServiceProtocol>)callService didReceiveRemoteVideoTrack:(RTCVideoTrack *)remoteVideoTrack {
	__weak __typeof(self)weakSelf = self;
	
	[self.output didReceiveRemoteVideoTrackWithConfigurationBlock:^(RTCEAGLVideoView *renderer) {
		__typeof(self)strongSelf = weakSelf;
		
		if (strongSelf.remoteVideoTrack == remoteVideoTrack) {
			return;
		}
		
		[strongSelf.remoteVideoTrack removeRenderer:renderer];
		strongSelf.remoteVideoTrack = nil;
		
		[renderer renderFrame:nil];
		
		strongSelf.remoteVideoTrack = remoteVideoTrack;
		
		[strongSelf.remoteVideoTrack addRenderer:renderer];
		
	}];
}

- (void)callService:(id<CallServiceProtocol>)callService didOpenDataChannel:(RTCDataChannel *)dataChannel {
	[self.output didOpenDataChannel];
}

- (void)callService:(id<CallServiceProtocol>)callService didReceiveMessage:(NSString *)message {
	NSLog(@"callService %@ didReceiveMessage %@", callService, message);
}

@end