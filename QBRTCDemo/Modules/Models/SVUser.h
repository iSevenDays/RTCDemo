//
//  SVUser.h
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 11/17/15.
//  Copyright © 2015 anton. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

@interface SVUser : NSObject <NSCoding, NSCopying>

+ (nonnull instancetype)userWithID:(nullable NSNumber *)ID login:(NSString *)login password:(nullable NSString *)password;
+ (nonnull instancetype)userWithID:(nullable NSNumber *)ID login:(NSString *)login password:(nullable NSString *)password tags:(nullable NSArray<NSString *> *)tags;

- (nonnull instancetype)initWithID:(nullable NSNumber *)ID login:(NSString *)login password:(nullable NSString *)password;
- (nonnull instancetype)initWithID:(nullable NSNumber *)ID login:(NSString *)login password:(nullable NSString *)password tags:(nullable NSArray<NSString *> *)tags;

- (nonnull instancetype)initWithID:(nullable NSNumber *)ID login:(NSString *)login fullName:(nullable NSString *)fullName password:(nullable NSString *)password tags:(nullable NSArray<NSString *> *)tags;

@property (nonatomic, copy, nullable) NSNumber *ID;
@property (nonatomic, copy) NSString *login;
@property (nonatomic, copy) NSString *fullName;
@property (nonatomic, copy, nullable) NSString *password;

@property (nonatomic, copy, nullable) NSArray <NSString *> *tags;

@end

NS_ASSUME_NONNULL_END