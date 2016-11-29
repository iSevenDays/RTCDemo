//
//  VideoStoryAssembly_Testable.h
//  RTCDemo
//
//  Created by Anton Sokolchenko on 20/01/2016.
//  Copyright 2016 Anton Sokolchenko. All rights reserved.
//

#import "VideoStoryAssembly.h"

@class VideoStoryViewController;
@class VideoStoryInteractor;
@class VideoStoryPresenter;
@class VideoStoryRouter;

@interface VideoStoryAssembly ()

- (VideoStoryViewController *)viewVideoStoryModule;
- (VideoStoryPresenter *)presenterVideoStoryModule;
- (VideoStoryInteractor *)interactorVideoStoryModule;
- (VideoStoryRouter *)routerVideoStoryModule;

@end
