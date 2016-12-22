//
//  SVUser.m
//  RTCDemo
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
	return [self initWithID:ID login:login fullName:nil password:password tags:tags];
}

- (instancetype)initWithID:(NSNumber *)ID login:(NSString *)login fullName:(NSString *)fullName password:(NSString *)password tags:(NSArray<NSString *> *)tags {
	self = [super init];
	if (self) {
		self.ID = ID;
		self.login = login;
		self.fullName = fullName;
		self.password = password;
		self.tags = tags;
	}
	return self;
}

- (NSUInteger)hash {
	if (self.ID != nil) {
		return self.ID.unsignedIntegerValue;
	} else {
		return self.login.hash;
	}
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
	[self.login isEqualToString:obj.login];
}

- (NSString *)description {
	NSString *logString = [NSString stringWithFormat:@"<SVUser %p> id:%@ login:%@ password:%@", self, self.ID, self.login, self.password];
	
	if (self.tags != nil) {
		logString = [logString stringByAppendingFormat:@" tags:%@", self.tags];
	}
	return logString;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
	self = [super init];
	if (self) {
		_ID			= [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(ID))];
		_login		= [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(login))];
		_fullName	= [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(fullName))];
		_password	= [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(password))];
		_tags		= [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(tags))];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:_ID forKey:NSStringFromSelector(@selector(ID))];
	[aCoder encodeObject:_login forKey:NSStringFromSelector(@selector(login))];
	[aCoder encodeObject:_fullName forKey:NSStringFromSelector(@selector(fullName))];
	[aCoder encodeObject:_password forKey:NSStringFromSelector(@selector(password))];
	[aCoder encodeObject:_tags forKey:NSStringFromSelector(@selector(tags))];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
	SVUser *copy = [[[self class] alloc] init];
	copy->_ID = [_ID copy];
	copy->_login = [_login copy];
	copy->_fullName = [_fullName copy];
	copy->_password = [_password copy];
	copy->_tags = [_tags copy];
	return copy;
}

@end
