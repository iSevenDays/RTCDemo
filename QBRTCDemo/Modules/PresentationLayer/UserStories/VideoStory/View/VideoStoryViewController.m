//
//  VideoStoryViewController.m
//  RTCDemo
//
//  Created by Anton Sokolchenko on 20/01/2016.
//  Copyright 2016 Anton Sokolchenko. All rights reserved.
//

#import "VideoStoryViewController.h"

#import "VideoStoryViewOutput.h"

#import <RTCVideoTrack.h>
#import <RTCAVFoundationVideoSource.h>
#import <RTCCameraPreviewView.h>

#import <RTCEAGLVideoView.h>

@implementation VideoStoryViewController

#pragma mark - Lifecycle methods

- (void)viewDidLoad {
	[super viewDidLoad];

	[self.output didTriggerViewReadyEvent];
}

#pragma mark - VideoStoryViewInput methods

- (void)setupInitialState {
	// В этом методе происходит настройка параметров view, зависящих от ее жизненого цикла (создание элементов, анимации и пр.)
}

- (void)configureViewWithUser:(SVUser *)user {
//	self.btnConnectWithUser1.backgroundColor = [UIColor greenColor];
}

- (void)showHangup {
	[self.viewRemote renderFrame:nil];
}

- (void)showErrorConnect {
	[[[UIAlertView alloc] initWithTitle:@"Error" message:@"Cannot connect" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

- (void)showErrorDataChannelNotReady {
	[[[UIAlertView alloc] initWithTitle:@"Error" message:@"Data channel not ready" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

- (void)setLocalVideoCaptureSession:(AVCaptureSession *)captureSession {
	self.viewLocal.captureSession = captureSession;
}

- (void)configureRemoteVideoViewWithBlock:(void (^)(RTCEAGLVideoView *_Nullable renderer))block {
	block(self.viewRemote);
}

#pragma mark - VideoStoryViewOutput methods

- (IBAction)didTapButtonStartCall:(id)sender {
	[self.output didTriggerStartCallButtonTaped];
}

- (IBAction)didTapButtonHangup:(id)sender {
	[self.output didTriggerHangupButtonTaped];
}

- (IBAction)didTapButtonDataChannelImageGallery:(id)sender {
	[self.output didTriggerDataChannelButtonTaped];
}


@end
