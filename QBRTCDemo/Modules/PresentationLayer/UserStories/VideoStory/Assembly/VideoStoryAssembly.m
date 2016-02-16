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

#import "ServiceComponents.h"

#import <ViperMcFlurry/ViperMcFlurry.h>

#import "CallService.h"
#import "WebRTCHelpers.h"
#import "QBSignalingChannel.h"

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
                          }];
}

#pragma mark CallService

- (id<CallServiceProtocol>)callService {
	return [TyphoonDefinition withClass:[CallService class] configuration:^(TyphoonDefinition *definition) {
		[definition useInitializer:@selector(initWithSignalingChannel:clientDelegate:dataChannelDelegate:) parameters:^(TyphoonMethod *initializer) {

			[initializer injectParameterWith:[self signalingChannel]];
			[initializer injectParameterWith:[self interactorVideoStoryModule]];
			[initializer injectParameterWith:[self interactorVideoStoryModule]];
		}];
		
		[definition injectProperty:@selector(defaultOfferConstraints)
							  with:[WebRTCHelpers defaultOfferConstraints]];
		[definition injectProperty:@selector(defaultAnswerConstraints)
							  with:[WebRTCHelpers defaultAnswerConstraints]];
		[definition injectProperty:@selector(defaultPeerConnectionConstraints)
							  with:[WebRTCHelpers defaultPeerConnectionConstraints]];
		[definition injectProperty:@selector(defaultMediaStreamConstraints)
							  with:[WebRTCHelpers defaultMediaStreamConstraints]];
		
		[definition injectProperty:@selector(iceServers)
							  with:[WebRTCHelpers defaultIceServers]];

		[definition injectProperty:@selector(defaultConfigurationWithCurrentICEServers) with:[WebRTCHelpers defaultConfigurationWithCurrentICEServers]];
	}];
}

- (id<SVSignalingChannelProtocol>)signalingChannel {
	return [TyphoonDefinition withClass:[QBSignalingChannel class]];
}

@end