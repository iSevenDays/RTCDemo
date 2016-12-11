//
//  SVSignalingMessageSDP.m
//  RTCDemo
//
//  Created by Anton Sokolchenko on 11/16/15.
//  Copyright © 2015 anton. All rights reserved.
//

#import "SVSignalingParams.h"
#import "SVSignalingMessageSDP.h"
#import <RTCSessionDescription.h>

@implementation SVSignalingMessageSDP

- (instancetype)initWithSessionDescription:(RTCSessionDescription *)sessionDescription sessionDetails:(SessionDetails *)sessiondetails {
	NSString *type = sessionDescription.type;
	
	NSCAssert([type isEqualToString:SVSignalingMessageType.offer] || [type isEqualToString:SVSignalingMessageType.answer],
			  @"Type must be offer or answer");
	
	self = [super initWithType:type params:nil];
	
	if (self) {
		_sdp = sessionDescription;
		[self populateParametersWithSessionDetails:sessiondetails];
	}
	return self;
}

- (instancetype)initWithType:(NSString *)type params:(NSDictionary *)params {
	self = [super initWithType:type params:params];
	NSCAssert([type isEqualToString:SVSignalingMessageType.offer] || [type isEqualToString:SVSignalingMessageType.answer],
			  @"Type must be offer or answer");
	
	if (self) {
		NSString *sdp = params[SVSignalingParams.sdp];
		sdp = [sdp stringByReplacingOccurrencesOfString:@"&#13;" withString:@"\r"];
		NSCParameterAssert(sdp);
		_sdp = [[RTCSessionDescription alloc] initWithType:type sdp:sdp];
	}
	return self;
}

@end
