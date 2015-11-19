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

@interface ViewController () <SVClientDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lblConnected;
@property (weak, nonatomic) IBOutlet UILabel *lblState;
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


#pragma mark - SVClientDelegate methods

- (void)client:(SVClient *)client didChangeConnectionState:(RTCICEConnectionState)state {
	
}

- (void)client:(SVClient *)client didChangeState:(enum SVClientState)state {
	
}

- (void)client:(SVClient *)client didError:(NSError *)error {
	
}

- (void)client:(SVClient *)client didReceiveLocalVideoTrack:(RTCVideoTrack *)localVideoTrack {
	
}

- (void)client:(SVClient *)client didReceiveRemoteVideoTrack:(RTCVideoTrack *)remoteVideoTrack {
	
}


@end
