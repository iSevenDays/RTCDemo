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
#import "NSData+GZIP.h"

@implementation SVSignalingMessage (QBChatMessage)

+ (instancetype)messageWithQBChatMessage:(QBChatMessage *)qbmessage {
	NSString *signalingType = qbmessage.text;
	
	// Decompressing customParameters from 'compressedData' field
	NSString *base64Representation = qbmessage.customParameters[SVSignalingParams.compressedData];
	NSCParameterAssert(base64Representation);
	
	NSData *decodedBase64Data = [[NSData alloc] initWithBase64EncodedString:base64Representation options:0];
	NSCParameterAssert(decodedBase64Data);
	
	NSData *ungzippedData = [decodedBase64Data gunzippedData];
	NSCParameterAssert(ungzippedData);
	
	NSError *error = nil;
	NSDictionary *params = [NSJSONSerialization JSONObjectWithData:ungzippedData options:0 error:&error];
	NSAssert(error == nil, @"JSON decoding error");
	
	SVSignalingMessage *svmessage = nil;
	
	if ([signalingType isEqualToString:SVSignalingMessageType.answer] ||
		[signalingType isEqualToString:SVSignalingMessageType.offer] ) {
		
		svmessage = [SVSignalingMessageSDP messageWithType:signalingType params:params];
		
	} else if([signalingType isEqualToString:SVSignalingMessageType.candidates]) {
		
		svmessage = [SVSignalingMessageICE messageWithType:signalingType params:params];
	} else {
		svmessage = [SVSignalingMessage messageWithType:signalingType params:params];
	}
	
	// restore user back from dictionary
	NSString *login = params[SVSignalingParams.senderLogin];
	NSString *fullName = params[SVSignalingParams.senderFullName];
	
	NSString *initiatorID = params[SVSignalingParams.initiatorID];
	NSParameterAssert(initiatorID);
	
	NSString *sessionID = params[SVSignalingParams.sessionID];
	NSParameterAssert(sessionID);
	
	NSArray<NSString *> *membersIDsStr = [params[SVSignalingParams.membersIDs] componentsSeparatedByString:@","];
	NSMutableArray<NSNumber *> *membersIDs = [NSMutableArray arrayWithCapacity:membersIDsStr.count];
	NSAssert(membersIDsStr.count != 0, @"Members IDs array must not be empty");
	for (NSString *memberID in membersIDsStr) {
		[membersIDs addObject:@([memberID intValue])];
	}
	svmessage.membersIDs = [membersIDs copy];
	
	svmessage.sender = [[SVUser alloc] initWithID:@(qbmessage.senderID) login:login fullName:fullName password:nil tags:nil];
	svmessage.initiatorID = @([initiatorID integerValue]);
	svmessage.sessionID = sessionID;
	return svmessage;
}

@end
