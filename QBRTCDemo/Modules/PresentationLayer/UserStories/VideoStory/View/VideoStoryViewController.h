//
//  VideoStoryViewController.h
//  RTCDemo
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

#pragma mark IBOutlets

@property (weak, nonatomic) IBOutlet UIButton *btnStartCall;
@property (weak, nonatomic) IBOutlet UIButton *btnOpenDataChannel;
@property (weak, nonatomic) IBOutlet UIButton *btnHangup;
@property (weak, nonatomic) IBOutlet UILabel *lblConnected;
@property (weak, nonatomic) IBOutlet UILabel *lblState;
@property (weak, nonatomic) IBOutlet UILabel *lblIceState;
@property (weak, nonatomic) IBOutlet RTCEAGLVideoView *viewRemote;
@property (weak, nonatomic) IBOutlet RTCCameraPreviewView *viewLocal;


#pragma mark IBActions

- (IBAction)didTapButtonStartCall:(id)sender;
- (IBAction)didTapButtonHangup:(id)sender;
- (IBAction)didTapButtonDataChannelImageGallery:(id)sender;

@end
