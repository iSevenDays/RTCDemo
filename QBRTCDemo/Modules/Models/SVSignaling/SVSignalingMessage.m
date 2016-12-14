//
//  SVSignalingMessage.m
//  RTCDemo
//
//  Created by Anton Sokolchenko on 11/16/15.
//  Copyright © 2015 anton. All rights reserved.
//

#import "SVSignalingMessage.h"

#import "QBRTCDemo_s-Swift.h"

@implementation SVSignalingMessage

- (instancetype)initWithType:(NSString *)type params:(NSDictionary *)params {
	self = [super init];
	
	NSCAssert([type isEqualToString:SVSignalingMessageType.answer] ||
			  [type isEqualToString:SVSignalingMessageType.offer] ||
			  [type isEqualToString:SVSignalingMessageType.hangup] ||
			  [type isEqualToString:SVSignalingMessageType.candidates] ||
			  [type isEqualToString:SVSignalingMessageType.reject], @"Unknown type");
	
	if (self) {
		_type = type;
		_params = [params copy];
	}
	return self;
}

- (void)populateParametersWithSessionDetails:(SessionDetails *)sessionDetails {
	_initiatorID = @(sessionDetails.initiatorID);
	_sessionID = sessionDetails.sessionID;
	_membersIDs = sessionDetails.membersIDs;
}

@end
