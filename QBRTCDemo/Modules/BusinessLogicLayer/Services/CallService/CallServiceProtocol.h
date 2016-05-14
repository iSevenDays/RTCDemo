//
//  CallServiceProtocol.h
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 1/25/16.
//  Copyright © 2016 anton. All rights reserved.
//

#ifndef CallServiceProtocol_h
#define CallServiceProtocol_h

#import "SVSignalingChannelDelegate.h"

typedef NS_ENUM(NSInteger, CallServiceState) {
	// Disconnected from servers.
	kClientStateDisconnected,
	// Connecting to servers.
	kClientStateConnecting,
	// Connected to chat.
	kClientStateConnected,
};

@protocol SVSignalingChannelProtocol;
@protocol CallServiceDelegate;
@protocol CallServiceDataChannelAdditionsDelegate;

@class SVUser;

@protocol CallServiceProtocol <SVSignalingChannelDelegate>
@required

- (nullable instancetype)initWithSignalingChannel:(nonnull id<SVSignalingChannelProtocol>)signalingChannel callServiceDelegate:(nonnull id<CallServiceDelegate>)callServiceDelegate;

- (void)addDelegate:(nonnull id<CallServiceDelegate>)delegate;

- (void)connectWithUser:(SVUser *_Nonnull)user completion:(void(^_Nullable )(NSError *_Nullable error))completion;

- (void)startCallWithOpponent:(SVUser *_Nonnull)opponent;

/**
 * Clears session and ends a call
 *
 * @note sends hangup message when -hasActiveCall YES
 */
- (void)hangup;

- (BOOL)hasActiveCall;

/// @return YES if current user is a call initiator
- (BOOL)isInitiator;

@property (nonatomic, assign, readonly) CallServiceState state;
@property (nonatomic, assign, readonly) BOOL isConnecting;
@property (nonatomic, assign, readwrite) BOOL isConnected;

@optional
- (nullable instancetype)initWithSignalingChannel:(nonnull id<SVSignalingChannelProtocol>)signalingChannel callServiceDelegate:(nullable id<CallServiceDelegate>)callServiceDelegate dataChannelDelegate:(nonnull id<CallServiceDataChannelAdditionsDelegate>)dataChannelDelegate;

@end


#endif /* CallServiceProtocol_h */
