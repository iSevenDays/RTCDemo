//
//  NSObject+Testing.h
//  RTCDemo
//
//  Created by Anton Sokolchenko on 4/7/16.
//  Copyright © 2016 anton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Testing)

/**
 *  Archive self with NSKeyedArchiver, then unarchive with NSKeyedUnarchiver
 *  and return the object
 */
- (instancetype)clonedObjectViaCoding;

/**
 *  Retrieve all properties names
 *
 *  @return array of NSString insances
 */
- (NSArray *)allPropertyNames;

/**
 *  Compare with clonedObjectViaCoding
 */
- (void)compareWithSelfClonedObject;

/**
 *  Compare with object cloned with copy:
 */
- (void)compareWithSelfCopiedObject;

@end
