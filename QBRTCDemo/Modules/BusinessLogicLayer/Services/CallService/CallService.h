//
//  CallService.h
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 1/25/16.
//  Copyright © 2016 anton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CallServiceProtocol.h"
#import "CallServiceDataChannelAdditionsProtocol.h"

@protocol CallClientDelegate;
@protocol SVSignalingChannelProtocol;

@class SVUser;
@class RTCICEServer;

@interface CallService : NSObject<CallServiceProtocol, CallServiceDataChannelAdditionsProtocol>

- (nullable instancetype)initWithSignalingChannel:(nonnull id<SVSignalingChannelProtocol>)signalingChannel clientDelegate:(nonnull id<CallClientDelegate, CallServiceDataChannelAdditionsProtocol>)clientDelegate;

- (void)connectWithUser:(SVUser *_Nonnull)user completion:(void(^_Nullable )(NSError *_Nullable error))completion;

- (void)startCallWithOpponent:(SVUser *_Nonnull)opponent;

- (void)hangup;

- (BOOL)hasActiveCall;

@property (nonatomic, assign, readonly) CallClientState state;
@property (nonatomic, assign, readonly) BOOL isConnecting;
@property (nonatomic, assign, readwrite) BOOL isConnected;

@property (nonatomic, strong, nonnull) NSMutableArray<RTCICEServer *> *iceServers;

@end
