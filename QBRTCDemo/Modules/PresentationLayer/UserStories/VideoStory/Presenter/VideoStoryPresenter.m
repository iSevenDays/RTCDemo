//
//  VideoStoryPresenter.m
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 20/01/2016.
//  Copyright 2016 Anton Sokolchenko. All rights reserved.
//

#import "VideoStoryPresenter.h"

#import "VideoStoryViewInput.h"
#import "VideoStoryInteractorInput.h"
#import "VideoStoryRouterInput.h"

@implementation VideoStoryPresenter

#pragma mark - Методы VideoStoryModuleInput

- (void)configureModule {
    // Стартовая конфигурация модуля, не привязанная к состоянию view
}

#pragma mark - Методы VideoStoryViewOutput

- (void)didTriggerViewReadyEvent {
	[self.view setupInitialState];
}

- (void)didTriggerConnectWithUser1ButtonTaped {
	[self.interactor connectToChatWithUser1];
}

- (void)didTriggerConnectWithUser2ButtonTaped {
	[self.interactor connectToChatWithUser2];
}

- (void)didTriggerStartCallButtonTaped {
	[self.interactor startCall];
}

- (void)didTriggerHangupButtonTaped {
	[self.interactor hangup];
}

- (void)didTriggerDataChannelButtonTaped {
	[self.router openImageGallery];
}

#pragma mark - Методы VideoStoryInteractorOutput

- (void)didConnectToChatWithUser1 {
	[self.view configureViewWithUser1];
}

- (void)didConnectToChatWithUser2 {
	[self.view configureViewWithUser2];
}

- (void)didHangup {
	[self.view showHangup];
}

- (void)didFailToConnectToChat {
	[self.view showErrorConnect];
}

- (void)didSetLocalCaptureSession:(AVCaptureSession *)localCaptureSession {
	[self.view setLocalVideoCaptureSession:localCaptureSession];
}

- (void)didReceiveRemoteVideoTrackWithConfigurationBlock:(void (^_Nullable)(RTCEAGLVideoView * _Nullable))block {
	[self.view configureRemoteVideoViewWithBlock:block];
}

- (void)didOpenDataChannel {
	
}

@end