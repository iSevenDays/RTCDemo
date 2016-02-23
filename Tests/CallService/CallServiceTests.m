//
//  CallServiceTests.m
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 2/9/16.
//  Copyright © 2016 anton. All rights reserved.
//

#import "BaseTestCase.h"
#import <OCMock.h>

#import <RTCICECandidate.h>
#import <RTCSessionDescription.h>
#import <RTCPeerConnection.h>

#import "CallService.h"
#import "CallService_Private.h"
#import "CallServiceHelpers.h"

#import "CallServiceDelegate.h"
#import "FakeSignalingChannel.h"

#import "SVSignalingMessage.h"
#import "SVSignalingMessageSDP.h"
#import "SVSignalingMessageICE.h"
#import "SVSignalingParams.h"

@interface CallServiceTests : BaseTestCase

@property (nonatomic, strong) CallService<SVSignalingChannelDelegate, CallServiceProtocol, CallServiceDataChannelAdditionsProtocol> *callService;
@property (nonatomic, strong) id mockOutput;
@property (nonatomic, strong) id mockCallService;

@property (nonatomic, strong) SVUser *user1;
@property (nonatomic, strong) SVUser *user2;
@property (nonatomic, strong) SVUser *user3;

@end

@implementation CallServiceTests

- (void)setUp {
	[super setUp];
	self.user1 = [CallServiceHelpers user1];
	self.user2 = [CallServiceHelpers user2];
	self.user3 = [[SVUser alloc] initWithID:@1 login:@"login" password:@""];
	
	self.mockOutput = OCMProtocolMock(@protocol(CallServiceDelegate));
	
	self.callService = [[CallService alloc] initWithSignalingChannel:[FakeSignalingChannel new] callServiceDelegate:self.mockOutput];
	
	self.mockCallService = OCMPartialMock(self.callService);
}

- (void)tearDown {
	[self.callService hangup];
	self.callService = nil;
	self.mockCallService = nil;
	self.mockOutput = nil;
}

- (void)testCanConnectWithUserAndHaveConnectedState {
	// given
	XCTestExpectation *expectation = [self currentSelectorTestExpectation];
	// when
	[self.callService connectWithUser:self.user1 completion:^(NSError * _Nullable error) {
		XCTAssertNil(error);
		XCTAssertEqual(self.callService.state, kClientStateConnected);
		[expectation fulfill];
	}];
	
	// then
	[self waitForTestExpectations];
}

#pragma mark CallClientDelegate tests

- (void)testHasLocalVideoTrackAfterStartCall {
	// given
	
	// when
	[self.callService connectWithUser:self.user1 completion:nil];
	
	[self.callService startCallWithOpponent:self.user2];

	// then
	OCMVerify([self.mockOutput callService:[OCMArg any] didReceiveLocalVideoTrack:[OCMArg any]]);
}

- (void)testCorrectlyChangesClientStateToConnected {
	// given
	
	// when
	[self.callService connectWithUser:self.user1 completion:nil];
	
	// then
	OCMVerify([self.mockOutput callService:[OCMArg any] didChangeState:kClientStateConnected]);
}

- (void)testCorrectlyChangesClientStateToDisconnectedAfterHangup {
	// given
	
	// when
	[self.callService connectWithUser:self.user1 completion:nil];
	[self.callService hangup];

	// then
	OCMVerify([self.mockOutput callService:[OCMArg any] didChangeState:kClientStateDisconnected]);
}

- (void)testSendsRejectIfAlreadyHasActiveCall {
	// given
	[[self.mockCallService reject] peerConnection:[OCMArg any] didSetSessionDescriptionWithError:[OCMArg isNotNil]];
	
	RTCSessionDescription *rtcofferSDP = [[RTCSessionDescription alloc] initWithType:SVSignalingMessageType.offer sdp:[self offerSDP]];
	SVSignalingMessage *offer = [[SVSignalingMessageSDP alloc] initWithSessionDescription:rtcofferSDP];
	offer.sender = self.user3;
	
	OCMExpect([self.mockCallService sendRejectToUser:self.user3 completion:[OCMArg any]]);
	
	// when
	[self.callService connectWithUser:self.user1 completion:nil];
	[self.callService startCallWithOpponent:self.user2];
	
	[self.callService channel:self.callService.signalingChannel didReceiveMessage:offer];
	
	// then
	OCMVerifyAll(self.mockCallService);
}

#pragma mark Signaling messages processing

- (void)testCorrectlyProcessesHangupSignalingMessage {
	// given
	[[self.mockCallService reject] peerConnection:[OCMArg any] didSetSessionDescriptionWithError:[OCMArg isNotNil]];
	
	SVSignalingMessage *hangup = [SVSignalingMessage messageWithType:SVSignalingMessageType.hangup params:nil];
	
	// when
	[self.callService connectWithUser:self.user1 completion:nil];
	[self.callService startCallWithOpponent:self.user2];
	
	[self.callService processSignalingMessage:hangup];
	
	// then
	OCMVerify([self.mockCallService clearSession]);
}

- (void)testCorrectlyProcessesSignalingMessageIceWithAudioAndVideoFromOpponent {
	// given
	[[self.mockCallService reject] peerConnection:[OCMArg any] didSetSessionDescriptionWithError:[OCMArg isNotNil]];
	
	RTCICECandidate *rtcIceCandidateAudio = [[RTCICECandidate alloc] initWithMid:@"audio" index:0 sdp:@"candidate:1009584571 1 udp 2122260223 192.168.8.197 58130 typ host generation 0 ufrag 0+C/nsdLdjk3x5eG"];
	
	RTCICECandidate *rtcIceCandidateVideo = [[RTCICECandidate alloc] initWithMid:@"video" index:1 sdp:@"candidate:1009584571 1 udp 2122260223 192.168.8.197 62216 typ host generation 0 ufrag 0+C/nsdLdjk3x5eG"];
	
	SVSignalingMessage *iceAudio = [[SVSignalingMessageICE alloc] initWithICECandidate:rtcIceCandidateAudio];
	SVSignalingMessage *iceVideo = [[SVSignalingMessageICE alloc] initWithICECandidate:rtcIceCandidateVideo];
	
	iceAudio.sender = self.user2;
	iceVideo.sender = self.user2;
	
	OCMExpect([self.mockCallService drainMessageQueueIfReady]);
	
	// when
	[self.callService connectWithUser:self.user1 completion:nil];
	[self.callService startCallWithOpponent:self.user2];
	
	[self.callService channel:self.callService.signalingChannel didReceiveMessage:iceAudio];
	[self.callService channel:self.callService.signalingChannel didReceiveMessage:iceVideo];
	
	// then
	OCMVerifyAll(self.mockCallService);
}

- (void)testCorrectlyProcessesSignalingMessageOfferFromOpponent_andCreatesAnswer {
	// given
	[[self.mockCallService reject] peerConnection:[OCMArg any] didSetSessionDescriptionWithError:[OCMArg isNotNil]];
	
	RTCSessionDescription *rtcofferSDP = [[RTCSessionDescription alloc] initWithType:SVSignalingMessageType.offer sdp:[self offerSDP]];
	
	SVSignalingMessage *offerSDP = [[SVSignalingMessageSDP alloc] initWithSessionDescription:rtcofferSDP];
	
	offerSDP.sender = self.user2;
	
	OCMExpect([[self.mockCallService peerConnection] createAnswerWithDelegate:[OCMArg any] constraints:[OCMArg any]]);
	
	// when
	[self.callService connectWithUser:self.user1 completion:nil];
	
	[self.callService channel:self.callService.signalingChannel didReceiveMessage:offerSDP];
	
	// then
	OCMVerify([self.mockCallService processSignalingMessage:offerSDP]);
	
	OCMVerifyAll(self.mockCallService);
}

- (void)testCorrectlyProcessesSignalingMessageOfferFromOpponent_andThenРшыIceCandidates {
	// given
	[[self.mockCallService reject] peerConnection:[OCMArg any] didSetSessionDescriptionWithError:[OCMArg isNotNil]];
	
	RTCSessionDescription *rtcofferSDP = [[RTCSessionDescription alloc] initWithType:SVSignalingMessageType.offer sdp:[self offerSDP]];
	
	SVSignalingMessage *offerSDP = [[SVSignalingMessageSDP alloc] initWithSessionDescription:rtcofferSDP];
	
	offerSDP.sender = self.user2;
	
	RTCICECandidate *rtcIceCandidateAudio = [[RTCICECandidate alloc] initWithMid:@"audio" index:0 sdp:@"candidate:1009584571 1 udp 2122260223 192.168.8.197 58130 typ host generation 0 ufrag 0+C/nsdLdjk3x5eG"];
	
	RTCICECandidate *rtcIceCandidateVideo = [[RTCICECandidate alloc] initWithMid:@"video" index:1 sdp:@"candidate:1009584571 1 udp 2122260223 192.168.8.197 62216 typ host generation 0 ufrag 0+C/nsdLdjk3x5eG"];
	
	SVSignalingMessage *iceAudio = [[SVSignalingMessageICE alloc] initWithICECandidate:rtcIceCandidateAudio];
	SVSignalingMessage *iceVideo = [[SVSignalingMessageICE alloc] initWithICECandidate:rtcIceCandidateVideo];
	
	iceAudio.sender = self.user2;
	iceVideo.sender = self.user2;
	
	OCMExpect([[self.mockCallService peerConnection] createAnswerWithDelegate:[OCMArg any] constraints:[OCMArg any]]);
	
	// when
	[self.callService connectWithUser:self.user1 completion:nil];
	
	[self.callService channel:self.callService.signalingChannel didReceiveMessage:offerSDP];
	
	[self.callService channel:self.callService.signalingChannel didReceiveMessage:iceAudio];
	[self.callService channel:self.callService.signalingChannel didReceiveMessage:iceVideo];
	
	// then
	OCMVerify([self.mockCallService processSignalingMessage:offerSDP]);
	OCMVerify([self.mockCallService processSignalingMessage:iceAudio]);
	OCMVerify([self.mockCallService processSignalingMessage:iceVideo]);
	
	OCMVerifyAll(self.mockCallService);
}
									
- (NSString *)offerSDP {
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

@end