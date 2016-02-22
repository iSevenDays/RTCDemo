//
//  CallServiceProtocol.h
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 1/25/16.
//  Copyright © 2016 anton. All rights reserved.
//

#ifndef CallServiceProtocol_h
#define CallServiceProtocol_h

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

@protocol CallServiceProtocol <NSObject>

- (nullable instancetype)initWithSignalingChannel:(nonnull id<SVSignalingChannelProtocol>)signalingChannel callServiceDelegate:(nonnull id<CallServiceDelegate>)callServiceDelegate;

- (void)connectWithUser:(SVUser *_Nonnull)user completion:(void(^_Nullable )(NSError *_Nullable error))completion;

- (void)startCallWithOpponent:(SVUser *_Nonnull)opponent;

- (void)hangup;

- (BOOL)hasActiveCall;

/// @return YES if current user is call initiator
- (BOOL)isInitiator;

@property (nonatomic, assign, readonly) CallServiceState state;
@property (nonatomic, assign, readonly) BOOL isConnecting;
@property (nonatomic, assign, readwrite) BOOL isConnected;
@property (nonatomic, weak, nullable) id<CallServiceDelegate> delegate;

@optional
- (nullable instancetype)initWithSignalingChannel:(nonnull id<SVSignalingChannelProtocol>)signalingChannel callServiceDelegate:(nullable id<CallServiceDelegate>)callServiceDelegate dataChannelDelegate:(nonnull id<CallServiceDataChannelAdditionsDelegate>)dataChannelDelegate;

@property (nonatomic, weak, nullable) id<CallServiceDataChannelAdditionsDelegate> dataChannelDelegate;

@end


#endif /* CallServiceProtocol_h */
