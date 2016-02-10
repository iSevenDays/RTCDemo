//
//  CallService.h
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 1/25/16.
//  Copyright © 2016 anton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CallServiceProtocol.h"

@protocol CallClientDelegate;
@protocol SVSignalingChannelProtocol;

@class SVUser;

@interface CallService : NSObject<CallServiceProtocol>

- (nullable instancetype)initWithSignalingChannel:(nonnull id<SVSignalingChannelProtocol>)signalingChannel clientDelegate:(nonnull id<CallClientDelegate>)clientDelegate;

- (void)connectWithUser:(SVUser *_Nonnull)user completion:(void(^_Nullable )(NSError *_Nullable error))completion;

- (void)startCallWithOpponent:(SVUser *_Nonnull)opponent;

- (void)openDataChannel;

- (void)hangup;

- (BOOL)hasActiveCall;

@property (nonatomic, assign, readonly) CallClientState state;
@property (nonatomic, assign, readonly) BOOL isConnecting;
@property (nonatomic, assign, readwrite) BOOL isConnected;
@property (nonatomic, weak, nullable) id<CallClientDelegate> delegate;

@property (nonatomic, strong, nonnull) NSMutableArray *iceServers;

@end
