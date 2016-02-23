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
@class RTCPeerConnection;

@interface CallService ()

@property (nonatomic, strong, nullable) id<SVSignalingChannelProtocol> signalingChannel;
@property (nonatomic, strong, nullable) RTCPeerConnection *peerConnection;

- (void)processSignalingMessage:(nonnull SVSignalingMessage *)message;
- (void)clearSession;

- (void)sendHangupToUser:(nonnull SVUser *)user completion:(void(^_Nullable)(NSError * _Nullable error))completion;
- (void)sendRejectToUser:(nonnull SVUser *)user completion:(void(^_Nullable)(NSError * _Nullable error))completion;

- (void)drainMessageQueueIfReady;

- (void)peerConnection:(nullable RTCPeerConnection *)peerConnection didSetSessionDescriptionWithError:(nullable NSError *)error;

@end

#endif /* CallService_Private_h */
