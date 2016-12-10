//
//  QBChatMessage+SVSignalingMessage.h
//  RTCDemo
//
//  Created by Anton Sokolchenko on 11/17/15.
//  Copyright © 2015 anton. All rights reserved.
//

#import "SVSignalingMessage.h"

@interface QBChatMessage (SVSignalingMessage)

+ (nullable instancetype)messageWithSVSignalingMessage:(__kindof SVSignalingMessage *_Nonnull)signalingMessage;

+ (nonnull NSString *)compressedCustomParams:(nonnull NSDictionary *)params;

@end
