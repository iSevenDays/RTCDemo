//
//  SVSignalingChannelProtocol.h
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 11/16/15.
//  Copyright © 2015 anton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SVSignalingChannelState.h"
#import "SVSignalingChannelDelegate.h"
#import "SVSignalingMessage.h"
#import "SVUser.h"

@protocol SVSignalingChannelProtocol <NSObject>
@required

- (void)connectWithUser:(SVUser *_Nonnull)user completion:(void(^_Nullable)(NSError *_Nullable error))completion;

- (void)sendMessage:(__kindof SVSignalingMessage *_Nonnull)message toUser:(__kindof SVUser *_Nonnull)user completion:(void(^_Nullable)(NSError *_Nullable error))completion;

- (BOOL)isConnected;

@property (nonatomic, strong, nonnull) NSString *state;
@property (nonatomic, strong, nullable) SVUser *user; // currently connected user
@property (nonatomic, weak) id <SVSignalingChannelDelegate> delegate;

@optional

- (void)disconnectWithCompletion:(void(^_Nullable)(NSError *_Nullable))completion;

@end
