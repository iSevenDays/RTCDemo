//
//  SVSignalingChannelDelegate.h
//  RTCDemo
//
//  Created by Anton Sokolchenko on 11/16/15.
//  Copyright © 2015 anton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SVSignalingChannelState.h"

@protocol SVSignalingChannelProtocol;
@class SVSignalingMessage;

@protocol SVSignalingChannelDelegate <NSObject>

@optional
- (void)channel:(nonnull id<SVSignalingChannelProtocol>)channel didReceiveMessage:(SVSignalingMessage *_Nonnull)message;
- (void)channel:(nonnull id<SVSignalingChannelProtocol>)channel didChangeState:(NSString *_Nonnull)signalingState;

@end
