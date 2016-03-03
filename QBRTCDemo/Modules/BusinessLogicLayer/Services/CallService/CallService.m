//
//  CallService.m
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 1/25/16.
//  Copyright © 2016 anton. All rights reserved.
//

#import "CallService.h"
#import "CallServiceDelegate.h"
#import "CallServiceDataChannelAdditionsDelegate.h"

#import "SVUser.h"

#import "SVSignalingChannelProtocol.h"
#import "SVSignalingMessageSDP.h"
#import "SVSignalingMessageICE.h"
#import "SVMulticastDelegate.h"

#import <RTCAVFoundationVideoSource.h>
#import <RTCMediaStream.h>
#import <RTCPeerConnection.h>
#import <RTCPeerConnectionFactory.h>
#import <RTCICEServer.h>
#import <RTCSessionDescriptionDelegate.h>
#import <RTCPeerConnectionInterface.h>
#import <RTCSessionDescriptionDelegate.h>
#import <RTCMediaStream.h>
#import <RTCPeerConnection.h>
#import <RTCPeerConnectionFactory.h>
#import <RTCMediaConstraints.h>
#import <RTCPair.h>
#import <RTCLogging.h>

#import "RTCDataChannel.h"

#import "WebRTCHelpers.h"
#import "RTCMediaStream.h"

@interface CallService()<SVSignalingChannelDelegate, RTCPeerConnectionDelegate, RTCSessionDescriptionDelegate, RTCDataChannelDelegate>

@property (nonatomic, strong) id<SVSignalingChannelProtocol> signalingChannel;
@property (atomic, strong) NSMutableArray *messageQueue;
@property (nonatomic, strong) RTCPeerConnectionFactory *factory;
@property (nonatomic, strong) RTCPeerConnection *peerConnection;

@property (nonatomic, strong) RTCDataChannel *dataChannel;

@property (nonatomic, assign, readwrite) CallServiceState state;
@property (nonatomic, assign) BOOL isReceivedSDP;
@property (nonatomic, assign, getter=isInitiator) BOOL initiator;
@property (nonatomic, assign) BOOL isAudioOnly;

@property (nonatomic, strong) SVUser *opponentUser;
@property (nonatomic, strong) SVUser *initiatorUser;

@property (nonatomic, strong) RTCMediaConstraints *defaultOfferConstraints;
@property (nonatomic, strong) RTCMediaConstraints *defaultAnswerConstraints;
@property (nonatomic, strong) RTCMediaConstraints *defaultPeerConnectionConstraints;
@property (nonatomic, strong) RTCMediaConstraints *defaultMediaStreamConstraints;
@property (nonatomic, strong) RTCConfiguration *defaultConfigurationWithCurrentICEServers;

@end

@implementation CallService

@synthesize dataChannelEnabled = _dataChannelEnabled;

- (instancetype)initWithSignalingChannel:(id<SVSignalingChannelProtocol>)signalingChannel callServiceDelegate:(id<CallServiceDelegate>)callServiceDelegate dataChannelDelegate:(id<CallServiceDataChannelAdditionsDelegate>)dataChannelDelegate {
	
	NSParameterAssert(signalingChannel);
	
	self = [super init];
	
	if (self) {
		_signalingChannel = signalingChannel;
		_signalingChannel.delegate = self;
		_multicastDelegate = (SVMulticastDelegate<CallServiceDelegate>*)[[SVMulticastDelegate alloc] init];
		
		if (callServiceDelegate) {
			[self addDelegate:callServiceDelegate];
		}
		
		_multicastDataChannelDelegate = (SVMulticastDelegate<CallServiceDataChannelAdditionsDelegate>*)[[SVMulticastDelegate alloc] init];
		
		if (dataChannelDelegate) {
			[self addDataChannelDelegate:dataChannelDelegate];
		}
		
		_messageQueue = [NSMutableArray array];
		_factory = [[RTCPeerConnectionFactory alloc] init];
		
		_state = kClientStateDisconnected;
		
		_isAudioOnly = NO;
		
		_dataChannelEnabled = YES;
	}
	return self;
}

- (instancetype)initWithSignalingChannel:(id<SVSignalingChannelProtocol>)signalingChannel callServiceDelegate:(id<CallServiceDelegate>)callServiceDelegate {
	return [self initWithSignalingChannel:signalingChannel callServiceDelegate:callServiceDelegate dataChannelDelegate:nil];
}

- (void)addDelegate:(id<CallServiceDelegate>)delegate {
	DDLogInfo(@"Added call delegate: %@", delegate);
	[self.multicastDelegate addDelegate:delegate];
}

- (void)addDataChannelDelegate:(id<CallServiceDataChannelAdditionsDelegate>)dataChannelDelegate {
	DDLogInfo(@"Added dataChannel delegate: %@", dataChannelDelegate);
	[self.multicastDataChannelDelegate addDelegate:dataChannelDelegate];
}

- (BOOL)isConnected {
	return self.signalingChannel.state == SVSignalingChannelState.established;
}

- (BOOL)isConnecting {
	return self.signalingChannel.state == SVSignalingChannelState.open;
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
	if ([self hasActiveCall]) {
		DDLogWarn(@"Trying to call while already calling. Returning.");
		return;
	}
	
	NSParameterAssert(opponent);
	NSCAssert(![opponent.ID isEqualToNumber:@0], @"Invalid opponent ID");
	
	if (![self.signalingChannel.state isEqualToString:SVSignalingChannelState.established]) {
		DDLogWarn(@"Chat is not connected");
		return;
	}
	
	self.opponentUser = opponent;
	self.initiatorUser = self.signalingChannel.user;
	// Create peer connection.
	
	RTCMediaConstraints *constraints = [self defaultPeerConnectionConstraints];
	RTCConfiguration *config = [[RTCConfiguration alloc] init];
	config.iceServers = self.iceServers;

	self.peerConnection = [self.factory peerConnectionWithConfiguration:config constraints:constraints delegate:self];
	self.peerConnection.delegate = self;
	
	
	if (self.isDataChannelEnabled) {
		RTCDataChannelInit *dataChannelInit = [[RTCDataChannelInit alloc] init];
		self.dataChannel = [self.peerConnection createDataChannelWithLabel:@"offerDataChannel" config:dataChannelInit];
		self.dataChannel.delegate = self;
	}
	
	// Create AV media stream and add it to the peer connection.
	RTCMediaStream *localStream = [self createLocalMediaStream];
	[self.peerConnection addStream:localStream];
	
	// Send offer.
	[self.peerConnection createOfferWithDelegate:self constraints:[self defaultOfferConstraints]];

}

- (void)hangup {
	
	if (self.state == kClientStateDisconnected) {
		[self clearSession];
		return;
	}
	
	if (![[self.signalingChannel state] isEqualToString:SVSignalingChannelState.established]) {
		[self clearSession];
	}
	
	if ([self hasActiveCall]) {
		[self sendHangupToUser:self.opponentUser completion:^(NSError * _Nullable error) {
			[self clearSession];
		}];
	} else {
		[self clearSession];
	}
}

- (void)sendHangupToUser:(SVUser *)user completion:(void(^)(NSError * _Nullable error))completion {
	SVSignalingMessage *hangupMessage = [SVSignalingMessage messageWithType:SVSignalingMessageType.hangup params:nil];
	
	[self sendSignalingMessage:hangupMessage toUser:user completion:completion];
}

- (void)sendRejectToUser:(SVUser *)user completion:(void(^)(NSError * _Nullable error))completion {
	SVSignalingMessage *rejectMessage = [SVSignalingMessage messageWithType:SVSignalingMessageType.reject params:nil];
	
	[self sendSignalingMessage:rejectMessage toUser:user completion:completion];
}

- (void)sendSignalingMessage:(SVSignalingMessage *)signalingMessage toUser:(SVUser *)user completion:(void(^)(NSError * _Nullable error))completion {
	[self.signalingChannel sendMessage:signalingMessage toUser:user completion:^(NSError * _Nullable error) {
		if (error) {
			DDLogWarn(@"Error sending signaling message: %@ error: %@", signalingMessage, error);
			return;
		}
		if (completion) {
			completion(error);
		}
	}];
}

- (void)setState:(CallServiceState)state {
	if (state != _state) {
		_state = state;
		[self notifyDelegateWithCurrentState];
	}
}

- (void)notifyDelegateWithCurrentState {
	if ([self.multicastDelegate respondsToSelector:@selector(callService:didChangeState:)]) {
		[self.multicastDelegate callService:self didChangeState:self.state];
	}
}

- (void)clearSession {
	DDLogInfo(@"Clear session");
	
	self.opponentUser = nil;
	self.initiatorUser = nil;
	self.state = kClientStateDisconnected;
	for (RTCMediaStream *stream in self.peerConnection.localStreams) {
		[self.peerConnection removeStream:stream];
	}
	[self.peerConnection close];
	self.peerConnection = nil;
	
	[self.dataChannel close];
	self.dataChannel = nil;
	
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
	
	if (self.isDataChannelEnabled && self.peerConnection.iceGatheringState == RTCICEGatheringGathering) {
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
			DDLogVerbose(@"GOT ANSWER");
		}
		
		SVSignalingMessageSDP *sdpMessage = (SVSignalingMessageSDP *)message;
		NSAssert([message isKindOfClass:[SVSignalingMessageSDP class]], @"Incorrect class");
		
		RTCSessionDescription *description = sdpMessage.sdp;
		
		NSParameterAssert(description);
		
		// Prefer H264 if available.
		RTCSessionDescription *sdpPreferringH264 =
		[WebRTCHelpers descriptionForDescription:description
						   preferredVideoCodec:@"H264"];
		
		NSParameterAssert(self.peerConnection);
		[self.peerConnection setRemoteDescriptionWithDelegate:self
										   sessionDescription:sdpPreferringH264];
		
	} else if ([message.type isEqualToString:SVSignalingMessageType.candidate] ) {
		
		SVSignalingMessageICE *candidateMessage = (SVSignalingMessageICE *)message;
		NSAssert([message isKindOfClass:[SVSignalingMessageICE class]], @"Incorrect class");
		
		[self.peerConnection addICECandidate:candidateMessage.iceCandidate];
	} else if ([message.type isEqualToString:SVSignalingMessageType.hangup] ) {
		// Other client disconnected.
		[self clearSession];
	}
}

- (void)sendSignalingMessage:(SVSignalingMessage *)message {
	__weak __typeof(self)weakSelf = self;
	
	[self.signalingChannel sendMessage:message toUser:self.opponentUser completion:^(NSError * _Nullable error) {
		if (error) {
			if ([weakSelf.multicastDelegate respondsToSelector:@selector(callService:didError:)]) {
				[weakSelf.multicastDelegate callService:self didError:error];
			}
		}
	}];
}

- (RTCMediaStream *)createLocalMediaStream {
	NSParameterAssert(self.factory);
	
	RTCMediaStream *localStream = [self.factory mediaStreamWithLabel:@"ARDAMS"];
	RTCVideoTrack *localVideoTrack = [self createLocalVideoTrack];
	if (localVideoTrack) {
		[localStream addVideoTrack:localVideoTrack];
		if ([self.multicastDelegate respondsToSelector:@selector(callService:didReceiveLocalVideoTrack:)]) {
			[self.multicastDelegate callService:self didReceiveLocalVideoTrack:localVideoTrack];
		}
	}
	
	// For XCTest
	if (NSClassFromString(@"XCTest") != nil){
		if ([self.multicastDelegate respondsToSelector:@selector(callService:didReceiveLocalVideoTrack:)]) {
			[self.multicastDelegate callService:self didReceiveLocalVideoTrack:localVideoTrack];
		}
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
		
		RTCAVFoundationVideoSource *source =
		[[RTCAVFoundationVideoSource alloc] initWithFactory:self.factory
												constraints:[self defaultMediaStreamConstraints]];
		localVideoTrack =
		[[RTCVideoTrack alloc] initWithFactory:self.factory
										source:source
									   trackId:@"ARDAMSv0"];
	}
	NSParameterAssert(localVideoTrack);
	NSParameterAssert(self.factory);
#endif
	return localVideoTrack;
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
			
			[self.multicastDelegate callService:self didReceiveRemoteVideoTrack:videoTrack];
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
		if ([self.multicastDelegate respondsToSelector:@selector(callService:didChangeConnectionState:)]) {
			[self.multicastDelegate callService:self didChangeConnectionState:newState];
		}
	});
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection iceGatheringChanged:(RTCICEGatheringState)newState {
	RTCLog(@"ICE gathering state changed: %d", newState);
	[self drainMessageQueueIfReady];
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection gotICECandidate:(RTCICECandidate *)candidate {
	dispatch_async(dispatch_get_main_queue(), ^{
		SVSignalingMessageICE *message = [[SVSignalingMessageICE alloc] initWithICECandidate:candidate];
		[self sendSignalingMessage:message];
	});
}

//#pragma mark - RTCStatsDelegate
//- (void)peerConnection:(RTCPeerConnection *)peerConnection didGetStats:(NSArray *)stats {
//	dispatch_async(dispatch_get_main_queue(), ^{
//				[self.delegate client:self didGetStats:stats];
//	});
//}

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
			if ([self.multicastDelegate respondsToSelector:@selector(callService:didError:)]) {
				[self.multicastDelegate callService:self didError:sdpError];
			}
			return;
		}
		NSParameterAssert(sdp);
		//		 Prefer H264 if available.
		RTCSessionDescription *sdpPreferringH264 = [WebRTCHelpers descriptionForDescription:sdp preferredVideoCodec:@"H264"];

		NSParameterAssert(self.peerConnection);
		
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
			NSDictionary *userInfo = @{
									   NSLocalizedDescriptionKey: @"Failed to set session description.",
									   };
			NSError *sdpError = [[NSError alloc] initWithDomain:@"" code:-1
													   userInfo:userInfo];
			if ([self.multicastDelegate respondsToSelector:@selector(callService:didError:)]) {
				[self.multicastDelegate callService:self didError:sdpError];
			}
			return;
		}
		// If we're answering and we've just set the remote offer we need to create
		// an answer and set the local description.
		if (!self.isInitiator && !self.peerConnection.localDescription) {
			NSCAssert(self.peerConnection, @"Peer connection must exist");
			[self.peerConnection createAnswerWithDelegate:self
											  constraints:[self defaultAnswerConstraints]];
		}
	});
}

- (BOOL)isInitiator {
	return [self.initiatorUser isEqual:self.signalingChannel.user];
}

#pragma mark - SVSignalingChannel Delegate

- (void)channel:(id<SVSignalingChannelProtocol>)channel didReceiveMessage:(SVSignalingMessage *)message {
	
	if ([message.type isEqualToString:SVSignalingMessageType.offer]) {
		
		if ([self hasActiveCall]) {
			[self sendRejectToUser:message.sender completion:^(NSError * _Nullable error) {
				if (!error) {
					DDLogInfo(@"Sent reject to: %@", message.sender);
				}
			}];
			
			return;
		}
		
		NSCAssert(self.peerConnection == nil, @"At the time of answer there should be no active peerconnection");
		NSCAssert(!self.isInitiator, @"Invalid state, you should be answering side");
		NSCAssert(self.opponentUser == nil, @"Opponent is not nil");
		
		self.opponentUser = message.sender;
		self.initiatorUser = self.opponentUser;
		
		self.peerConnection = [self.factory peerConnectionWithConfiguration:[self defaultConfigurationWithCurrentICEServers] constraints:[self defaultAnswerConstraints] delegate:self];
		[self.peerConnection addStream:[self createLocalMediaStream]];
		self.peerConnection.delegate = self;
	}
	if ([message.type isEqualToString:SVSignalingMessageType.offer] ||
		[message.type isEqualToString:SVSignalingMessageType.answer]) {
		self.isReceivedSDP = YES;
		// Offers and answers must be processed before any other message, so we
		// place them at the front of the queue.
		[_messageQueue insertObject:message atIndex:0];
		
	} else if ([message.type isEqualToString:SVSignalingMessageType.candidate] ) {
		
		[_messageQueue addObject:message];
	} else if ([message.type isEqualToString:SVSignalingMessageType.hangup] ) {
		
		// Disconnects can be processed immediately.
		[self processSignalingMessage:message];
	}
	
	[self drainMessageQueueIfReady];
}

#pragma mark Data Channel

- (BOOL)sendText:(NSString *)text {
	if (!self.dataChannel) {
		return NO;
	}
	
	NSData *textData = [text dataUsingEncoding:NSUTF8StringEncoding];
	RTCDataBuffer *buffer = [[RTCDataBuffer alloc] initWithData:textData isBinary:NO];
	
	return [self.dataChannel sendData:buffer];
}

- (BOOL)sendData:(NSData *)data {
	if (!self.dataChannel) {
		return NO;
	}
	
	RTCDataBuffer *buffer = [[RTCDataBuffer alloc] initWithData:data isBinary:YES];
	
	return [self.dataChannel sendData:buffer];
}

- (BOOL)isDataChannelReady {
	return self.dataChannel && self.dataChannel.state == kRTCDataChannelStateOpen;
}

#pragma mark RTC Data Channel delegate

- (void)peerConnection:(RTCPeerConnection *)peerConnection didOpenDataChannel:(RTCDataChannel *)dataChannel {
	DDLogVerbose(@"peerConnection %@ didOpenDataChannel %@", peerConnection, dataChannel);
	self.dataChannel = dataChannel;
	dataChannel.delegate = self;
	
	if ([self.multicastDataChannelDelegate respondsToSelector:@selector(callService:didOpenDataChannel:)]) {
		[self.multicastDataChannelDelegate callService:self didOpenDataChannel:dataChannel];
	}
}

- (void)channelDidChangeState:(RTCDataChannel *)channel {
	DDLogVerbose(@"dataChannel %@ didChangeState: %u", channel, channel.state);
	
	//send test offer text
	if (channel.state == kRTCDataChannelStateOpen) {
		[self sendText:@"hello!"];
	}
}

- (void)channel:(RTCDataChannel *)channel didReceiveMessageWithBuffer:(RTCDataBuffer *)buffer {
	DDLogVerbose(@"dataChannel %@ didReceiveMessageWithBuffer: %@", channel, buffer);
	
	if (buffer.isBinary) {
		if ([self.multicastDataChannelDelegate respondsToSelector:@selector(callService:didReceiveData:)]) {
			[self.multicastDataChannelDelegate callService:self didReceiveData:buffer.data];
		}
	} else {
		if ([self.multicastDataChannelDelegate respondsToSelector:@selector(callService:didReceiveMessage:)]) {
			[self.multicastDataChannelDelegate callService:self didReceiveMessage:[[NSString alloc] initWithData:buffer.data encoding:NSUTF8StringEncoding]];
		}
	}
}

@end