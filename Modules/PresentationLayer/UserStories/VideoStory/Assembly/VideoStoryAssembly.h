//
//  VideoStoryAssembly.h
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 20/01/2016.
//  Copyright 2016 Anton Sokolchenko. All rights reserved.
//

#import <Typhoon/Typhoon.h>
#import <RamblerTyphoonUtils/AssemblyCollector.h>

#import "ModuleAssemblyBase.h"

/**
 @author Anton Sokolchenko

 VideoStory module
 */

@class VideoStoryViewController;
@class VideoStoryInteractor;
@class VideoStoryPresenter;
@class VideoStoryRouter;

@protocol CallServiceProtocol;
@protocol SVSignalingChannelProtocol;

@interface VideoStoryAssembly : ModuleAssemblyBase <RamblerInitialAssembly>

- (VideoStoryViewController *)viewVideoStoryModule;
- (VideoStoryInteractor *)interactorVideoStoryModule;
- (VideoStoryPresenter *)presenterVideoStoryModule;
- (VideoStoryRouter *)routerVideoStoryModule;

- (id<CallServiceProtocol>)callService;
- (id<SVSignalingChannelProtocol>)signalingChannel;

@end