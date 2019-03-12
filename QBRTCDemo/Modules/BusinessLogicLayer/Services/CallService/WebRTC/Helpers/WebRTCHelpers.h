//
//  WebRTCHelpers.h
//  RTCDemo
//
//  Created by Anton Sokolchenko on 1/25/16.
//  Copyright © 2016 anton. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RTCMediaConstraints;
@class RTCIceServer;
@class RTCConfiguration;
@class RTCSessionDescription;

@interface WebRTCHelpers : NSObject

// Updates the original SDP description to instead prefer the specified video
// codec. We do this by placing the specified codec at the beginning of the
// codec list if it exists in the sdp.
+ (RTCSessionDescription *)descriptionForDescription:(RTCSessionDescription *)description preferredVideoCodec:(NSString *)codec;
+ (RTCSessionDescription *)constrainedSessionDescription:(RTCSessionDescription *)description videoBandwidth:(NSUInteger)videoBandwidth audioBandwidth:(NSUInteger)audioBandwidth;

+ (RTCConfiguration *)defaultConfigurationWithCurrentICEServers;

+ (RTCMediaConstraints *)defaultMediaStreamConstraints;

/**
 *  RTCMediaConstraints.
 *  Enable/disable Video and Audio.
 *
 *  @note default audio state: disabled
 *  @note default video state: disabled
 *
 *  @return RTCMediaConstraints instance
 */
+ (RTCMediaConstraints *)defaultOfferConstraints;

/// @return +defaultOfferConstraints
+ (RTCMediaConstraints *)defaultAnswerConstraints;

+ (RTCMediaConstraints *)defaultPeerConnectionConstraints;

+ (NSArray<RTCIceServer *> *)defaultIceServers;

@end
