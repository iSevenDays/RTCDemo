//
//  SVSignalingMessageType.m
//  RTCDemo
//
//  Created by Anton Sokolchenko on 11/16/15.
//  Copyright © 2015 anton. All rights reserved.
//

#import "SVSignalingMessageType.h"

const struct SVSignalingMessageType SVSignalingMessageType = {
	.candidates = @"candidates",
	.offer = @"offer",
	.answer = @"answer",
	.hangup = @"hangup",
	.reject = @"reject"
};
