//
//  SVUser.h
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 11/17/15.
//  Copyright © 2015 anton. All rights reserved.
//

@interface SVUser : NSObject

+ (instancetype)userWithID:(NSNumber *)ID login:(NSString *)login password:(NSString *)password;
- (instancetype)initWithID:(NSNumber *)ID login:(NSString *)login password:(NSString *)password;

@property (nonatomic, copy) NSNumber *ID;
@property (nonatomic, copy) NSString *login;
@property (nonatomic, copy) NSString *password;

@end
