//
//  VideoStoryInteractorOutput.h
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 20/01/2016.
//  Copyright 2016 Anton Sokolchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RTCVideoTrack;
@class RTCEAGLVideoView;
@class SVUser;

@protocol VideoStoryInteractorOutput <NSObject>

- (void)didConnectToChatWithUser:(nonnull SVUser *)user;

- (void)didHangup;

- (void)didFailToConnectToChat;

- (void)didSetLocalCaptureSession:(nonnull AVCaptureSession *)localCaptureSession;
- (void)didReceiveRemoteVideoTrackWithConfigurationBlock:(void(^_Nullable)(RTCEAGLVideoView *_Nullable renderer))block;

- (void)didOpenDataChannel;

- (void)didReceiveDataChannelStateReady;
- (void)didReceiveDataChannelStateNotReady;

/// Sender has sent us(receiver side) invitation to open image gallery and start sync
- (void)didReceiveInvitationToOpenImageGallery;

/// We have sent to a receiver an invitation to open image gallery and start sync
- (void)didSendInvitationToOpenImageGallery;

@end