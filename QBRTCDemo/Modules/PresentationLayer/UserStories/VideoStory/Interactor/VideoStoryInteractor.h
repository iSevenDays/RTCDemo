//
//  VideoStoryInteractor.h
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 20/01/2016.
//  Copyright 2016 Anton Sokolchenko. All rights reserved.
//

#import "VideoStoryInteractorInput.h"
#import "CallClientDelegate.h"

@protocol VideoStoryInteractorOutput;
@protocol CallServiceProtocol;

@interface VideoStoryInteractor : NSObject <VideoStoryInteractorInput, CallClientDelegate>

@property (nonatomic, weak) id<VideoStoryInteractorOutput> output;

@property (nonatomic, strong) id<CallServiceProtocol> callService;

@end

@protocol CallServiceProtocol_Private;

@interface VideoStoryInteractor (PrivateCallService)
@property (nonatomic, strong, readwrite) id<CallServiceProtocol_Private> callService;
@end