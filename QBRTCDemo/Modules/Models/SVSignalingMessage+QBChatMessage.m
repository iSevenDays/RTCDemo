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
	svmessage.sender = [SVUser userWithID:@(qbmessage.senderID) login:login password:@""];
	
	return svmessage;
}

@end
