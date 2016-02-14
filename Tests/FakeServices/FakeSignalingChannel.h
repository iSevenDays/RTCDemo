//
//  FakeSignalingChannel.h
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 1/28/16.
//  Copyright © 2016 anton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SVSignalingChannelProtocol.h"

@class SVUser;

@protocol SVSignalingChannelDelegate;

@interface FakeSignalingChannel : NSObject <SVSignalingChannelProtocol>

@property (nonatomic, strong, nonnull) NSString *state;

@property (nonatomic, strong, nullable) SVUser *user;

@end
