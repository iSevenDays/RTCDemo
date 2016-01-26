//
//  VideoStoryModuleInput.h
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 20/01/2016.
//  Copyright 2016 Anton Sokolchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VideoStoryModuleInput <NSObject>

/**
 @author Anton Sokolchenko

 Метод инициирует стартовую конфигурацию текущего модуля
 */
- (void)configureModule;

@end