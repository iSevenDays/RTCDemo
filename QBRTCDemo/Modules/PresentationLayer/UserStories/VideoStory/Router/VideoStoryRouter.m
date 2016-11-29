//
//  VideoStoryRouter.m
//  RTCDemo
//
//  Created by Anton Sokolchenko on 20/01/2016.
//  Copyright 2016 Anton Sokolchenko. All rights reserved.
//

#ifdef QBRTCDemo_s
	#import "QBRTCDemo_s-Swift.h"
#elif defined(QBRTCDemo)
	#import "QBRTCDemo-Swift.h"
#endif

#import "VideoStoryRouter.h"
#import "VideoStoryModuleInput.h"
#import <ViperMcFlurry/ViperMcFlurry.h>
NSString *kVideoStoryToImageGalleryModuleSegue = @"VideoStoryToImageGalleryModuleSegue";

@protocol CallServiceProtocol;
@protocol CallServiceDataChannelAdditionsProtocol;

@interface VideoStoryRouter()
@property (nonatomic, strong) id<CallServiceProtocol, CallServiceDataChannelAdditionsProtocol> callService;
@end

@implementation VideoStoryRouter

#pragma mark - Методы VideoStoryRouterInput

- (void)openImageGallery {
	NSParameterAssert(self.callService);
	
	[[self.transitionHandler openModuleUsingSegue:kVideoStoryToImageGalleryModuleSegue] thenChainUsingBlock:^id<RamblerViperModuleOutput>(id<ImageGalleryStoryModuleInput> moduleInput) {
		NSCParameterAssert(moduleInput);
		
		[moduleInput configureModule];
		
		return nil;
	}];
}

@end
