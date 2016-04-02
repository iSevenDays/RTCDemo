//
//  SVUser+QBUUser.m
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 3/31/16.
//  Copyright © 2016 anton. All rights reserved.
//

#import "SVUser+QBUUser.h"

@implementation SVUser (QBUUser)

- (instancetype)initWithQBUUser:(QBUUser *)user {
	return [SVUser userWithID:@(user.ID) login:user.login password:user.password tags:user.tags];
}

@end
