//
//  FakeCallServiceDelegate.m
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 1/28/16.
//  Copyright © 2016 anton. All rights reserved.
//

#import "FakeCallServiceDelegate.h"
#import "CallServiceDelegate.h"

@implementation FakeCallServiceDelegate

- (void)callService:(id<CallServiceProtocol>)callService didChangeConnectionState:(RTCICEConnectionState)state {
	
}

- (void)callService:(id<CallServiceProtocol>)callService didChangeState:(enum CallServiceState)state {
	
}

- (void)callService:(id<CallServiceProtocol>)callService didError:(NSError *)error {
	
}

- (void)callService:(id<CallServiceProtocol>)callService didReceiveLocalVideoTrack:(id)localVideoTrack {
	
}

- (void)callService:(id<CallServiceProtocol>)callService didReceiveRemoteVideoTrack:(id)remoteVideoTrack {
	
}

@end
