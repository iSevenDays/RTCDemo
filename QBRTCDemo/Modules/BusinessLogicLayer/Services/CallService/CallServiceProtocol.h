//
//  CallServiceProtocol.h
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 1/25/16.
//  Copyright © 2016 anton. All rights reserved.
//

#ifndef CallServiceProtocol_h
#define CallServiceProtocol_h

typedef NS_ENUM(NSInteger, CallClientState) {
	// Disconnected from servers.
	kClientStateDisconnected,
	// Connecting to servers.
	kClientStateConnecting,
	// Connected to chat.
	kClientStateConnected,
};

@protocol SVSignalingChannelProtocol;
@protocol CallClientDelegate;

@class SVUser;

@protocol CallServiceProtocol <NSObject>

- (nullable instancetype)initWithSignalingChannel:(nonnull id<SVSignalingChannelProtocol>)signalingChannel clientDelegate:(nonnull id<CallClientDelegate>)clientDelegate;

- (void)connectWithUser:(SVUser *_Nonnull)user completion:(void(^_Nullable )(NSError *_Nullable error))completion;

- (void)startCallWithOpponent:(SVUser *_Nonnull)opponent;

- (void)hangup;

- (BOOL)hasActiveCall;

@property (nonatomic, assign, readonly) CallClientState state;
@property (nonatomic, assign, readonly) BOOL isConnecting;
@property (nonatomic, assign, readwrite) BOOL isConnected;
@property (nonatomic, weak, nullable) id<CallClientDelegate> delegate;

@end


#endif /* CallServiceProtocol_h */
