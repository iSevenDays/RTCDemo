//
//  VideoStoryPresenter.m
//  RTCDemo
//
//  Created by Anton Sokolchenko on 20/01/2016.
//  Copyright 2016 Anton Sokolchenko. All rights reserved.
//

#import "VideoStoryPresenter.h"

#import "VideoStoryViewInput.h"
#import "VideoStoryInteractorInput.h"
#import "VideoStoryRouterInput.h"

@implementation VideoStoryPresenter

#pragma mark - Methods VideoStoryModuleInput

- (void)connectToChatWithUser:(SVUser *)user callOpponent:(SVUser *)opponent {
	[self.interactor connectToChatWithUser:user callOpponent:opponent];
}

- (void)acceptCallFromOpponent:(SVUser *)opponent {
	[self.interactor acceptCallFromOpponent:opponent];
}

#pragma mark - Methods VideoStoryViewOutput

- (void)didTriggerViewReadyEvent {
	[self.view setupInitialState];
}

- (void)didTriggerStartCallButtonTaped {
	[self.interactor startCallWithOpponent:nil];
}

- (void)didTriggerHangupButtonTaped {
	[self.interactor hangup];
}

- (void)didTriggerDataChannelButtonTaped {
	[self.interactor sendInvitationMessageAndOpenImageGallery];
}

#pragma mark - Methods VideoStoryInteractorOutput

- (void)didConnectToChatWithUser:(SVUser *)user {
	[self.view configureViewWithUser:user];
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

- (void)didReceiveDataChannelStateReady {
	// do nothing
}

- (void)didReceiveInvitationToOpenImageGallery {
	[self.router openImageGallery];
}

- (void)didSendInvitationToOpenImageGallery {
	[self.router openImageGallery];
}

- (void)didReceiveDataChannelStateNotReady {
	[self.view showErrorDataChannelNotReady];
}

- (void)didOpenDataChannel {
	
}

@end
