//
//  QBUUser+SVUser.h
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 11/17/15.
//  Copyright © 2015 anton. All rights reserved.
//

@class SVUser;

@interface QBUUser (SVUser)

+ (nonnull instancetype)userWithSVUser:(SVUser *_Nonnull)svser;

@end
