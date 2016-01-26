//
//  WebRTCHelpers.m
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 1/25/16.
//  Copyright © 2016 anton. All rights reserved.
//

#import "WebRTCHelpers.h"
#import <RTCMediaConstraints.h>
#import <RTCPair.h>
#import <RTCICEServer.h>

@implementation WebRTCHelpers

+ (RTCMediaConstraints *)defaultMediaStreamConstraints {
	RTCMediaConstraints* constraints =
	[[RTCMediaConstraints alloc]
	 initWithMandatoryConstraints:nil
	 optionalConstraints:nil];
	return constraints;
}

+ (RTCMediaConstraints *)defaultOfferConstraints {
	NSArray *mandatoryConstraints = @[
									  [[RTCPair alloc] initWithKey:@"OfferToReceiveAudio" value:@"true"],
									  [[RTCPair alloc] initWithKey:@"OfferToReceiveVideo" value:@"false"]
									  ];
	RTCMediaConstraints* constraints =
	[[RTCMediaConstraints alloc]
	 initWithMandatoryConstraints:mandatoryConstraints
	 optionalConstraints:nil];
	return constraints;
}

+ (RTCMediaConstraints *)defaultAnswerConstraints {
	return [self defaultOfferConstraints];
}

+ (RTCMediaConstraints *)defaultPeerConnectionConstraints {
	NSString *value = false ? @"false" : @"true";
	NSArray *optionalConstraints = @[
									 [[RTCPair alloc] initWithKey:@"DtlsSrtpKeyAgreement" value:value],
									 [[RTCPair alloc] initWithKey:@"internalSctpDataChannels" value:@"true"],
									 [[RTCPair alloc] initWithKey:@"RtpDataChannels" value:@"true"]
									 ];
	RTCMediaConstraints* constraints =
	[[RTCMediaConstraints alloc]
	 initWithMandatoryConstraints:nil
	 optionalConstraints:optionalConstraints];
	return constraints;
}

+ (NSArray *)defaultIceServers {
	return @[[[RTCICEServer alloc] initWithURI:[NSURL URLWithString:@"stun:stun.l.google.com:19302"] username:@"" password:@""]];
}

@end
