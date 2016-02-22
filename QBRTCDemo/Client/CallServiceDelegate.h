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

@protocol CallServiceDelegate <NSObject>

- (void)client:(id<CallServiceProtocol>)client didChangeConnectionState:(RTCICEConnectionState)state;
- (void)client:(id<CallServiceProtocol>)client didChangeState:(enum CallServiceState)state;
- (void)client:(id<CallServiceProtocol>)client didReceiveLocalVideoTrack:(RTCVideoTrack *)localVideoTrack;
- (void)client:(id<CallServiceProtocol>)client didReceiveRemoteVideoTrack:(RTCVideoTrack *)remoteVideoTrack;
- (void)client:(id<CallServiceProtocol>)client didError:(NSError *)error;

@end
