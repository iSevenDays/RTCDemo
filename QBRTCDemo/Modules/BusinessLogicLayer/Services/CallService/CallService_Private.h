//
//  CallService_Private.h
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 2/9/16.
//  Copyright © 2016 anton. All rights reserved.
//

#ifndef CallService_Private_h
#define CallService_Private_h

#import "CallService.h"
@class SVSignalingMessage;

@interface CallService ()

@property (nonatomic, strong) id<SVSignalingChannelProtocol> signalingChannel;

- (void)processSignalingMessage:(SVSignalingMessage *)message;
- (void)clearSession;

@end

#endif /* CallService_Private_h */
