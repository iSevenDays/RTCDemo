//
//  CallServiceProtocol.h
//  RTCDemo
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

@class RTCDataChannel;
@class RTCDataBuffer;
@class SVUser;

@protocol CallServiceProtocol <SVSignalingChannelDelegate>
@required

- (nullable instancetype)initWithSignalingChannel:(nonnull id<SVSignalingChannelProtocol>)signalingChannel;
- (nullable instancetype)initWithSignalingChannel:(nonnull id<SVSignalingChannelProtocol>)signalingChannel callServiceDelegate:(nullable id<CallServiceDelegate>)callServiceDelegate;

- (void)addDelegate:(nonnull id<CallServiceDelegate>)delegate;
- (nullable NSArray<id<CallServiceDelegate>> *)delegates;
/**
 *  Connect to Chat with user
 *
 *  @param user       SVUser instance
 *  @param completion completion
 */
- (void)connectWithUser:(SVUser *_Nonnull)user completion:(void(^_Nullable)(NSError *_Nullable error))completion;

/**
 *  Disconnect from Chat
 *
 *  @param completion completion
 */
- (void)disconnectWithCompletion:(void(^_Nullable)(NSError *_Nullable error))completion;

/**
 *  Start a call with user
 *
 *  @param opponent SVUser instance
 */
- (void)startCallWithOpponent:(SVUser *_Nonnull)opponent;

/**
 *  Accept an existent call from opponent
 *
 *  @param opponent SVUser instance
 */
- (void)acceptCallFromOpponent:(SVUser *_Nonnull)opponent;


/**
 * Clears session and ends a call. Do nothing if there is no active call at the moment
 *
 * @note sends hangup message when -hasActiveCall YES
 */
- (void)hangup;

/*
 * Send hangup to a user
 * Should be called only when incoming call is received from
 * undefined user, otherwise - user -hangup
 */
- (void)sendHangupToUser:(SVUser *_Nonnull)user completion:(void(^_Nullable)(NSError * _Nullable error))completion;

- (BOOL)hasActiveCall;

/// @return YES if current user is a call initiator
- (BOOL)isInitiator;
- (nullable SVUser *)currentUser;

@property (nonatomic, assign) CallServiceState state;
@property (nonatomic, assign, readonly) BOOL isConnecting;
@property (nonatomic, assign, readwrite) BOOL isConnected;

- (void)channel:(RTCDataChannel *_Nullable)channel didReceiveMessageWithBuffer:(RTCDataBuffer *_Nonnull)buffer;

@optional
- (nullable instancetype)initWithSignalingChannel:(nonnull id<SVSignalingChannelProtocol>)signalingChannel callServiceDelegate:(nullable id<CallServiceDelegate>)callServiceDelegate dataChannelDelegate:(nonnull id<CallServiceDataChannelAdditionsDelegate>)dataChannelDelegate;

@end


#endif /* CallServiceProtocol_h */
