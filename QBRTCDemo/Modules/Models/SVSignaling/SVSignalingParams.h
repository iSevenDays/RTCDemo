//
//  SVSignalingParams.h
//  RTCDemo
//
//  Created by Anton Sokolchenko on 11/17/15.
//  Copyright © 2015 anton. All rights reserved.
//

#import <Foundation/Foundation.h>


extern const struct SVSignalingParams {
	__unsafe_unretained NSString *sdp;
	__unsafe_unretained NSString *mid;
	__unsafe_unretained NSString *index;
	__unsafe_unretained NSString *sessionID;
	__unsafe_unretained NSString *initiatorID;
	__unsafe_unretained NSString *membersIDs;
	__unsafe_unretained NSString *senderLogin;
	__unsafe_unretained NSString *senderFullName;
	
} SVSignalingParams;
