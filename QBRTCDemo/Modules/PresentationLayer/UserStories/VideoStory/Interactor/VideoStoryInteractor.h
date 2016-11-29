//
//  VideoStoryInteractor.h
//  RTCDemo
//
//  Created by Anton Sokolchenko on 20/01/2016.
//  Copyright 2016 Anton Sokolchenko. All rights reserved.
//

#import "VideoStoryInteractorInput.h"
#import "CallServiceDelegate.h"
#import "CallServiceDataChannelAdditionsDelegate.h"

@protocol VideoStoryInteractorOutput;
@protocol CallServiceProtocol;
@protocol CallServiceDataChannelAdditionsProtocol;

@interface VideoStoryInteractor : NSObject <VideoStoryInteractorInput, CallServiceDelegate, CallServiceDataChannelAdditionsDelegate>

@property (nonatomic, weak) id<VideoStoryInteractorOutput> output;

@property (nonatomic, strong) id<CallServiceProtocol, CallServiceDataChannelAdditionsProtocol> callService;

@end
