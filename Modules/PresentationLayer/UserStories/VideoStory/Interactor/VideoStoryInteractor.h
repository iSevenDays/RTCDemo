//
//  VideoStoryInteractor.h
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 20/01/2016.
//  Copyright 2016 Anton Sokolchenko. All rights reserved.
//

#import "VideoStoryInteractorInput.h"

@protocol VideoStoryInteractorOutput;
@protocol CallServiceProtocol;

@interface VideoStoryInteractor : NSObject <VideoStoryInteractorInput>

@property (nonatomic, weak) id<VideoStoryInteractorOutput> output;

@property (nonatomic, strong) id<CallServiceProtocol> callService;

@end