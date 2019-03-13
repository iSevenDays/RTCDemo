//
//  SVUser+QBUUser.h
//  RTCDemo
//
//  Created by Anton Sokolchenko on 3/31/16.
//  Copyright © 2016 anton. All rights reserved.
//
#import "SVUser.h"
@class QBUUser;

@interface SVUser (QBUUser)

- (instancetype)initWithQBUUser:(QBUUser *)user;

@end
