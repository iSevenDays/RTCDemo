//
//  SVSignalingMessage.m
//  RTCDemo
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
	return [self initWithType:type params:params sender:nil];
}

- (instancetype)initWithType:(NSString *)type params:(NSDictionary *)params sender:(SVUser *)sender{
	self = [super init];
	
	NSCAssert([type isEqualToString:SVSignalingMessageType.answer] ||
			  [type isEqualToString:SVSignalingMessageType.offer] ||
			  [type isEqualToString:SVSignalingMessageType.hangup] ||
			  [type isEqualToString:SVSignalingMessageType.candidates] ||
			  [type isEqualToString:SVSignalingMessageType.reject], @"Unknown type");
	
	if (self) {
		_type = type;
		_params = [params copy];
		_sender = sender;
	}
	return self;
}

@end
