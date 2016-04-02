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

+ (instancetype)userWithID:(NSNumber *)ID login:(NSString *)login password:(NSString *)password tags:(NSArray<NSString *> *)tags {
	return [[self alloc] initWithID:ID login:login password:password tags:tags];
}

- (instancetype)initWithID:(NSNumber *)ID login:(NSString *)login password:(NSString *)password {
	return [self initWithID:ID login:login password:password tags:nil];
}

- (instancetype)initWithID:(NSNumber *)ID login:(NSString *)login password:(NSString *)password tags:(NSArray<NSString *> *)tags {
	self = [super init];
	if (self) {
		self.ID = ID;
		self.login = login;
		self.password = password;
		self.tags = tags;
	}
	return self;
}

- (BOOL)isEqual:(id)object {
	if (self == object) {
		return YES;
	}
	
	if (![object isKindOfClass:[SVUser class]]) {
		return NO;
	}
	
	SVUser *obj = object;
	return [self.ID isEqualToNumber:obj.ID] &&
	[self.login isEqualToString:obj.login] &&
	[self.password isEqualToString:obj.password] &&
	((!self.tags && !obj.tags) || [self.tags isEqual:obj.tags]);
}

- (NSString *)description {
	NSString *logString = [NSString stringWithFormat:@"<SVUser %p> id:%@ login:%@ password:%@", self, self.ID, self.login, self.password];
	
	if (self.tags != nil) {
		logString = [logString stringByAppendingFormat:@" tags:%@", self.tags];
	}
	return logString;
}

@end
