//
//  VideoStoryPresenter.h
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 20/01/2016.
//  Copyright 2016 Anton Sokolchenko. All rights reserved.
//

#import "VideoStoryViewOutput.h"
#import "VideoStoryInteractorOutput.h"
#import "VideoStoryModuleInput.h"

@protocol VideoStoryViewInput;
@protocol VideoStoryInteractorInput;
@protocol VideoStoryRouterInput;

@interface VideoStoryPresenter : NSObject <VideoStoryModuleInput, VideoStoryViewOutput, VideoStoryInteractorOutput>

@property (nonatomic, weak) id<VideoStoryViewInput> view;
@property (nonatomic, strong) id<VideoStoryInteractorInput> interactor;
@property (nonatomic, strong) id<VideoStoryRouterInput> router;

@end