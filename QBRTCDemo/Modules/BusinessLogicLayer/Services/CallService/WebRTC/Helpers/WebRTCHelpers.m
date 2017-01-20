//
//  WebRTCHelpers.m
//  RTCDemo
//
//  Created by Anton Sokolchenko on 1/25/16.
//  Copyright © 2016 anton. All rights reserved.
//

#import "WebRTCHelpers.h"
#import <WebRTC/WebRTC.h>

@implementation WebRTCHelpers

+ (RTCSessionDescription *)descriptionForDescription:(RTCSessionDescription *)description preferredVideoCodec:(NSString *)codec {
	NSString *sdpString = description.sdp;
	NSString *lineSeparator = @"\n";
	NSString *mLineSeparator = @" ";
	// Copied from PeerConnectionClient.java.
	// TODO(tkchin): Move this to a shared C++ file.
	NSMutableArray *lines =
	[NSMutableArray arrayWithArray:
	 [sdpString componentsSeparatedByString:lineSeparator]];
	NSInteger mLineIndex = -1;
	NSString *codecRtpMap = nil;
	// a=rtpmap:<payload type> <encoding name>/<clock rate>
	// [/<encoding parameters>]
	NSString *pattern =
	[NSString stringWithFormat:@"^a=rtpmap:(\\d+) %@(/\\d+)+[\r]?$", codec];
	NSRegularExpression *regex =
	[NSRegularExpression regularExpressionWithPattern:pattern
											  options:0
												error:nil];
	for (NSInteger i = 0; (i < lines.count) && (mLineIndex == -1 || !codecRtpMap);
		 ++i) {
		NSString *line = lines[i];
		if ([line hasPrefix:@"m=video"]) {
			mLineIndex = i;
			continue;
		}
		NSTextCheckingResult *codecMatches =
		[regex firstMatchInString:line
						  options:0
							range:NSMakeRange(0, line.length)];
		if (codecMatches) {
			codecRtpMap =
			[line substringWithRange:[codecMatches rangeAtIndex:1]];
			continue;
		}
	}
	if (mLineIndex == -1) {
		RTCLog(@"No m=video line, so can't prefer %@", codec);
		return description;
	}
	if (!codecRtpMap) {
		RTCLog(@"No rtpmap for %@", codec);
		return description;
	}
	NSArray *origMLineParts =
	[lines[mLineIndex] componentsSeparatedByString:mLineSeparator];
	if (origMLineParts.count > 3) {
		NSMutableArray *newMLineParts =
		[NSMutableArray arrayWithCapacity:origMLineParts.count];
		NSInteger origPartIndex = 0;
		// Format is: m=<media> <port> <proto> <fmt> ...
		[newMLineParts addObject:origMLineParts[origPartIndex++]];
		[newMLineParts addObject:origMLineParts[origPartIndex++]];
		[newMLineParts addObject:origMLineParts[origPartIndex++]];
		[newMLineParts addObject:codecRtpMap];
		for (; origPartIndex < origMLineParts.count; ++origPartIndex) {
			if (![codecRtpMap isEqualToString:origMLineParts[origPartIndex]]) {
				[newMLineParts addObject:origMLineParts[origPartIndex]];
			}
		}
		NSString *newMLine =
		[newMLineParts componentsJoinedByString:mLineSeparator];
		[lines replaceObjectAtIndex:mLineIndex
						 withObject:newMLine];
	} else {
		RTCLogWarning(@"Wrong SDP media description format: %@", lines[mLineIndex]);
	}
	NSString *mangledSdpString = [lines componentsJoinedByString:lineSeparator];
	return [[RTCSessionDescription alloc] initWithType:description.type
												   sdp:mangledSdpString];
}

+ (RTCMediaConstraints *)defaultMediaStreamConstraints {
	
	NSDictionary<NSString *, NSString *> *optionalConstraints = @{@"DtlsSrtpKeyAgreement": true ? @"true" : @"false"};
	
//	RTCPair *minWidth;
//	RTCPair *minHeight;
//	RTCPair *maxWidth;
//	RTCPair *maxHeight;
//	BOOL low = YES;
//	if (low) {
//		
//		// 352x288
//		minWidth = [[RTCPair alloc] initWithKey:@"minWidth" value:@"320"];
//		minHeight = [[RTCPair alloc] initWithKey:@"minHeight" value:@"180"];
//		
//		maxWidth = [[RTCPair alloc] initWithKey:@"maxWidth" value:@"320"];
//		maxHeight = [[RTCPair alloc] initWithKey:@"maxHeight" value:@"240"];
//	} else {
//		minWidth = [[RTCPair alloc] initWithKey:@"minWidth" value:@"1280"];
//		minHeight = [[RTCPair alloc] initWithKey:@"minHeight" value:@"720"];
//		
//		maxWidth = [[RTCPair alloc] initWithKey:@"maxWidth" value:@"1920"];
//		maxHeight = [[RTCPair alloc] initWithKey:@"maxHeight" value:@"1080"];
//	}
	RTCMediaConstraints *constraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:nil optionalConstraints:optionalConstraints];
	return constraints;
}

+ (RTCMediaConstraints *)defaultOfferConstraints {
	NSDictionary<NSString *, NSString*> *mandatoryConstraints = @{
									  @"OfferToReceiveAudio":@"true",
									  @"OfferToReceiveVideo":@"true"
									  };
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
	NSString *value = true ? @"true" : @"false";
	NSDictionary<NSString *, NSString *> *mandatory = @{
									 @"DtlsSrtpKeyAgreement": value,
									 @"internalSctpDataChannels": @"true",
									 };
	RTCMediaConstraints* constraints =
	[[RTCMediaConstraints alloc]
	 initWithMandatoryConstraints:mandatory
	 optionalConstraints:nil];
	return constraints;
}

+ (RTCConfiguration *)defaultConfigurationWithCurrentICEServers {
	RTCConfiguration *config = [[RTCConfiguration alloc] init];
	config.iceServers = [self defaultIceServers];
	return config;
}

+ (NSArray *)defaultIceServers {
	return @[[[RTCIceServer alloc] initWithURLStrings:@[@"stun:stun.l.google.com:19302"] username:@"" credential:@""]];
}

+ (NSArray<NSString *> *)videoResolutions {
	return @[ @"640x480", @"960x540", @"1280x720" ];
}

@end
