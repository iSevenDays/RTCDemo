//
//  SVSignalingParams.m
//  RTCDemo
//
//  Created by Anton Sokolchenko on 11/17/15.
//  Copyright © 2015 anton. All rights reserved.
//

#import "SVSignalingParams.h"


const struct SVSignalingParams SVSignalingParams = {
	//sdp
	.sdp = @"sdp",
	//ice
	.mid = @"mid",
	.index = @"index",
	.sessionID = @"sessionID",
	.initiatorID = @"initiatorID",
	.membersIDs = @"membersIDs",
	.senderLogin = @"login",
	.senderFullName = @"fullname",
	.compressedData = @"compressedData"
};
