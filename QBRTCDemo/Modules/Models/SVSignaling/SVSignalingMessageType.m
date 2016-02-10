//
//  SVSignalingMessageType.m
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 11/16/15.
//  Copyright © 2015 anton. All rights reserved.
//

#import "SVSignalingMessageType.h"

const struct SVSignalingMessageType SVSignalingMessageType = {
	.candidate = @"candidate",
	.offer = @"offer",
	.answer = @"answer",
	.hangup = @"hangup",
	.reject = @"reject"
};
