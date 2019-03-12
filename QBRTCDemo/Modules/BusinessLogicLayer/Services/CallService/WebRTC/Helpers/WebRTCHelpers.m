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
	
	NSMutableDictionary<NSString *, NSString *> *videoConstraints = [NSMutableDictionary dictionary];
	
	
//	videoConstraints[kRTCMediaConstraintsMinWidth] = @"320";
//	videoConstraints[kRTCMediaConstraintsMinHeight] = @"180";
	
//	videoConstraints[kRTCMediaConstraintsMinWidth] = @"1280";
//	videoConstraints[kRTCMediaConstraintsMinHeight] = @"720";
//	
//	
//	videoConstraints[kRTCMediaConstraintsMaxWidth] = @"1920";
//	videoConstraints[kRTCMediaConstraintsMaxHeight] = @"1080";
//	videoConstraints[kRTCMediaConstraintsMinFrameRate] = @"5";
//	videoConstraints[kRTCMediaConstraintsMaxFrameRate] = @"60";
	
	RTCMediaConstraints *constraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:videoConstraints optionalConstraints:nil];
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
									 /*@"internalSctpDataChannels": @"true",*/
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
	RTCIceServer *googleSTUN = [[RTCIceServer alloc] initWithURLStrings:@[@"stun:stun.l.google.com:19302"] username:@"" credential:@""];
	RTCIceServer *qbUSA = [[RTCIceServer alloc] initWithURLStrings:@[@"turn:turn.quickblox.com:3478?transport=udp", @"turn:turn.quickblox.com:3478?transport=tcp"] username:@"quickblox" credential:@"baccb97ba2d92d71e26eb9886da5f1e0"];
	RTCIceServer *qbSingapore = [[RTCIceServer alloc] initWithURLStrings:@[@"turn:turnsingapore.quickblox.com:3478?transport=udp", @"turn:turnsingapore.quickblox.com:3478?transport=tcp"] username:@"quickblox" credential:@"baccb97ba2d92d71e26eb9886da5f1e0"];
	RTCIceServer *qbIreland = [[RTCIceServer alloc] initWithURLStrings:@[@"turn:turnireland.quickblox.com:3478?transport=udp", @"turn:turnireland.quickblox.com:3478?transport=tcp"] username:@"quickblox" credential:@"baccb97ba2d92d71e26eb9886da5f1e0"];
	
	return @[googleSTUN, qbUSA, qbSingapore, qbIreland];
}

+ (RTCSessionDescription *)constrainedSessionDescription:(RTCSessionDescription *)description videoBandwidth:(NSUInteger)videoBandwidth audioBandwidth:(NSUInteger)audioBandwidth {
	// Modify the SDP's video & audio media sections to restrict the maximum bandwidth used.
	
	NSString *mAudioLinePattern = @"m=audio(.*)";
	NSString *mVideoLinePattern = @"m=video(.*)";
	
	NSString *constraintedSDPString = [self limitBandwidth:description.sdp withPattern:mAudioLinePattern maximum:audioBandwidth];
	constraintedSDPString = [self limitBandwidth:constraintedSDPString withPattern:mVideoLinePattern maximum:videoBandwidth];
	
	RTCSessionDescription *constraintedSDP = [[RTCSessionDescription alloc] initWithType:description.type sdp: constraintedSDPString];
	
	return constraintedSDP;
}

+ (NSString *)limitBandwidth:(NSString *)sdp withPattern:(NSString *)mLinePattern maximum:(NSUInteger)bandwidthLimit {
	NSString *cLinePattern = @"c=IN(.*)";
	NSError *error = nil;
	NSRegularExpression *mRegex = [[NSRegularExpression alloc] initWithPattern:mLinePattern options:0 error:&error];
	NSRegularExpression *cRegex = [[NSRegularExpression alloc] initWithPattern:cLinePattern options:0 error:&error];
	NSRange mLineRange = [mRegex rangeOfFirstMatchInString:sdp options:NSMatchingWithoutAnchoringBounds range:NSMakeRange(0, [sdp length])];
	NSRange cLineSearchRange = NSMakeRange(mLineRange.location + mLineRange.length, [sdp length] - (mLineRange.location + mLineRange.length));
	NSRange cLineRange = [cRegex rangeOfFirstMatchInString:sdp options:NSMatchingWithoutAnchoringBounds range:cLineSearchRange];
	
	NSString *cLineString = [sdp substringWithRange:cLineRange];
	NSString *bandwidthString = [NSString stringWithFormat:@"b=AS:%d", (int)bandwidthLimit];
	
	return [sdp stringByReplacingCharactersInRange:cLineRange
										withString:[NSString stringWithFormat:@"%@\n%@", cLineString, bandwidthString]];
}

+ (NSArray<NSString *> *)videoResolutions {
	return @[ @"640x480", @"960x540", @"1280x720" ];
}

@end
