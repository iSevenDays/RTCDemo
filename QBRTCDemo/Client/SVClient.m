//
//  SVClient.m
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 11/18/15.
//  Copyright © 2015 anton. All rights reserved.
//

#import "SVClient.h"
#import "SVUser.h"
#import "SVSignalingChannelProtocol.h"
#import "SVSignalingMessageSDP.h"
#import "SVSignalingMessageICE.h"

#import <RTCAVFoundationVideoSource.h>
#import <RTCMediaStream.h>
#import <RTCPeerConnection.h>
#import <RTCPeerConnectionFactory.h>
#import <RTCICEServer.h>
#import <RTCMediaConstraints.h>
#import <RTCPair.h>
#import <RTCPeerConnectionInterface.h>
#import <RTCLogging.h>
#import <RTCSessionDescriptionDelegate.h>

#import "RTCDataChannel.h"

#import "ARDSDPUtils.h"

@interface SVClient() <SVSignalingChannelDelegate, RTCPeerConnectionDelegate, RTCSessionDescriptionDelegate, RTCDataChannelDelegate>

@property (nonatomic, strong) id<SVSignalingChannelProtocol> signalingChannel;

@property (nonatomic, strong) NSMutableArray *iceServers;
@property (nonatomic, strong) NSMutableArray *messageQueue;
@property (nonatomic, strong) RTCPeerConnectionFactory *factory;
@property (nonatomic, strong) RTCPeerConnection *peerConnection;

@property (nonatomic, assign) SVClientState state;
@property (nonatomic, assign) BOOL isReceivedSDP;
@property (nonatomic, assign, getter=isInitiator) BOOL initiator;
@property (nonatomic, assign) BOOL isAudioOnly;

@property (nonatomic, strong) SVUser *opponentUser;
@property (nonatomic, strong) SVUser *initiatorUser;

@property (nonatomic, strong) RTCDataChannel *dataChannel;

@end

@implementation SVClient

- (instancetype)initWithSignalingChannel:(id<SVSignalingChannelProtocol>)signalingChannel clientDelegate:(id<SVClientDelegate>)clientDelegate {
	NSParameterAssert(signalingChannel);
	NSParameterAssert(clientDelegate);
	
	self = [super init];
	
	if (self) {
		self.signalingChannel = signalingChannel;
		self.signalingChannel.delegate = self;
		self.delegate = clientDelegate;
		
		self.iceServers =
		[NSMutableArray arrayWithObject:[[RTCICEServer alloc] initWithURI:[NSURL URLWithString:@"stun:stun.l.google.com:19302"] username:@"" password:@""]];
		
		self.messageQueue = [NSMutableArray array];
		self.factory = [[RTCPeerConnectionFactory alloc] init];
		
		self.state = kClientStateDisconnected;
		
		self.isAudioOnly = NO;
	}
	return self;
}

- (void)connectWithUser:(SVUser *)user completion:(void(^)(NSError *error))completion {
	
	NSCAssert(self.state == kClientStateDisconnected, @"Invalid state");
	
	self.state = kClientStateConnecting;
	
	[self.signalingChannel connectWithUser:user completion:^(NSError * _Nullable error) {
		if (error) {
			self.state = kClientStateDisconnected;
		} else {
			self.state = kClientStateConnected;
		}
		if (completion) {
			completion(error);
		}
	}];
}

- (void)startCallWithOpponent:(SVUser *)opponent {
	NSParameterAssert(opponent);
	NSCAssert(![opponent.ID isEqualToNumber:@0], @"Invalid opponent ID");
	
	if (![self.signalingChannel.state isEqualToString:SVSignalingChannelState.established]) {
		NSLog(@"Chat is not connected");
		return;
	}
	
	self.initiatorUser = self.signalingChannel.user;
	self.opponentUser = opponent;
	// Create peer connection.
	
	RTCMediaConstraints *constraints = [self defaultPeerConnectionConstraints];
	RTCConfiguration *config = [[RTCConfiguration alloc] init];
	config.iceServers = self.iceServers;
	
	self.peerConnection = [self.factory peerConnectionWithConfiguration:config constraints:constraints delegate:self];
	
	// Create AV media stream and add it to the peer connection.
	RTCMediaStream *localStream = [self createLocalMediaStream];
	[self.peerConnection addStream:localStream];

	[self openDataChannel]; // configure data channel, then start call
	// Send offer.
	[self.peerConnection createOfferWithDelegate:self constraints:[self defaultOfferConstraints]];
}

- (void)openDataChannel {
//	if (![self.signalingChannel.state isEqualToString:SVSignalingChannelState.established]
//		|| self.state != kClientStateConnected) {
//		NSLog(@"Connection is not established");
//		return;
//	}
	RTCDataChannelInit *dataChannelInit = [[RTCDataChannelInit alloc] init];
	
	self.dataChannel = [self.peerConnection createDataChannelWithLabel:@"testdatachannel" config:dataChannelInit];
	self.dataChannel.delegate = self;
}

- (void)hangup {
	
	if (self.state == kClientStateDisconnected) {
		[self clearSession];
		return;
	}
	
	if (![[self.signalingChannel state] isEqualToString:SVSignalingChannelState.established]) {
		[self clearSession];
		return;
	}
	
	SVSignalingMessage *hangupMessage = [SVSignalingMessage messageWithType:SVSignalingMessageType.hangup params:nil];
	
	[self.signalingChannel sendMessage:hangupMessage toUser:self.opponentUser completion:^(NSError * _Nullable error) {
		if (error) {
			NSLog(@"Error hangup disconnect: %@", error);
			return;
		}
		[self clearSession];
	}];
}

- (void)clearSession {
	NSLog(@"Clear session");
	self.initiatorUser = nil;
	self.opponentUser = nil;
	self.state = kClientStateDisconnected;
	for (RTCMediaStream *stream in  self.peerConnection.localStreams) {
		[self.peerConnection removeStream:stream];
	}
	[self.peerConnection close];
	self.peerConnection = nil;
	self.isReceivedSDP = NO;
	self.messageQueue = [NSMutableArray array];
}

- (BOOL)hasActiveCall {
	return self.initiatorUser && self.opponentUser;
}

- (void)drainMessageQueueIfReady {
	if (!self.peerConnection || !self.isReceivedSDP) {
		return;
	}
	for (SVSignalingMessage *message in self.messageQueue) {
		[self processSignalingMessage:message];
	}
	[self.messageQueue removeAllObjects];
}

// Processes the given signaling message based on its type.
- (void)processSignalingMessage:(SVSignalingMessage *)message {
	NSParameterAssert(self.peerConnection ||
					  [message.type isEqualToString:SVSignalingMessageType.hangup]);
	
	if ([message.type isEqualToString:SVSignalingMessageType.offer] ||
		[message.type isEqualToString:SVSignalingMessageType.answer]) {
		
		if ([message.type isEqualToString:SVSignalingMessageType.answer]) {
			NSLog(@"GOT ANSWER");
		}
		
		SVSignalingMessageSDP *sdpMessage = (SVSignalingMessageSDP *)message;
		RTCSessionDescription *description = sdpMessage.sdp;
		
		NSParameterAssert(description);
		
		// Prefer H264 if available.
		RTCSessionDescription *sdpPreferringH264 =
		[ARDSDPUtils descriptionForDescription:description
						   preferredVideoCodec:@"H264"];
		
		[self.peerConnection setRemoteDescriptionWithDelegate:self
										   sessionDescription:sdpPreferringH264];
		
	} else if ([message.type isEqualToString:SVSignalingMessageType.candidate] ) {
		
		SVSignalingMessageICE *candidateMessage = (SVSignalingMessageICE *)message;
		[self.peerConnection addICECandidate:candidateMessage.iceCandidate];
	} else if ([message.type isEqualToString:SVSignalingMessageType.hangup] ) {
		// Other client disconnected.
		[self clearSession];
	}
}

// Sends a signaling message to the other client. The caller will send messages
// through the room server, whereas the callee will send messages over the
// signaling channel.
- (void)sendSignalingMessage:(SVSignalingMessage *)message {
	__weak __typeof(self)weakSelf = self;
	
	[self.signalingChannel sendMessage:message toUser:self.opponentUser completion:^(NSError * _Nullable error) {
		if (error) {
			[weakSelf.delegate client:weakSelf didError:error];
		}
	}];
}

- (RTCMediaConstraints *)defaultPeerConnectionConstraints {
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

- (RTCMediaStream *)createLocalMediaStream {
	NSParameterAssert(self.factory);
	
	RTCMediaStream* localStream = [self.factory mediaStreamWithLabel:@"ARDAMS"];
	RTCVideoTrack* localVideoTrack = nil; [self createLocalVideoTrack];
	if (localVideoTrack) {
		[localStream addVideoTrack:localVideoTrack];
		[self.delegate client:self didReceiveLocalVideoTrack:localVideoTrack];
	}
	[localStream addAudioTrack:[_factory audioTrackWithID:@"ARDAMSa0"]];
	return localStream;
}

- (RTCVideoTrack *)createLocalVideoTrack {
	RTCVideoTrack* localVideoTrack = nil;
	// The iOS simulator doesn't provide any sort of camera capture
	// support or emulation (http://goo.gl/rHAnC1) so don't bother
	// trying to open a local stream.
	// TODO(tkchin): local video capture for OSX. See
	// https://code.google.com/p/webrtc/issues/detail?id=3417.
#if !TARGET_IPHONE_SIMULATOR && TARGET_OS_IPHONE
	if (!_isAudioOnly) {
		RTCMediaConstraints *mediaConstraints =
		[self defaultMediaStreamConstraints];
		RTCAVFoundationVideoSource *source =
		[[RTCAVFoundationVideoSource alloc] initWithFactory:_factory
												constraints:mediaConstraints];
		localVideoTrack =
		[[RTCVideoTrack alloc] initWithFactory:_factory
										source:source
									   trackId:@"ARDAMSv0"];
	}
#endif
	return localVideoTrack;
}

- (RTCMediaConstraints *)defaultMediaStreamConstraints {
	RTCMediaConstraints* constraints =
	[[RTCMediaConstraints alloc]
	 initWithMandatoryConstraints:nil
	 optionalConstraints:nil];
	return constraints;
}


- (RTCMediaConstraints *)defaultOfferConstraints {
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

#pragma mark - RTCPeerConnectionDelegate
// Callbacks for this delegate occur on non-main thread and need to be
// dispatched back to main queue as needed.

- (void)peerConnection:(RTCPeerConnection *)peerConnection signalingStateChanged:(RTCSignalingState)stateChanged {
	RTCLog(@"Signaling state changed: %d", stateChanged);
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection addedStream:(RTCMediaStream *)stream {
	dispatch_async(dispatch_get_main_queue(), ^{
		RTCLog(@"Received %lu video tracks and %lu audio tracks",
			   (unsigned long)stream.videoTracks.count,
			   (unsigned long)stream.audioTracks.count);
		if (stream.videoTracks.count) {
			RTCVideoTrack *videoTrack = stream.videoTracks[0];
			[self.delegate client:self didReceiveRemoteVideoTrack:videoTrack];
		}
	});
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection removedStream:(RTCMediaStream *)stream {
	RTCLog(@"Stream was removed.");
}

- (void)peerConnectionOnRenegotiationNeeded:(RTCPeerConnection *)peerConnection {
	RTCLog(@"WARNING: Renegotiation needed but unimplemented.");
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection iceConnectionChanged:(RTCICEConnectionState)newState {
	RTCLog(@"ICE state changed: %d", newState);
	
	switch (newState) {
		case RTCICEConnectionChecking:
			self.state = kClientStateConnecting;
		case RTCICEConnectionCompleted:
			self.state = kClientStateConnected;
			break;
		case RTCICEConnectionDisconnected:
			self.state = kClientStateDisconnected;
			break;
		case RTCICEConnectionFailed:
			self.state = kClientStateDisconnected;
			[self clearSession];
		default:
			break;
	}
	
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.delegate client:self didChangeConnectionState:newState];
	});
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection iceGatheringChanged:(RTCICEGatheringState)newState {
	RTCLog(@"ICE gathering state changed: %d", newState);
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection gotICECandidate:(RTCICECandidate *)candidate {
	dispatch_async(dispatch_get_main_queue(), ^{
		SVSignalingMessageICE *message = [[SVSignalingMessageICE alloc] initWithICECandidate:candidate];
		[self sendSignalingMessage:message];
	});
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection didOpenDataChannel:(RTCDataChannel *)dataChannel {
	NSLog(@"did Open Data Channel");
	dataChannel.delegate = self;
	[self sendDataChannelTestMessage];
}

- (void)sendDataChannelTestMessage {

	NSString *str = [NSString stringWithFormat:@"%@ user calling to %@", self.signalingChannel.user.ID, self.opponentUser.ID];
	RTCDataBuffer *buff = [[RTCDataBuffer alloc] initWithData:[str dataUsingEncoding:NSUTF8StringEncoding] isBinary:NO];
	
	[self.dataChannel sendData:buff];
}

#pragma mark - RTCStatsDelegate

- (void)peerConnection:(RTCPeerConnection *)peerConnection didGetStats:(NSArray *)stats {
	dispatch_async(dispatch_get_main_queue(), ^{
//		[self.delegate client:self didGetStats:stats];
	});
}

#pragma mark - RTCSessionDescriptionDelegate
// Callbacks for this delegate occur on non-main thread and need to be
// dispatched back to main queue as needed.

- (void)peerConnection:(RTCPeerConnection *)peerConnection didCreateSessionDescription:(RTCSessionDescription *)sdp error:(NSError *)error {
	dispatch_async(dispatch_get_main_queue(), ^{
		if (error) {
			RTCLogError(@"Failed to create session description. Error: %@", error);
			//[self disconnect];
			NSDictionary *userInfo = @{
									   NSLocalizedDescriptionKey: @"Failed to create session description.",
									   };
			NSError *sdpError = [[NSError alloc] initWithDomain:@"error"
									   code:-1
								   userInfo:userInfo];
			[self.delegate client:self didError:sdpError];
			return;
		}
//		 Prefer H264 if available.
		RTCSessionDescription *sdpPreferringH264 = [ARDSDPUtils descriptionForDescription:sdp preferredVideoCodec:@"H264"];
		NSParameterAssert(sdp);
		
		[self.peerConnection setLocalDescriptionWithDelegate:self sessionDescription:sdpPreferringH264];
		SVSignalingMessageSDP *message = [[SVSignalingMessageSDP alloc]
		 initWithSessionDescription:sdp];
		[self sendSignalingMessage:message];
	});
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection didSetSessionDescriptionWithError:(NSError *)error {
	dispatch_async(dispatch_get_main_queue(), ^{
		if (error) {
			RTCLogError(@"Failed to set session description. Error: %@", error);
			//[self disconnect];
			NSDictionary *userInfo = @{
									   NSLocalizedDescriptionKey: @"Failed to set session description.",
									   };
			NSError *sdpError = [[NSError alloc] initWithDomain:@"" code:-1
								   userInfo:userInfo];
			[self.delegate client:self didError:sdpError];
			return;
		}
		// If we're answering and we've just set the remote offer we need to create
		// an answer and set the local description.
		if (!self.isInitiator && !self.peerConnection.localDescription) {
			NSCAssert(self.peerConnection, @"Peer connection must exists");
			[self.peerConnection createAnswerWithDelegate:self
										  constraints:[self defaultAnswerConstraints]];
		}
	});
}

- (RTCConfiguration *)defaulConfigurationWithCurrentICEServers {
	RTCConfiguration *config = [[RTCConfiguration alloc] init];
	config.iceServers = self.iceServers;
	return config;
}

- (RTCMediaConstraints *)defaultAnswerConstraints {
	return [self defaultOfferConstraints];
}

- (BOOL)isInitiator {
	return [self.initiatorUser isEqual:self.signalingChannel.user];
}

#pragma mark - SVSignalingChannel Delegate

- (void)channel:(id<SVSignalingChannelProtocol>)channel didReceiveMessage:(SVSignalingMessage *)message {
	if ([message.type isEqualToString:SVSignalingMessageType.offer]) {
		
		NSCAssert(self.peerConnection == nil, @"At the time of answer there should be no active peerconnection");
		NSCAssert(!self.isInitiator, @"Invalid state, you should be answering side");
		NSCAssert(self.opponentUser == nil, @"Opponent is not nil");
		
		self.opponentUser = message.sender;
		
		self.peerConnection = [self.factory peerConnectionWithConfiguration:[self defaulConfigurationWithCurrentICEServers] constraints:[self defaultAnswerConstraints] delegate:self];
		[self.peerConnection addStream:[self createLocalMediaStream]];
	}
	if ([message.type isEqualToString:SVSignalingMessageType.offer] ||
		[message.type isEqualToString:SVSignalingMessageType.answer]) {
		self.isReceivedSDP = YES;
		// Offers and answers must be processed before any other message, so we
		// place them at the front of the queue.
		[_messageQueue insertObject:message atIndex:0];
		
	} else if ([message.type isEqualToString:SVSignalingMessageType.candidate] ) {
		
		[_messageQueue addObject:message];
	}
	else if ([message.type isEqualToString:SVSignalingMessageType.hangup] ) {

		// Disconnects can be processed immediately.
		[self processSignalingMessage:message];
	}
	[self drainMessageQueueIfReady];
}

#pragma mark DataChannel Delegate
- (void)channelDidChangeState:(RTCDataChannel *)channel {
	NSLog(@"%@ didChangeState: %u", channel, channel.state);
//	if (channel.state == kRTCDataChannelStateOpen) {
//		[self sendDataChannelTestMessage];
//	}
}

- (void)channel:(RTCDataChannel *)channel didReceiveMessageWithBuffer:(RTCDataBuffer *)buffer {
	NSLog(@"%@ didReceiveMessageWithBuffer: %@", channel, buffer);
}



@end
