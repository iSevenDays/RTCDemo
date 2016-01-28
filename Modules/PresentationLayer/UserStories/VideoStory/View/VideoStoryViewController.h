//
//  VideoStoryViewController.h
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 20/01/2016.
//  Copyright 2016 Anton Sokolchenko. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VideoStoryViewInput.h"

@protocol VideoStoryViewOutput;

@class RTCEAGLVideoView;
@class RTCVideoTrack;
@class RTCCameraPreviewView;

@interface VideoStoryViewController : UIViewController <VideoStoryViewInput>

@property (nonatomic, strong) id<VideoStoryViewOutput> output;

@property(nonatomic, strong) RTCVideoTrack *localVideoTrack;
@property(nonatomic, strong) RTCVideoTrack *remoteVideoTrack;

#pragma mark IBOutlets

@property (weak, nonatomic) IBOutlet UIButton *btnConnectWithUser1;
@property (weak, nonatomic) IBOutlet UIButton *btnConnectWithUser2;
@property (weak, nonatomic) IBOutlet UIButton *btnStartCall;
@property (weak, nonatomic) IBOutlet UIButton *btnOpenDataChannel;
@property (weak, nonatomic) IBOutlet UIButton *btnHangup;
@property (weak, nonatomic) IBOutlet UILabel *lblConnected;
@property (weak, nonatomic) IBOutlet UILabel *lblState;
@property (weak, nonatomic) IBOutlet UILabel *lblIceState;
@property (weak, nonatomic) IBOutlet RTCEAGLVideoView *viewRemote;
@property (weak, nonatomic) IBOutlet RTCCameraPreviewView *viewLocal;


#pragma mark IBActions

- (IBAction)didTapButtonConnectWithUser1:(id)sender;
- (IBAction)didTapButtonConnectWithUser2:(id)sender;
- (IBAction)didTapButtonStartCall:(id)sender;
- (IBAction)didTapButtonHangup:(id)sender;

@end