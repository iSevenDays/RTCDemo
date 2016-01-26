//
//  FakeCallService.h
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 1/26/16.
//  Copyright © 2016 anton. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CallServiceProtocol;
@protocol SVClientDelegate;


@interface FakeCallService : NSObject<CallServiceProtocol>

@property (nonatomic, weak, nullable) id<SVClientDelegate> delegate;

@end
