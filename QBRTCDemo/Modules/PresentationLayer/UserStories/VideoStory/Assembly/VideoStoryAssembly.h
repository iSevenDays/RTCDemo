//
//  VideoStoryAssembly.h
//  RTCDemo
//
//  Created by Anton Sokolchenko on 20/01/2016.
//  Copyright 2016 Anton Sokolchenko. All rights reserved.
//

#import <Typhoon/Typhoon.h>
#import <RamblerTyphoonUtils/AssemblyCollector.h>


/**
 @author Anton Sokolchenko

 VideoStory module
 */

@class VideoStoryViewController;
@class VideoStoryInteractor;
@class VideoStoryPresenter;
@class VideoStoryRouter;

@protocol CallServiceProtocol;
@protocol CallServiceDataChannelAdditionsProtocol;
@protocol SVSignalingChannelProtocol;

@interface VideoStoryAssembly : TyphoonAssembly

- (VideoStoryViewController *)viewVideoStoryModule;
- (VideoStoryInteractor *)interactorVideoStoryModule;
- (VideoStoryPresenter *)presenterVideoStoryModule;
- (VideoStoryRouter *)routerVideoStoryModule;

- (id<CallServiceProtocol, CallServiceDataChannelAdditionsProtocol>)callService;

- (UIStoryboard *)videoStoryStoryboard;
@end
