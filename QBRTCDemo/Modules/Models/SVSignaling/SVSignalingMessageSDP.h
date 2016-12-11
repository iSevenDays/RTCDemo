//
//  SVSignalingMessageSDP.h
//  RTCDemo
//
//  Created by Anton Sokolchenko on 11/16/15.
//  Copyright © 2015 anton. All rights reserved.
//

#import "SVSignalingMessage.h"
@class RTCSessionDescription;
@class SessionDetails;

@interface SVSignalingMessageSDP : SVSignalingMessage

- (nonnull instancetype)initWithSessionDescription:(RTCSessionDescription *_Nonnull)sessionDescription sessionDetails:(SessionDetails *_Nonnull)sessiondetails;

@property (nonatomic, strong, readonly, nullable) RTCSessionDescription *sdp;

@end
