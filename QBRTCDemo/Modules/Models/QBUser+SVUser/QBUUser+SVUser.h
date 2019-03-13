//
//  QBUUser+SVUser.h
//  RTCDemo
//
//  Created by Anton Sokolchenko on 11/17/15.
//  Copyright © 2015 anton. All rights reserved.
//

@class SVUser;
@import Quickblox;

@interface QBUUser (SVUser)

+ (nonnull instancetype)userWithSVUser:(SVUser *_Nonnull)svser;

@end
