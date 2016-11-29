//
//  CallServiceProtocol_Private.h
//  RTCDemo
//
//  Created by Anton Sokolchenko on 3/1/16.
//  Copyright © 2016 anton. All rights reserved.
//

#ifndef CallServiceProtocol_Private_h
#define CallServiceProtocol_Private_h

#import "CallServiceProtocol.h"

@class RTCDataChannel;
@class RTCDataBuffer;

@protocol SVSignalingChannelProtocol;

@protocol CallServiceProtocol_Private <CallServiceProtocol>

@property (nonatomic, strong) id<SVSignalingChannelProtocol> signalingChannel;
@property (nonatomic, assign) CallServiceState state;
@property (nonatomic, assign) BOOL hasActiveCall; // used in FakeCallService

- (void)channel:(RTCDataChannel *)channel didReceiveMessageWithBuffer:(RTCDataBuffer *)buffer;

@end

#endif /* CallServiceProtocol_Private_h */
