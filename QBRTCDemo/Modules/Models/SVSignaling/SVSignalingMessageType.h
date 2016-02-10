//
//  SVSignalingMessageType.h
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 11/16/15.
//  Copyright © 2015 anton. All rights reserved.
//

#import <Foundation/Foundation.h>

extern const struct SVSignalingMessageType {
	__unsafe_unretained NSString *candidate;
	__unsafe_unretained NSString *offer;
	__unsafe_unretained NSString *answer;
	__unsafe_unretained NSString *hangup;
	__unsafe_unretained NSString *reject;
} SVSignalingMessageType;