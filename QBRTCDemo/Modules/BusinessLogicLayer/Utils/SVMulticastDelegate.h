//
//  SVMulticastDelegate.h
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 2/23/16.
//  Copyright © 2016 anton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SVMulticastDelegate<T> : NSObject

// Adds the given delegate implementation to the list of observers
- (void)addDelegate:(nonnull T)delegate;

// Removes the given delegate implementation from the list of observers
- (void)removeDelegate:(nonnull T)delegate;

// Removes all delegates
- (void)removeAllDelegates;

// Hashtable of all delegates
- (nonnull NSHashTable<T> *)delegates;

@end