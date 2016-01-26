//
//  WebRTCHelpers.h
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 1/25/16.
//  Copyright © 2016 anton. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RTCMediaConstraints;
@class RTCICEServer;

@interface WebRTCHelpers : NSObject

+ (RTCMediaConstraints *)defaultMediaStreamConstraints;

+ (RTCMediaConstraints *)defaultOfferConstraints;
+ (RTCMediaConstraints *)defaultAnswerConstraints;

+ (RTCMediaConstraints *)defaultPeerConnectionConstraints;

+ (NSArray<RTCICEServer *> *)defaultIceServers;

@end
