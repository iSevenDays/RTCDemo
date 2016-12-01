//
//  VideoStoryViewOutput.h
//  RTCDemo
//
//  Created by Anton Sokolchenko on 20/01/2016.
//  Copyright 2016 Anton Sokolchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VideoStoryViewOutput <NSObject>

/**
 @author Anton Sokolchenko

 Метод сообщает презентеру о том, что view готова к работе
 */
- (void)didTriggerViewReadyEvent;


- (void)didTriggerHangupButtonTaped;

- (void)didTriggerDataChannelButtonTaped;

@end
