//
//  VideoStoryRouter.m
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 20/01/2016.
//  Copyright 2016 Anton Sokolchenko. All rights reserved.
//

#import "VideoStoryRouter.h"
#import "VideoStoryModuleInput.h"

#import <ViperMcFlurry/ViperMcFlurry.h>

NSString *kVideoStoryToImageGalleryModuleSegue = @"VideoStoryToImageGalleryModuleSegue";

@implementation VideoStoryRouter

#pragma mark - Методы VideoStoryRouterInput

- (void)openImageGallery {
	[self.transitionHandler openModuleUsingSegue:kVideoStoryToImageGalleryModuleSegue];
}

@end