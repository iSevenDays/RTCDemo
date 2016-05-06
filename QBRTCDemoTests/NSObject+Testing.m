//
//  NSObject+Testing.m
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 4/7/16.
//  Copyright © 2016 anton. All rights reserved.
//

#import "NSObject+Testing.h"

#import "NSObject+Testing.h"
#import <objc/runtime.h>
#import <XCTest/XCTest.h>

@implementation NSObject (Testing)

- (instancetype)clonedObjectViaCoding {
	id coded = [NSKeyedArchiver archivedDataWithRootObject:self];
	id decoded = [NSKeyedUnarchiver unarchiveObjectWithData:coded];
	return decoded;
}

- (NSArray *)allPropertyNames {
	unsigned count;
	objc_property_t *properties = class_copyPropertyList([self class], &count);
	
	NSMutableArray *rv = [NSMutableArray array];
	
	unsigned i;
	for (i = 0; i < count; i++)
	{
		objc_property_t property = properties[i];
		NSString *name = [NSString stringWithUTF8String:property_getName(property)];
		[rv addObject:name];
	}
	
	free(properties);
	
	return rv;
}

- (void)compareWithObject:(id)comparedObject {
	id originalObject = self;
	
	NSArray *allPropertyNames = [self allPropertyNames];
	
	for (NSString *propertyName in allPropertyNames) {
		id originalProperty = [originalObject valueForKey:propertyName];
		id comparedProperty = [comparedObject valueForKey:propertyName];
		
		if (originalProperty != nil || comparedProperty != nil) {
		
			XCTAssertEqualObjects(originalProperty, comparedProperty, @"Properties are not equal");
			
			// to catch assert add All Exceptions breakpoint
			NSAssert([originalProperty isEqual:comparedProperty], @"see debugger with print-object");
		}
	}
}

- (void)compareWithSelfClonedObject {
	id comparedObject = [self clonedObjectViaCoding];
	
	[self compareWithObject:comparedObject];
}

- (void)compareWithSelfCopiedObject {
	id comparedObject = [self copy];
	
	[self compareWithObject:comparedObject];
}

@end