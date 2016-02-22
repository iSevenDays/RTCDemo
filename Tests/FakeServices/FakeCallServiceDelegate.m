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

- (void)client:(id<CallServiceProtocol>)client didChangeConnectionState:(RTCICEConnectionState)state {
	
}

- (void)client:(id<CallServiceProtocol>)client didChangeState:(enum CallServiceState)state {
	
}

- (void)client:(id<CallServiceProtocol>)client didError:(NSError *)error {
	
}

- (void)client:(id<CallServiceProtocol>)client didReceiveLocalVideoTrack:(id)localVideoTrack {
	
}

- (void)client:(id<CallServiceProtocol>)client didReceiveRemoteVideoTrack:(id)remoteVideoTrack {
	
}

@end
