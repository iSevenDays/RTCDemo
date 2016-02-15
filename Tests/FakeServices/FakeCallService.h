//
//  FakeCallService.h
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 1/26/16.
//  Copyright © 2016 anton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CallServiceProtocol.h"
#import "CallService.h"

@protocol CallClientDelegate;
@protocol SVSignalingChannelProtocol;

@interface FakeCallService : CallService

@end
