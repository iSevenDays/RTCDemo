//
//  FakeCallService.h
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 1/26/16.
//  Copyright © 2016 anton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CallServiceProtocol.h"

@protocol CallClientDelegate;
@protocol SVSignalingChannelProtocol;

@interface FakeCallService : NSObject<CallServiceProtocol>

- (nullable instancetype)initWithSignalingChannel:(nonnull id<SVSignalingChannelProtocol>)signalingChannel clientDelegate:(nonnull id<CallClientDelegate>)clientDelegate;

@property (nonatomic, assign, readonly) BOOL isConnecting;
@property (nonatomic, assign, readwrite) BOOL isConnected;
@property (nonatomic, weak, nullable) id<CallClientDelegate> delegate;

@end
