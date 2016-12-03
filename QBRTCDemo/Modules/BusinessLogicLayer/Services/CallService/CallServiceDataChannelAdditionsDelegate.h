//
//  CallServiceDataChannelAdditionsDelegate.h
//  RTCDemo
//
//  Created by Anton Sokolchenko on 2/14/16.
//  Copyright © 2016 anton. All rights reserved.
//

#ifndef CallServiceDataChannelAdditionsDelegate_h
#define CallServiceDataChannelAdditionsDelegate_h

#import <Foundation/Foundation.h>

@protocol CallServiceProtocol;
@class RTCDataChannel;

@protocol CallServiceDataChannelAdditionsDelegate <NSObject>

@optional
- (void)callService:(id<CallServiceProtocol>)callService didOpenDataChannel:(RTCDataChannel *)dataChannel;
- (void)callService:(id<CallServiceProtocol>)callService didReceiveMessage:(NSString *)message;
- (void)callService:(id<CallServiceProtocol>)callService didReceiveData:(NSData *)data;

@end

#endif /* CallServiceDataChannelAdditionsDelegate_h */
