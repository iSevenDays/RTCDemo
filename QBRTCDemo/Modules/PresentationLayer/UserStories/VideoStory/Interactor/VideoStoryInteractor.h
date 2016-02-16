//
//  VideoStoryInteractor.h
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 20/01/2016.
//  Copyright 2016 Anton Sokolchenko. All rights reserved.
//

#import "VideoStoryInteractorInput.h"
#import "CallClientDelegate.h"
#import "CallServiceDataChannelAdditionsDelegate.h"

@protocol VideoStoryInteractorOutput;
@protocol CallServiceProtocol;
@protocol CallServiceDataChannelAdditionsProtocol;

@interface VideoStoryInteractor : NSObject <VideoStoryInteractorInput, CallClientDelegate, CallServiceDataChannelAdditionsDelegate>

@property (nonatomic, weak) id<VideoStoryInteractorOutput> output;

@property (nonatomic, strong) id<CallServiceProtocol, CallServiceDataChannelAdditionsProtocol> callService;

@end