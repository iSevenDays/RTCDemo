//
//  ViewController.m
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 11/15/15.
//  Copyright © 2015 anton. All rights reserved.
//

#import "ViewController.h"
#import "SVSignalingChannelProtocol.h"
#import "SVClient.h"
#import "QBSignalingChannel.h"
#import "RTCEAGLVideoView.h"

#import <RTCVideoTrack.h>


@interface ViewController () <SVClientDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lblConnected;
@property (weak, nonatomic) IBOutlet UILabel *lblState;
@property (weak, nonatomic) IBOutlet UILabel *lblIceState;


@property (weak, nonatomic) IBOutlet RTCEAGLVideoView *remoteVideoView;
@property (weak, nonatomic) IBOutlet RTCEAGLVideoView *localVideoView;

@property (strong, nonatomic) RTCVideoTrack *remoteVideoTrack;
@property (strong, nonatomic) RTCVideoTrack *localVideoTrack;

@property (nonatomic, strong) SVClient *client;
@property (nonatomic, strong) SVUser *currentUser;
@property (nonatomic, strong) SVUser *opponentUser;

@property (nonatomic, strong) SVUser *user1;
@property (nonatomic, strong) SVUser *user2;

@end

@implementation ViewController


- (void)viewDidLoad {
	[super viewDidLoad];
	
	QBSignalingChannel *signalChannel = [[QBSignalingChannel alloc] init];
	
	self.client = [[SVClient alloc] initWithSignalingChannel:signalChannel clientDelegate:self];
	
	self.user1 = [[SVUser alloc] initWithID:@(6942802) login:@"rtcuser1" password:@"rtcuser1"];
	self.user2 = [[SVUser alloc] initWithID:@(6942819) login:@"rtcuser2" password:@"rtcuser2"];
	
}

- (IBAction)connectUser1:(id)sender {
	self.currentUser = self.user1;
	
	self.lblConnected.text = [@"Connecting with user: " stringByAppendingString:self.currentUser.login];
	
	[self.client connectWithUser:self.user1 completion:^(NSError * _Nullable error) {
		if (error) {
			NSLog(@"connect error: %@", error);
			self.currentUser = nil;
		} else {
			self.lblConnected.text = [@"Connected with user: " stringByAppendingString:self.currentUser.login];
			self.lblConnected.backgroundColor = [UIColor greenColor];
		}
	}];
}

- (IBAction)connectUser2:(id)sender {
	self.currentUser = self.user2;
	self.lblConnected.text = [@"Connecting with user: " stringByAppendingString:self.currentUser.login];
	
	[self.client connectWithUser:self.user2 completion:^(NSError * _Nullable error) {
		if (error) {
			NSLog(@"connect error: %@", error);
			self.currentUser = nil;
		} else {
			self.lblConnected.text = [@"Connected with user: " stringByAppendingString:self.currentUser.login];
			self.lblConnected.backgroundColor = [UIColor greenColor];
		}
	}];
}

- (IBAction)startCall:(id)sender {
	if ([self.currentUser.ID isEqualToNumber:self.user1.ID]) {
		[self.client startCallWithOpponent:self.user2];
	} else {
		[self.client startCallWithOpponent:self.user1];
	}
}
- (IBAction)openDataChannel:(id)sender {
	[self.client openDataChannel];
}

- (IBAction)hungup:(id)sender {
	[self.client hangup];
}


#pragma mark - SVClientDelegate methods

- (void)client:(SVClient *)client didChangeConnectionState:(RTCICEConnectionState)state {
	NSString *iceText = nil;
	switch (state) {
		case RTCICEConnectionChecking:
			iceText = @"checking";
			break;
		case RTCICEConnectionClosed:
			iceText = @"closed";
			break;
		case RTCICEConnectionCompleted:
			iceText = @"completed";
			break;
		case RTCICEConnectionConnected:
			iceText = @"connected";
			break;
		case RTCICEConnectionDisconnected:
			iceText = @"disconnected";
			break;
		case RTCICEConnectionFailed:
			iceText = @"failed";
			break;
  default:
			break;
	}
	
	if (iceText) {
		self.lblIceState.text = [@"ICE State:" stringByAppendingString:iceText];
	}
}

- (void)client:(SVClient *)client didChangeState:(enum SVClientState)state {
	NSString *stateText = nil;
	switch (state) {
		case kClientStateDisconnected: {
			stateText = @"Disconnected";
			break;
		}
		case kClientStateConnecting: {
			stateText = @"Connecting";
			break;
		}
		case kClientStateConnected: {
			stateText = @"Connected";
			break;
		}
		default: {
			assert(false);
			break;
		}
	}
	self.lblState.text = [@"State: " stringByAppendingString:stateText];
}

- (void)client:(SVClient *)client didError:(NSError *)error {
	
}

- (void)client:(SVClient *)client didReceiveLocalVideoTrack:(RTCVideoTrack *)localVideoTrack {

	
#ifndef __i386__
	[self.localVideoView renderFrame:nil];
	[localVideoTrack addRenderer:self.localVideoView];
#endif

}

- (void)client:(SVClient *)client didReceiveRemoteVideoTrack:(RTCVideoTrack *)remoteVideoTrack {
	if (self.remoteVideoTrack == remoteVideoTrack) {
		return;
	}
	
	// disable old
	[self.remoteVideoTrack removeRenderer:self.remoteVideoView];
	self.remoteVideoTrack = nil;
	[self.remoteVideoView renderFrame:nil];
	
	// enable new
	self.remoteVideoTrack = remoteVideoTrack;
	
	[self.remoteVideoTrack addRenderer:self.remoteVideoView];
	
#if __i386__
	NSLog(@"simulator didReceiveRemoteVideoTrack" );
#endif
}


@end
