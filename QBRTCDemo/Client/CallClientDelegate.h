//
//  CallClientDelegate.h
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 11/18/15.
//  Copyright © 2015 anton. All rights reserved.
//

#import <RTCTypes.h>
#import <RTCVideoTrack.h>
#import "RTCTypes.h"


enum CallClientState : NSInteger;
@protocol CallServiceProtocol;

@protocol CallClientDelegate <NSObject>

- (void)client:(id<CallServiceProtocol>)client didChangeConnectionState:(RTCICEConnectionState)state;
- (void)client:(id<CallServiceProtocol>)client didChangeState:(enum CallClientState)state;
- (void)client:(id<CallServiceProtocol>)client didReceiveLocalVideoTrack:(RTCVideoTrack *)localVideoTrack;
- (void)client:(id<CallServiceProtocol>)client didReceiveRemoteVideoTrack:(RTCVideoTrack *)remoteVideoTrack;
- (void)client:(id<CallServiceProtocol>)client didError:(NSError *)error;

@end
