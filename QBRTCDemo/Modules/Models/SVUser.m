//
//  SVUser.m
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 11/17/15.
//  Copyright © 2015 anton. All rights reserved.
//

#import "SVUser.h"

@implementation SVUser

+ (instancetype)userWithID:(NSNumber *)ID login:(NSString *)login password:(NSString *)password {
	return [[self alloc] initWithID:ID login:login password:password];
}

- (instancetype)initWithID:(NSNumber *)ID login:(NSString *)login password:(NSString *)password {
	self = [super init];
	if (self) {
		self.ID = ID;
		self.login = login;
		self.password = password;
	}
	return self;
}

- (BOOL)isEqual:(id)object {
	if (![object isKindOfClass:[SVUser class]]) {
		return NO;
	}
	SVUser *obj = object;
	return [self.ID isEqualToNumber:obj.ID] && [self.login isEqualToString:obj.login] && [self.password isEqualToString:obj.password];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<SVUser %p> id:%@ login:%@ password:%@", self, self.ID, self.login, self.password];
}

@end
