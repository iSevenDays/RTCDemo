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
#import "CallClientDelegate.h"

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


#pragma mark SVClientDelegate methods


- (void)client:(id<CallServiceProtocol>)client didChangeConnectionState:(RTCICEConnectionState)state {
	
}

- (void)client:(id<CallServiceProtocol>)client didChangeState:(enum CallClientState)state {
	
}

- (void)client:(id<CallServiceProtocol>)client didError:(NSError *)error {
	
}

- (void)client:(id<CallServiceProtocol>)client didReceiveLocalVideoTrack:(RTCVideoTrack *)localVideoTrack {
	if (self.localVideoTrack == localVideoTrack) {
		return;
	}
	
	RTCAVFoundationVideoSource *source = nil;
	
	if ([localVideoTrack.source isKindOfClass:[RTCAVFoundationVideoSource class]]) {
		source = (RTCAVFoundationVideoSource*)localVideoTrack.source;
	}
	
	[self.output didSetLocalCaptureSession:source.captureSession];
}

- (void)client:(id<CallServiceProtocol>)client didReceiveRemoteVideoTrack:(RTCVideoTrack *)remoteVideoTrack {
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

@end