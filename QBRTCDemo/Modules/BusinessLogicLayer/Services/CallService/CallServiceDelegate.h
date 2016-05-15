//
//  CallServiceDelegate.h
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 11/18/15.
//  Copyright © 2015 anton. All rights reserved.
//

#import <RTCVideoTrack.h>
#import <RTCTypes.h>

enum RTCICEConnectionState : NSInteger;
enum CallServiceState : NSInteger;

@protocol CallServiceProtocol;
@class SVUser;

@protocol CallServiceDelegate <NSObject>

- (void)callService:(id<CallServiceProtocol>)callService didReceiveCallRequestFromOpponent:(SVUser *)opponent;

- (void)callService:(id<CallServiceProtocol>)callService didChangeConnectionState:(RTCICEConnectionState)state;
- (void)callService:(id<CallServiceProtocol>)callService didChangeState:(enum CallServiceState)state;
- (void)callService:(id<CallServiceProtocol>)callService didReceiveLocalVideoTrack:(RTCVideoTrack *)localVideoTrack;
- (void)callService:(id<CallServiceProtocol>)callService didReceiveRemoteVideoTrack:(RTCVideoTrack *)remoteVideoTrack;
- (void)callService:(id<CallServiceProtocol>)callService didError:(NSError *)error;

@end
