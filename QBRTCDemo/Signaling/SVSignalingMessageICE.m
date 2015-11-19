//
//  SVSignalingMessageICE.m
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 11/16/15.
//  Copyright © 2015 anton. All rights reserved.
//

#import "SVSignalingMessageICE.h"
#import "SVSignalingParams.h"
#import <RTCICECandidate.h>

@implementation SVSignalingMessageICE

- (instancetype)initWithICECandidate:(RTCICECandidate *)iceCandidate {
	self = [super initWithType:SVSignalingMessageType.candidate params:nil];
	if (self) {
		// make [iceCandidate copy]
		_iceCandidate = [[RTCICECandidate alloc] initWithMid:iceCandidate.sdpMid index:iceCandidate.sdpMLineIndex sdp:iceCandidate.sdp];
	}
	return self;
}

- (instancetype)initWithType:(NSString *)type params:(NSDictionary *)params {
	self = [super initWithType:type params:params];
	NSCAssert([type isEqualToString:SVSignalingMessageType.offer] || [type isEqualToString:SVSignalingMessageType.answer],
			  @"Type must be offer or answer");
	if (self) {
		
		NSString *mid = params[SVSignalingParams.mid];
		NSString *index = params[SVSignalingParams.index];
		NSString *sdp = params[SVSignalingParams.sdp];
		
		NSCParameterAssert(mid);
		NSCParameterAssert(index);
		NSCParameterAssert(sdp);
		
		_iceCandidate = [[RTCICECandidate alloc] initWithMid:mid index:index.integerValue sdp:sdp];
	}
	return self;
}

@end
