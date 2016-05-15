//
//  VideoStoryModuleInput.h
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 20/01/2016.
//  Copyright 2016 Anton Sokolchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SVUser;

@protocol VideoStoryModuleInput <NSObject>

/**
 @author Anton Sokolchenko

 Configure module and start call with user
 */
- (void)connectToChatWithUser:(SVUser *)user callOpponent:(SVUser *)opponent;

- (void)acceptCallFromOpponent:(SVUser *)opponent;

@end