//
//  VideoCallStoryAssembly_Testable.h
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 01/12/2016.
//  Copyright 2016 Anton Sokolchenko. All rights reserved.
//

#import "VideoCallStoryAssembly.h"

@class VideoCallStoryViewController;
@class VideoCallStoryInteractor;
@class VideoCallStoryPresenter;
@class VideoCallStoryRouter;

@interface VideoCallStoryAssembly ()

- (VideoCallStoryViewController *)viewVideoCallStoryModule;
- (VideoCallStoryPresenter *)presenterVideoCallStoryModule;
- (VideoCallStoryInteractor *)interactorVideoCallStoryModule;
- (VideoCallStoryRouter *)routerVideoCallStoryModule;

@end