//
//  TestsStorage.h
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 11/19/15.
//  Copyright © 2015 anton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SVUser.h"

@interface TestsStorage : NSObject

+ (nonnull SVUser *)svuserRealUser1;
+ (nonnull SVUser *)svuserRealUser2;

/**
 *  Login	testlogin
 *  Pass	testpass
 *  ID		777
 */
+ (nonnull QBUUser *)qbuserTest;

/**
 *  Login	svlogin
 *  Pass	svpass
 *  ID		123
 */
+ (nonnull SVUser*)svuserTest;

/// Reset test users
+ (void)reset;

@end
