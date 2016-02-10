//
//  CallService_Private.h
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 2/9/16.
//  Copyright © 2016 anton. All rights reserved.
//

#ifndef CallService_Private_h
#define CallService_Private_h

#import "CallService.h"
@class SVSignalingMessage;

@interface CallService ()

@property (nonatomic, strong, nullable) id<SVSignalingChannelProtocol> signalingChannel;

- (void)processSignalingMessage:(nonnull SVSignalingMessage *)message;
- (void)clearSession;

- (void)sendHangupToUser:(nonnull SVUser *)user completion:(void(^_Nullable)(NSError * _Nullable error))completion;
- (void)sendRejectToUser:(nonnull SVUser *)user completion:(void(^_Nullable)(NSError * _Nullable error))completion;

@end

#endif /* CallService_Private_h */
