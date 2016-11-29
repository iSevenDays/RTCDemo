//
//  SVMulticastDelegate.m
//  RTCDemo
//
//  Created by Anton Sokolchenko on 2/23/16.
//  Copyright © 2016 anton. All rights reserved.
//

#import "SVMulticastDelegate.h"


@interface SVMulticastDelegate()

@property (strong, nonatomic) NSHashTable *delegates;

@end

@implementation SVMulticastDelegate

- (id)init {
	if (self = [super init]) {
		_delegates = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
	}
	return self;
}

- (void)addDelegate:(id)delegate {
	[self.delegates addObject:delegate];
}


- (void)removeDelegate:(id)delegate {
	[self.delegates removeObject:delegate];
}

- (void)removeAllDelegates {
	[self.delegates removeAllObjects];
}

- (NSHashTable *)delegates {
	return _delegates;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
	
	if ([super respondsToSelector:aSelector]) {
		return YES;
	}
	
	// if any of the delegates respond to this selector, return YES
	NSArray *delegates = self.delegates.allObjects;
	for (id delegate in delegates) {
		
		if ([delegate respondsToSelector:aSelector]) {
			return YES;
		}
	}
	
	return NO;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
	// can this class create the signature?
	NSMethodSignature *signature = [super methodSignatureForSelector:aSelector];
	
	// if not, try our delegates
	if (!signature) {
		
		NSArray *delegates = self.delegates.allObjects;
		for (id delegate in delegates) {
			
			if ([delegate respondsToSelector:aSelector]) {
				return [delegate methodSignatureForSelector:aSelector];
			}
		}
	}
	
	return signature;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
	// forward the invocation to every delegate
	NSArray *delegates = self.delegates.allObjects;
	for (id delegate in delegates) {
		
		if ([delegate respondsToSelector:[anInvocation selector]]) {
			[anInvocation invokeWithTarget:delegate];
		}
	}
}
@end
