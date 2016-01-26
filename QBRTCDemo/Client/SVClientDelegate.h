//
//  SVClientDelegate.h
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 11/18/15.
//  Copyright © 2015 anton. All rights reserved.
//

#import <RTCTypes.h>
#import <RTCVideoTrack.h>

@class SVClient;

enum SVClientState : NSInteger;
@protocol CallServiceProtocol;

@protocol SVClientDelegate <NSObject>

- (void)client:(id<CallServiceProtocol>)client didChangeConnectionState:(RTCICEConnectionState)state;
- (void)client:(id<CallServiceProtocol>)client didChangeState:(enum SVClientState)state;
- (void)client:(id<CallServiceProtocol>)client didReceiveLocalVideoTrack:(RTCVideoTrack *)localVideoTrack;
- (void)client:(id<CallServiceProtocol>)client didReceiveRemoteVideoTrack:(RTCVideoTrack *)remoteVideoTrack;
- (void)client:(id<CallServiceProtocol>)client didError:(NSError *)error;

@end
