//
//  SVSignalingMessage.m
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 11/16/15.
//  Copyright © 2015 anton. All rights reserved.
//

#import "SVSignalingMessage.h"

@implementation SVSignalingMessage

+ (instancetype)messageWithType:(NSString *)type params:(NSDictionary *)params {
	return [[self alloc] initWithType:type params:params];
}

- (instancetype)initWithType:(NSString *)type params:(NSDictionary *)params {
	self = [super init];
	
	NSCAssert([type isEqualToString:SVSignalingMessageType.answer] ||
			  [type isEqualToString:SVSignalingMessageType.offer] ||
			  [type isEqualToString:SVSignalingMessageType.hangup] ||
			  [type isEqualToString:SVSignalingMessageType.candidate], @"Unknown type");
	
	if (self) {
		_type = type;
		_params = [params copy];
	}
	return self;
}


@end
