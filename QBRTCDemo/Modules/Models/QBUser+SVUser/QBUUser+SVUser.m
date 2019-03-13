//
//  QBUUser+SVUser.m
//  RTCDemo
//
//  Created by Anton Sokolchenko on 11/17/15.
//  Copyright © 2015 anton. All rights reserved.
//

#import "QBUUser+SVUser.h"
#import "SVUser.h"

@implementation QBUUser (SVUser)

+ (instancetype)userWithSVUser:(SVUser *)svuser {
	QBUUser *qbuser = [QBUUser user];
	qbuser.ID = svuser.ID.unsignedIntegerValue;
	qbuser.login = svuser.login;
	qbuser.password = svuser.password;
	qbuser.tags = [svuser.tags mutableCopy];
	qbuser.fullName = svuser.fullName;
	return qbuser;
}

@end
