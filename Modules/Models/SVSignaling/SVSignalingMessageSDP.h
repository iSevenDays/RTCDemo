//
//  SVSignalingMessageSDP.h
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 11/16/15.
//  Copyright © 2015 anton. All rights reserved.
//

#import "SVSignalingMessage.h"
@class RTCSessionDescription;

@interface SVSignalingMessageSDP : SVSignalingMessage

- (nullable instancetype)initWithSessionDescription:(RTCSessionDescription *_Nonnull)sessionDescription;

@property (nonatomic, strong, readonly, nullable) RTCSessionDescription *sdp;

@end
