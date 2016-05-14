//
//  VideoStoryViewInput.h
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 20/01/2016.
//  Copyright 2016 Anton Sokolchenko. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RTCEAGLVideoView;
@class SVUser;

@protocol VideoStoryViewInput <NSObject>

/**
 @author Anton Sokolchenko

 Метод настраивает начальный стейт view
 */
- (void)setupInitialState;

- (void)configureViewWithUser:(nonnull SVUser *)user;

- (void)showHangup;

- (void)showErrorConnect;
- (void)showErrorDataChannelNotReady;

- (void)setLocalVideoCaptureSession:(nonnull AVCaptureSession *)captureSession;

- (void)configureRemoteVideoViewWithBlock:(void (^_Nullable)(RTCEAGLVideoView *_Nullable renderer))block;

@end
