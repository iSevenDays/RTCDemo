//
//  SVSignalingMessage.h
//  RTCDemo
//
//  Created by Anton Sokolchenko on 11/16/15.
//  Copyright © 2015 anton. All rights reserved.
//

#import "SVSignalingMessageType.h"
@class SVUser;

@interface SVSignalingMessage : NSObject

+ (nullable instancetype)messageWithType:(NSString *_Nonnull)type params:(NSDictionary *_Nullable)params;
- (nullable instancetype)initWithType:(NSString *_Nonnull)type params:(NSDictionary *_Nullable)params;

@property (nonatomic, copy, readonly, nonnull) NSString *type;
@property (nonatomic, copy, readonly, nonnull) NSDictionary<NSString *, NSString *> *params;

@property (nonatomic, strong, nonnull) SVUser *sender;

@end
