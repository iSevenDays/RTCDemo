//
//  VideoStoryInteractorOutput.h
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 20/01/2016.
//  Copyright 2016 Anton Sokolchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RTCVideoTrack;

@protocol VideoStoryInteractorOutput <NSObject>

- (void)didConnectToChatWithUser1;
- (void)didConnectToChatWithUser2;

- (void)didFailToConnectToChat;

- (void)didReceiveLocalVideoTrack:(RTCVideoTrack *)localVideoTrack;

@end