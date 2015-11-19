//
//  SVClientDelegate.h
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 11/18/15.
//  Copyright © 2015 anton. All rights reserved.
//

#import <RTCVideoTrack.h>
@class SVClient;
enum SVClientState : NSInteger;

@protocol SVClientDelegate <NSObject>

- (void)client:(SVClient *)client didChangeState:(enum SVClientState)state;
- (void)client:(SVClient *)client didChangeConnectionState:(RTCICEConnectionState)state;
- (void)client:(SVClient *)client didReceiveLocalVideoTrack:(RTCVideoTrack *)localVideoTrack;
- (void)client:(SVClient *)client didReceiveRemoteVideoTrack:(RTCVideoTrack *)remoteVideoTrack;
- (void)client:(SVClient *)client didError:(NSError *)error;

@end
