//
//  VideoStoryRouter.h
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 20/01/2016.
//  Copyright 2016 Anton Sokolchenko. All rights reserved.
//

#import "VideoStoryRouterInput.h"

@protocol RamblerViperModuleTransitionHandlerProtocol;

@interface VideoStoryRouter : NSObject <VideoStoryRouterInput>

@property (nonatomic, weak) id<RamblerViperModuleTransitionHandlerProtocol> transitionHandler;

@end