//
//  SVSignalingMessage+QBChatMessage.m
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 11/17/15.
//  Copyright © 2015 anton. All rights reserved.
//

#import "SVSignalingMessage+QBChatMessage.h"
#import "SVSignalingMessageICE.h"
#import "SVSignalingMessageSDP.h"

@implementation SVSignalingMessage (QBChatMessage)

+ (instancetype)messageWithQBChatMessage:(QBChatMessage *)qbmessage {
	NSString *signalingType = qbmessage.text;
	NSDictionary *params = qbmessage.customParameters;
	
	if ([signalingType isEqualToString:SVSignalingMessageType.answer] ||
		[signalingType isEqualToString:SVSignalingMessageType.offer] ) {
		
		return [SVSignalingMessageSDP messageWithType:signalingType params:qbmessage.customParameters];
		
	} else if([signalingType isEqualToString:SVSignalingMessageType.candidate]) {
		
		return [SVSignalingMessageICE messageWithType:signalingType params:params];
	}
	
	return [SVSignalingMessage messageWithType:signalingType params:params];
}

@end
