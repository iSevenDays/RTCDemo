//
//  VideoStoryAssembly.m
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 20/01/2016.
//  Copyright 2016 Anton Sokolchenko. All rights reserved.
//

#import "VideoStoryAssembly.h"

#import "VideoStoryViewController.h"
#import "VideoStoryInteractor.h"
#import "VideoStoryPresenter.h"
#import "VideoStoryRouter.h"

#import <ViperMcFlurry/ViperMcFlurry.h>

#import "CallService.h"
#import "CallServiceHelpers.h"
#import "WebRTCHelpers.h"
#import "QBSignalingChannel.h"

#if QBRTCDemo_s
	#import "QBRTCDemo_s-swift.h"
#elif QBRTCDemo
	#import "QBRTCDemo-swift.h"
#endif


static NSString *const kVideoStoryboardName = @"VideoStory";

@implementation VideoStoryAssembly

- (VideoStoryViewController *)viewVideoStoryModule {
	
    return [TyphoonDefinition withClass:[VideoStoryViewController class]
                          configuration:^(TyphoonDefinition *definition) {
                              [definition injectProperty:@selector(output)
                                                    with:[self presenterVideoStoryModule]];
                              [definition injectProperty:@selector(moduleInput)
                                                    with:[self presenterVideoStoryModule]];
                          }];
}

- (VideoStoryInteractor *)interactorVideoStoryModule {
    return [TyphoonDefinition withClass:[VideoStoryInteractor class]
                          configuration:^(TyphoonDefinition *definition) {
							  
                              [definition injectProperty:@selector(output)
                                                    with:[self presenterVideoStoryModule]];
							  
							  [definition injectProperty:@selector(callService)
													with:[self callService]];
                          }];
}

- (VideoStoryPresenter *)presenterVideoStoryModule {
    return [TyphoonDefinition withClass:[VideoStoryPresenter class]
                          configuration:^(TyphoonDefinition *definition) {
                              [definition injectProperty:@selector(view)
                                                    with:[self viewVideoStoryModule]];
                              [definition injectProperty:@selector(interactor)
                                                    with:[self interactorVideoStoryModule]];
                              [definition injectProperty:@selector(router)
                                                    with:[self routerVideoStoryModule]];
                          }];
}

- (VideoStoryRouter *)routerVideoStoryModule {
    return [TyphoonDefinition withClass:[VideoStoryRouter class]
                          configuration:^(TyphoonDefinition *definition) {
                              [definition injectProperty:@selector(transitionHandler)
                                                    with:[self viewVideoStoryModule]];
							  [definition injectProperty:@selector(callService) with:[self callService]];
                          }];
}

#pragma mark CallService

- (id<CallServiceProtocol, CallServiceDataChannelAdditionsProtocol>)callService {
	return [[ServicesProvider currentProvider] callService];
}

- (id<SVSignalingChannelProtocol>)signalingChannel {
	return [TyphoonDefinition withClass:[QBSignalingChannel class]];
}

- (UIStoryboard *)videoStoryStoryboard {
	return [TyphoonDefinition withClass:[TyphoonStoryboard class]
						  configuration:^(TyphoonDefinition *definition) {
							  [definition useInitializer:@selector(storyboardWithName:factory:bundle:)
											  parameters:^(TyphoonMethod *initializer) {
												  [initializer injectParameterWith:kVideoStoryboardName];
												  [initializer injectParameterWith:self];
												  [initializer injectParameterWith:nil];
											  }];
						  }];
}

@end