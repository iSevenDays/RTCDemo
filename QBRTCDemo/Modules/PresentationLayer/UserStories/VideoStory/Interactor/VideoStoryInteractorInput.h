//
//  VideoStoryInteractorInput.h
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 20/01/2016.
//  Copyright 2016 Anton Sokolchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VideoStoryInteractorInput <NSObject>

- (void)connectToChatWithUser1;
- (void)connectToChatWithUser2;

- (void)startCall;
- (void)hangup;

- (BOOL)isReadyForDataChannel;

@end