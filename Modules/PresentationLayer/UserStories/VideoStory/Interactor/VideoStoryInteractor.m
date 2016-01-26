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

@interface VideoStoryInteractor()

@property (nonatomic, strong) SVUser *user1;
@property (nonatomic, strong) SVUser *user2;

@property (nonatomic, strong) SVUser *currentUser;
@end

@implementation VideoStoryInteractor

#pragma mark - Методы VideoStoryInteractorInput

- (instancetype)init {
	self = [super init];
	if (self) {
// prod
//		self.user1 = [[SVUser alloc] initWithID:@(8662991) login:@"rtcuser1" password:@"rtcuser1"];
//		self.user2 = [[SVUser alloc] initWithID:@(8663016
		self.user1 = [[SVUser alloc] initWithID:@(6942802) login:@"rtcuser1" password:@"rtcuser1"];
		self.user2 = [[SVUser alloc] initWithID:@(6942819) login:@"rtcuser2" password:@"rtcuser2"];
	}
	return self;
}

- (void)connectToChatWithUser1 {
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
}

@end