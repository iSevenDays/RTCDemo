//
//  CallServiceProtocol.h
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 1/25/16.
//  Copyright © 2016 anton. All rights reserved.
//

#ifndef CallServiceProtocol_h
#define CallServiceProtocol_h

@protocol SVSignalingChannelProtocol;
@protocol SVClientDelegate;

@class SVUser;

@protocol CallServiceProtocol <NSObject>

- (nullable instancetype)initWithSignalingChannel:(nonnull id<SVSignalingChannelProtocol>)signalingChannel clientDelegate:(nonnull id<SVClientDelegate>)clientDelegate;

- (void)connectWithUser:(SVUser *_Nonnull)user completion:(void(^_Nullable )(NSError *_Nullable error))completion;

- (void)startCallWithOpponent:(SVUser *_Nonnull)opponent;

- (void)openDataChannel;

- (void)hangup;

@property (nonatomic, weak, nullable) id<SVClientDelegate> delegate;

@end


#endif /* CallServiceProtocol_h */
