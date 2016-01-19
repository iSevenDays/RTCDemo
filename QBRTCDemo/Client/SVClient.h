//
//  SVClient.h
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 11/18/15.
//  Copyright © 2015 anton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SVSignalingChannelProtocol.h"
#import "SVClientDelegate.h"

typedef NS_ENUM(NSInteger, SVClientState) {
	// Disconnected from servers.
	kClientStateDisconnected,
	// Connecting to servers.
	kClientStateConnecting,
	// Connected to chat.
	kClientStateConnected,
};

@interface SVClient : NSObject

- (nullable instancetype)initWithSignalingChannel:(nonnull id<SVSignalingChannelProtocol>)signalingChannel clientDelegate:(nonnull id<SVClientDelegate>)clientDelegate;

- (void)connectWithUser:(SVUser *_Nonnull)user completion:(void(^_Nullable )(NSError *_Nullable error))completion;

- (void)startCallWithOpponent:(SVUser *_Nonnull)opponent;

- (void)openDataChannel;

- (void)hangup;

@property (nonatomic, weak, nullable) id<SVClientDelegate> delegate;

@end
