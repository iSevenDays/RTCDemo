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
@class RTCConfiguration;
@class RTCSessionDescription;

@interface WebRTCHelpers : NSObject

// Updates the original SDP description to instead prefer the specified video
// codec. We do this by placing the specified codec at the beginning of the
// codec list if it exists in the sdp.
+ (RTCSessionDescription *)descriptionForDescription:(RTCSessionDescription *)description preferredVideoCodec:(NSString *)codec;

+ (RTCConfiguration *)defaultConfigurationWithCurrentICEServers;

+ (RTCMediaConstraints *)defaultMediaStreamConstraints;
+ (RTCMediaConstraints *)defaultOfferConstraints;
+ (RTCMediaConstraints *)defaultAnswerConstraints;
+ (RTCMediaConstraints *)defaultPeerConnectionConstraints;

+ (NSArray<RTCICEServer *> *)defaultIceServers;

@end
