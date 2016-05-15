//
//  CallService.h
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 1/25/16.
//  Copyright © 2016 anton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CallServiceProtocol.h"
#import "CallServiceDataChannelAdditionsProtocol.h"
#import "SVMulticastDelegate.h"

@protocol CallServiceDelegate;
@protocol SVSignalingChannelProtocol;

@class SVUser;
@class RTCICEServer;
@class RTCMediaConstraints;
@class RTCConfiguration;
@class RTCPeerConnection;

@interface CallService : NSObject<CallServiceProtocol, CallServiceDataChannelAdditionsProtocol>

- (nullable instancetype)init NS_UNAVAILABLE;

- (nullable instancetype)initWithSignalingChannel:(nonnull id<SVSignalingChannelProtocol>)signalingChannel;

- (nullable instancetype)initWithSignalingChannel:(nonnull id<SVSignalingChannelProtocol>)signalingChannel callServiceDelegate:(nullable id<CallServiceDelegate>)callServiceDelegate;

- (nullable instancetype)initWithSignalingChannel:(nonnull id<SVSignalingChannelProtocol>)signalingChannel callServiceDelegate:(nullable id<CallServiceDelegate>)callServiceDelegate dataChannelDelegate:(nullable id<CallServiceDataChannelAdditionsDelegate>)dataChannelDelegate;

- (void)connectWithUser:(SVUser *_Nonnull)user completion:(void(^_Nullable )(NSError *_Nullable error))completion;

- (void)startCallWithOpponent:(SVUser *_Nonnull)opponent;

/// Clears session and sends hangup if -hasActiveCall YES
- (void)hangup;

/// @return YES if both initiatorUser and opponentUser are set
- (BOOL)hasActiveCall;

@property (nonatomic, strong, nonnull) SVMulticastDelegate<CallServiceDelegate> *multicastDelegate;
@property (nonatomic, strong, nonnull) SVMulticastDelegate<CallServiceDataChannelAdditionsDelegate> *multicastDataChannelDelegate;

@property (nonatomic, assign, readonly) CallServiceState state;
/// @return YES if signaling channel state is open
@property (nonatomic, assign, readonly) BOOL isConnecting;
/// @return YES if signaling channel state is established
@property (nonatomic, assign, readwrite) BOOL isConnected;

@property (nonatomic, strong, nonnull) NSMutableArray<RTCICEServer *> *iceServers;

@property (nonatomic, strong, nonnull) RTCMediaConstraints *defaultOfferConstraints;
@property (nonatomic, strong, nonnull) RTCMediaConstraints *defaultAnswerConstraints;
@property (nonatomic, strong, nonnull) RTCMediaConstraints *defaultPeerConnectionConstraints;
@property (nonatomic, strong, nonnull) RTCMediaConstraints *defaultMediaStreamConstraints;
@property (nonatomic, strong, nonnull) RTCConfiguration *defaultConfigurationWithCurrentICEServers;
@property (nonatomic, strong, nonnull) id<SVSignalingChannelProtocol> signalingChannel;
@property (nonatomic, strong, nullable) RTCPeerConnection *peerConnection;

@end
