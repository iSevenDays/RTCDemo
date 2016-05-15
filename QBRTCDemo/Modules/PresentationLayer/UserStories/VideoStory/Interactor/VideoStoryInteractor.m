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

#import "DataChannelMessages.h"

#import <RTCAVFoundationVideoSource.h>
#import <RTCVideoTrack.h>
#import <RTCEAGLVideoView.h>


@interface VideoStoryInteractor()

@property (nonatomic, strong) SVUser *lastOpponentUser;

@property (nonatomic, strong) RTCVideoTrack *localVideoTrack;
@property (nonatomic, strong) RTCVideoTrack *remoteVideoTrack;

@property (nonatomic, assign, getter=isConnectingToChat) BOOL connectingToChat;
@end

@implementation VideoStoryInteractor

#pragma mark - Методы VideoStoryInteractorInput

- (SVUser *)currentUser {
	return self.callService.currentUser;
}

- (void)connectToChatWithUser:(SVUser *)user callOpponent:(SVUser *)opponent {
	if (self.callService.isConnecting) {
		return;
	}
	
	void (^connectWithUserAndCallBlock)(SVUser *, SVUser *) = ^(SVUser *user, SVUser *opponent) {
		[self.callService connectWithUser:user completion:^(NSError * _Nullable error) {
			if (!error) {
				
				[self.output didConnectToChatWithUser:user];
				
				if (opponent != nil) {
					[self startCallWithOpponent:opponent];
				}
				
			} else {
				[self.output didFailToConnectToChat];
			}
		}];
	};
	
	if (self.callService.isConnected && [self.currentUser isEqual:user]) {
		[self startCallWithOpponent:opponent];
	} else if (self.callService.isConnected && ![self.currentUser isEqual:user]) {
		// connected with another user, firstly disconnect
		DDLogVerbose(@"Connected with another user, doing disconnect");
		[self.callService disconnectWithCompletion:^(NSError * _Nullable error) {
			if (error == nil) {
				connectWithUserAndCallBlock(user, opponent);
			} else {
				DDLogError(@"Error disconnecting %@", error);
			}
		}];
	} else {
		connectWithUserAndCallBlock(user, opponent);
	}
}

- (void)startCallWithOpponent:(SVUser *)opponent {
	if ([self.callService hasActiveCall]) {
		DDLogWarn(@"Can not call while already connecting");
		return;
	}
	
	NSAssert(![opponent isEqual:self.currentUser], @"You can not call yourself");
	
	if (opponent != nil) {
		self.lastOpponentUser = opponent;
	}
	
	[self.callService addDelegate:self];
	[self.callService addDataChannelDelegate:self];
	
	NSLog(@"Starting a call with opponent %@", opponent);
	[self.callService startCallWithOpponent:opponent];
	
}

- (void)acceptCallFromOpponent:(SVUser *)opponent {
	self.lastOpponentUser = opponent;
	
	[self.callService addDelegate:self];
	[self.callService addDataChannelDelegate:self];
	
	[self.callService acceptCallFromOpponent:opponent];
}

- (void)sendInvitationMessageAndOpenImageGallery {
	NSParameterAssert([self.callService hasActiveCall]);
	
	if ([self.callService sendText:[DataChannelMessages invitationToOpenImageGallery]]) {
		[self.output didSendInvitationToOpenImageGallery];
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

#pragma mark CallServiceDelegate methods

- (void)callService:(id<CallServiceProtocol>)callService didReceiveCallRequestFromOpponent:(SVUser *)opponent {
	// do nothing
}

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
	DDLogVerbose(@"callService %@ didReceiveMessage %@", callService, message);
	
	if ([message isEqualToString:[DataChannelMessages invitationToOpenImageGallery]]) {
		DDLogInfo(@"received invitation to open image gallery");
		[self.output didReceiveInvitationToOpenImageGallery];
	}
}

@end