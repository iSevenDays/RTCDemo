//
//  VideoStoryPresenter.h
//  RTCDemo
//
//  Created by Anton Sokolchenko on 20/01/2016.
//  Copyright 2016 Anton Sokolchenko. All rights reserved.
//

#import "VideoStoryViewOutput.h"
#import "VideoStoryModuleInput.h"

#if QBRTCDemo_s
#import "QBRTCDemo_s-Swift.h"
#elif QBRTCDemo
#import "QBRTCDemo-Swift.h"
#endif

@protocol VideoStoryViewInput;
@protocol VideoStoryInteractorInput;
@protocol VideoStoryInteractorOutput;
@protocol VideoStoryRouterInput;

@interface VideoStoryPresenter : NSObject <VideoStoryModuleInput, VideoStoryViewOutput, VideoStoryInteractorOutput>

@property (nonatomic, weak) id<VideoStoryViewInput> view;
@property (nonatomic, strong) id<VideoStoryInteractorInput> interactor;
@property (nonatomic, strong) id<VideoStoryRouterInput> router;

@end
