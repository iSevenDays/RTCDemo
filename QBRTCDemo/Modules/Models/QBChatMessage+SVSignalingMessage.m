//
//  QBChatMessage+SVSignalingMessage.m
//  RTCDemo
//
//  Created by Anton Sokolchenko on 11/17/15.
//  Copyright © 2015 anton. All rights reserved.
//

#import "QBChatMessage+SVSignalingMessage.h"
#import "SVSignalingMessageICE.h"
#import "SVSignalingMessageSDP.h"
#import "SVSignalingParams.h"
#import "SVUser.h"

#import <RTCIceCandidate.h>
#import <RTCSessionDescription.h>
#import "NSData+GZIP.h"

@implementation QBChatMessage (SVSignalingMessage)

+ (NSString *)offerSDP {
	return
	@"v=0\n"
	"o=- 5585842076786974405 2 IN IP4 127.0.0.1\n"
	"s=-\n"
	"t=0 0\n"
	"a=group:BUNDLE audio video\n"
	"a=msid-semantic: WMS ARDAMS\n"
	"m=audio 9 UDP/TLS/RTP/SAVPF 111 103 104 9 102 0 8 106 105 13 127 126\n"
	"c=IN IP4 0.0.0.0\n"
	"a=rtcp:9 IN IP4 0.0.0.0\n"
	"a=ice-ufrag:eAw8nqq9o2ya9ZO/\n"
	"a=ice-pwd:pMsKI35iUXSB4vsYyrPiSWJy\n"
	"a=fingerprint:sha-256 66:97:AC:05:D8:D9:E1:71:CF:98:30:29:E7:5A:FC:4D:9C:62:56:4C:F0:7C:EF:06:A5:20:6F:C1:D2:30:85:73\n"
	"a=setup:actpass\n"
	"a=mid:audio\n"
	"a=extmap:1 urn:ietf:params:rtp-hdrext:ssrc-audio-level\n"
	"a=extmap:3 http://www.webrtc.org/experiments/rtp-hdrext/abs-send-time\n"
	"a=sendrecv\n"
	"a=rtcp-mux\n"
	"a=rtpmap:111 opus/48000/2\n"
	"a=fmtp:111 minptime=10; useinbandfec=1\n"
	"a=rtpmap:103 ISAC/16000\n"
	"a=rtpmap:104 ISAC/32000\n"
	"a=rtpmap:9 G722/8000\n"
	"a=rtpmap:102 ILBC/8000\n"
	"a=rtpmap:0 PCMU/8000\n"
	"a=rtpmap:8 PCMA/8000\n"
	"a=rtpmap:106 CN/32000\n"
	"a=rtpmap:105 CN/16000\n"
	"a=rtpmap:13 CN/8000\n"
	"a=rtpmap:127 red/8000\n"
	"a=rtpmap:126 telephone-event/8000\n"
	"a=maxptime:60\n"
	"a=ssrc:1791747252 cname:cT+NPJUuMgb127I5\n"
	"a=ssrc:1791747252 msid:ARDAMS ARDAMSa0\n"
	"a=ssrc:1791747252 mslabel:ARDAMS\n"
	"a=ssrc:1791747252 label:ARDAMSa0\n"
	"m=video 9 UDP/TLS/RTP/SAVPF 107 100 101 116 117 96\n"
	"c=IN IP4 0.0.0.0\n"
	"a=rtcp:9 IN IP4 0.0.0.0\n"
	"a=ice-ufrag:eAw8nqq9o2ya9ZO/\n"
	"a=ice-pwd:pMsKI35iUXSB4vsYyrPiSWJy\n"
	"a=fingerprint:sha-256 66:97:AC:05:D8:D9:E1:71:CF:98:30:29:E7:5A:FC:4D:9C:62:56:4C:F0:7C:EF:06:A5:20:6F:C1:D2:30:85:73\n"
	"a=setup:actpass\n"
	"a=mid:video\n"
	"a=extmap:2 urn:ietf:params:rtp-hdrext:toffset\n"
	"a=extmap:3 http://www.webrtc.org/experiments/rtp-hdrext/abs-send-time\n"
	"a=extmap:4 urn:3gpp:video-orientation\n"
	"a=recvonly\n"
	"a=rtcp-mux\n"
	"a=rtpmap:100 VP8/90000\n"
	"a=rtcp-fb:100 ccm fir\n"
	"a=rtcp-fb:100 nack\n"
	"a=rtcp-fb:100 nack pli\n"
	"a=rtcp-fb:100 goog-remb\n"
	"a=rtcp-fb:100 transport-cc\n"
	"a=rtpmap:101 VP9/90000\n"
	"a=rtcp-fb:101 ccm fir\n"
	"a=rtcp-fb:101 nack\n"
	"a=rtcp-fb:101 nack pli\n"
	"a=rtcp-fb:101 goog-remb\n"
	"a=rtcp-fb:101 transport-cc\n"
	"a=rtpmap:107 H264/90000\n"
	"a=rtcp-fb:107 ccm fir\n"
	"a=rtcp-fb:107 nack\n"
	"a=rtcp-fb:107 nack pli\n"
	"a=rtcp-fb:107 goog-remb\n"
	"a=rtcp-fb:107 transport-cc\n"
	"a=rtpmap:116 red/90000\n"
	"a=rtpmap:117 ulpfec/90000\n"
	"a=rtpmap:96 rtx/90000\n"
	"a=fmtp:96 apt=100\n";
}


+ (instancetype)messageWithSVSignalingMessage:(SVSignalingMessage *)signalingMessage {
	QBChatMessage *message = [QBChatMessage message];
	
	NSMutableDictionary *params = [signalingMessage.params mutableCopy];
	
	if (params == nil) {
		params = [NSMutableDictionary dictionary];
	}
	
	if ([signalingMessage isKindOfClass:[SVSignalingMessageICE class]]) {
		
		SVSignalingMessageICE *sigmessageICE = (SVSignalingMessageICE *)signalingMessage;
		
		params[SVSignalingParams.sdp] = sigmessageICE.iceCandidate.sdp;
		params[SVSignalingParams.mid] = sigmessageICE.iceCandidate.sdpMid;
		params[SVSignalingParams.index] = [@(sigmessageICE.iceCandidate.sdpMLineIndex) stringValue];
		
	} else if ([signalingMessage isKindOfClass:[SVSignalingMessageSDP class]]) {
		
		SVSignalingMessageSDP *sigmessageSDP = (SVSignalingMessageSDP *)signalingMessage;
		
		params[SVSignalingParams.sdp] = sigmessageSDP.sdp.description;
	} else {
		if (signalingMessage.params) {
			params = signalingMessage.params.mutableCopy;
		}
	}
	
	message.text = signalingMessage.type;
	
	// Fill sender
	NSParameterAssert(signalingMessage.sender);
	params[SVSignalingParams.senderLogin] = [signalingMessage.sender.login copy];
	params[SVSignalingParams.senderFullName] = [signalingMessage.sender.fullName copy];
	
	NSString *initiatorID = [signalingMessage.initiatorID stringValue];
	NSParameterAssert(initiatorID);
	params[SVSignalingParams.initiatorID] = initiatorID;
	
	NSString *sessionID = [signalingMessage.sessionID copy];
	NSParameterAssert(sessionID);
	params[SVSignalingParams.sessionID] = sessionID;
	
	NSString *membersIDs = [signalingMessage.membersIDs componentsJoinedByString:@","];
	NSParameterAssert(membersIDs);
	params[SVSignalingParams.membersIDs] = membersIDs;
	
	// Compressing customParameters and saving them to 'compressedData' field
	
	message.customParameters[SVSignalingParams.compressedData] = [self compressedCustomParams:params];
	
	return message;
}

+ (NSString *)compressedCustomParams:(NSDictionary *)params {
	NSData *jsonRepresentation = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
	NSData *compressedParams = [jsonRepresentation gzippedData];
	NSString *base64Representation = [compressedParams base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
	
	return base64Representation;
}

@end
