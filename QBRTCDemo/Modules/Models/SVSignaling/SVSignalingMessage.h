//
//  SVSignalingMessage.h
//  RTCDemo
//
//  Created by Anton Sokolchenko on 11/16/15.
//  Copyright © 2015 anton. All rights reserved.
//

#import "SVSignalingMessageType.h"
@class SVUser;
@class SessionDetails;

@interface SVSignalingMessage : NSObject

- (nullable instancetype)initWithType:(NSString *_Nonnull)type params:(NSDictionary *_Nullable)params;

- (void)populateParametersWithSessionDetails:(SessionDetails *_Nonnull)sessionDetails;

@property (nonatomic, copy, readonly, nonnull) NSString *type;
@property (nonatomic, copy, readonly, nonnull) NSDictionary<NSString *, NSString *> *params;

@property (nonatomic, strong, nonnull) SVUser *sender;
@property (nonatomic, strong, nonnull) NSNumber *initiatorID;
@property (nonatomic, strong, nonnull) NSString *sessionID;
@property (nonatomic, strong, nonnull) NSArray<NSNumber *> *membersIDs;

@end
