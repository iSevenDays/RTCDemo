//
//  QBChatMessage+SVSignalingMessage.m
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 11/17/15.
//  Copyright © 2015 anton. All rights reserved.
//

#import "QBChatMessage+SVSignalingMessage.h"
#import "SVSignalingMessageICE.h"
#import "SVSignalingMessageSDP.h"
#import "SVSignalingParams.h"
#import <RTCIceCandidate.h>
#import <RTCSessionDescription.h>

@implementation QBChatMessage (SVSignalingMessage)

+ (instancetype)messageWithSVSignalingMessage:(SVSignalingMessage *)signalingMessage {
	QBChatMessage *message = [QBChatMessage message];
	
	NSMutableDictionary<NSString *, NSString *> *dic = signalingMessage.params.mutableCopy;
	
	if (dic == nil) {
		dic = [NSMutableDictionary dictionary];
	}
	
	message.customParameters = dic;
	
	if ([signalingMessage isKindOfClass:[SVSignalingMessageICE class]]) {
		
		SVSignalingMessageICE *sigmessageICE = (SVSignalingMessageICE *)signalingMessage;
		
		message.customParameters[SVSignalingParams.sdp] = sigmessageICE.iceCandidate.sdp;
		message.customParameters[SVSignalingParams.mid] = sigmessageICE.iceCandidate.sdpMid;
		message.customParameters[SVSignalingParams.index] = [@(sigmessageICE.iceCandidate.sdpMLineIndex) stringValue];
		
	} else if ([signalingMessage isKindOfClass:[SVSignalingMessageSDP class]]) {
		
		SVSignalingMessageSDP *sigmessageSDP = (SVSignalingMessageSDP *)signalingMessage;
		
		message.customParameters[SVSignalingParams.sdp] = sigmessageSDP.sdp.description;
	} else {
		message.customParameters = signalingMessage.params.mutableCopy;
	}
	
	message.text = signalingMessage.type;
	
	return message;
}

@end
