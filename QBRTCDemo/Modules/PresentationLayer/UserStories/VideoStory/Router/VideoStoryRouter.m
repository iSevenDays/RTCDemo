//
//  VideoStoryRouter.m
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 20/01/2016.
//  Copyright 2016 Anton Sokolchenko. All rights reserved.
//

#import "VideoStoryRouter.h"
#import "VideoStoryModuleInput.h"
#import "QBRTCDemo_s-Swift.h"

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
		
		[moduleInput configureWithCallService:self.callService];
		return nil;
	}];
}

@end