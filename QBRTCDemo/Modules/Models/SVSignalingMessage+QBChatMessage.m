//
//  SVSignalingMessage+QBChatMessage.m
//  RTCDemo
//
//  Created by Anton Sokolchenko on 11/17/15.
//  Copyright © 2015 anton. All rights reserved.
//

#import "SVSignalingMessage+QBChatMessage.h"
#import "SVSignalingMessageICE.h"
#import "SVSignalingMessageSDP.h"
#import "SVSignalingParams.h"
#import "SVUser.h"

@implementation SVSignalingMessage (QBChatMessage)

+ (instancetype)messageWithQBChatMessage:(QBChatMessage *)qbmessage {
	NSString *signalingType = qbmessage.text;
	NSDictionary *params = qbmessage.customParameters;
	
	SVSignalingMessage *svmessage = nil;
	
	if ([signalingType isEqualToString:SVSignalingMessageType.answer] ||
		[signalingType isEqualToString:SVSignalingMessageType.offer] ) {
		
		svmessage = [SVSignalingMessageSDP messageWithType:signalingType params:qbmessage.customParameters];
		
	} else if([signalingType isEqualToString:SVSignalingMessageType.candidate]) {
		
		svmessage = [SVSignalingMessageICE messageWithType:signalingType params:params];
	} else {
		svmessage = [SVSignalingMessage messageWithType:signalingType params:params];
	}
	
	// restore user back from dictionary
	NSString *login = params[SVSignalingParams.senderLogin];
	NSString *fullName = params[SVSignalingParams.senderFullName];
	svmessage.sender = [[SVUser alloc] initWithID:@(qbmessage.senderID) login:login fullName:fullName password:nil tags:nil];
	
	return svmessage;
}

@end
