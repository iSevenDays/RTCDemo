//
//  SVUser+QBUUser.m
//  RTCDemo
//
//  Created by Anton Sokolchenko on 3/31/16.
//  Copyright © 2016 anton. All rights reserved.
//

#import "SVUser+QBUUser.h"

@implementation SVUser (QBUUser)

- (instancetype)initWithQBUUser:(QBUUser *)user {
	return [[SVUser alloc] initWithID:@(user.ID) login:user.login  fullName:user.fullName password:user.password tags:user.tags];
}

@end
