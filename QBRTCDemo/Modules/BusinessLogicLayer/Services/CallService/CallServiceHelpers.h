//
//  CallServiceHelpers.h
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 2/9/16.
//  Copyright © 2016 anton. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SVUser;

@interface CallServiceHelpers : NSObject


+ (SVUser *)user1;
+ (SVUser *)user2;

+ (NSString *)offerSDP;

@end
