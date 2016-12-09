//
//  CallService.m
//  RTCDemo
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

#import "QBRTCDemo_s-Swift.h"

@interface CallService()<SVSignalingChannelDelegate, RTCPeerConnectionDelegate, RTCSessionDescriptionDelegate, RTCDataChannelDelegate, SignalingProcessorObserver>

@property (atomic, strong) NSMutableArray *messageQueue;
@property (nonatomic, strong) RTCPeerConnectionFactory *factory;
@property (nonatomic, strong) RTCDataChannel *dataChannel;

@property (nonatomic, assign) BOOL isReceivedSDP;
@property (nonatomic, assign, getter=isInitiator) BOOL initiator;
@property (nonatomic, assign) BOOL isAudioOnly;

/// Local offer to send to opponent
@property (nonatomic, strong) SVSignalingMessageSDP *localPendingSDPSignalingMessage;
@property (nonatomic, strong) SVTimer *dialingTimer;
@property (nonatomic, assign) NSUInteger dialingTimerTimeout;
@property (nonatomic, assign) NSUInteger dialingInterval;

// SVUser ID : pending request
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, CallServicePendingRequest *> *pendingRequests;

// Currently supported only 1 active session at a time
// Session Identifier : sessionDetails
@property (nonatomic, strong) NSMutableDictionary<NSString *, SessionDetails *> *sessions;

@property (nonatomic, strong) SignalingProcessor *signalingProcessor;

@end

@implementation CallService

@synthesize dataChannelEnabled = _dataChannelEnabled;

- (instancetype)initWithSignalingChannel:(id<SVSignalingChannelProtocol>)signalingChannel callServiceDelegate:(id<CallServiceDelegate>)callServiceDelegate dataChannelDelegate:(id<CallServiceDataChannelAdditionsDelegate>)dataChannelDelegate {
	
	NSParameterAssert(signalingChannel);
	
	self = [super init];
	
	if (self) {
		_signalingChannel = signalingChannel;
		[_signalingChannel addDelegate:self];
		_multicastDelegate = (SVMulticastDelegate<CallServiceDelegate>*)[[SVMulticastDelegate alloc] init];
		
		_signalingProcessor = [[SignalingProcessor alloc] init];
		[_signalingChannel addDelegate:_signalingProcessor];
		_signalingProcessor.observer = self;
		if (callServiceDelegate) {
			[self addDelegate:callServiceDelegate];
		}
		
		_multicastDataChannelDelegate = (SVMulticastDelegate<CallServiceDataChannelAdditionsDelegate>*)[[SVMulticastDelegate alloc] init];
		
		if (dataChannelDelegate) {
			[self addDataChannelDelegate:dataChannelDelegate];
		}
		
		_messageQueue = [NSMutableArray array];
		_pendingRequests = [NSMutableDictionary dictionary];
		_sessions = [NSMutableDictionary dictionary];
		_factory = [[RTCPeerConnectionFactory alloc] init];
		
		_state = kClientStateDisconnected;
		
		_isAudioOnly = NO;
		
		_dataChannelEnabled = YES;
		
		_dialingInterval = 9;
		_dialingTimerTimeout = 10;
	}
	return self;
}

- (instancetype)initWithSignalingChannel:(id<SVSignalingChannelProtocol>)signalingChannel {
	return [self initWithSignalingChannel:signalingChannel callServiceDelegate:nil];
}

- (instancetype)initWithSignalingChannel:(id<SVSignalingChannelProtocol>)signalingChannel callServiceDelegate:(id<CallServiceDelegate>)callServiceDelegate {
	return [self initWithSignalingChannel:signalingChannel callServiceDelegate:callServiceDelegate dataChannelDelegate:nil];
}

- (void)addDelegate:(id<CallServiceDelegate>)delegate {
	DDLogInfo(@"Added call delegate: %@", delegate);
	[self.multicastDelegate addDelegate:delegate];
}

- (NSArray *)delegates {
	return [self.multicastDelegate delegates].allObjects;
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

- (SessionDetails *)activeSession {
	NSMutableArray *activeSessions = [NSMutableArray array];
	
	for (SessionDetails *sessionDetails in [self.sessions allValues]) {
		if ([sessionDetails sessionState] != SessionDetailsStateClosed || [sessionDetails sessionState] != SessionDetailsStateRejected) {
			[activeSessions addObject:sessionDetails];
		}
	}
	NSAssert(activeSessions.count == 0 || activeSessions.count == 1, @"Wrong number of active session");
	return activeSessions.firstObject;
}

- (void)connectWithUser:(SVUser *)user completion:(void(^)(NSError *error))completion {
	
	NSParameterAssert(self.signalingChannel);
	NSParameterAssert(user.password);
	
	if (self.state == kClientStateConnecting) {
		if (completion != nil) {
			completion([[NSError alloc] initWithDomain:@"CallServiceErrorDomain" code:-1 userInfo:@{@"Error": @"Trying to connect while already connecting, return"}]);
		}
		return;
	}
	
	if (self.state == kClientStateConnected) {
		if (completion != nil) {
			completion(nil);
		}
		return;
	}
	
	self.state = kClientStateConnecting;
	__weak __typeof(self)weakSelf = self;
	[self.signalingChannel connectWithUser:user completion:^(NSError * _Nullable error) {
		__typeof(self)strongSelf = weakSelf;
		if (error != nil) {
			strongSelf.state = kClientStateDisconnected;
		} else {
			strongSelf.state = kClientStateConnected;
		}
		if (completion != nil) {
			completion(error);
		}
	}];
}

- (void)disconnectWithCompletion:(void (^)(NSError * _Nullable))completion {
	if (self.state == kClientStateDisconnected) {
		if (completion != nil) {
			completion(nil);
		}
		return;
	}
	
	__weak __typeof(self) weakSelf = self;
	
	[self.signalingChannel disconnectWithCompletion:^(NSError * _Nullable error) {
		if (error == nil) {
			weakSelf.state = kClientStateDisconnected;
		}
		if (completion != nil) {
			completion(error);
		}
	}];
}

- (void)startCallWithOpponent:(SVUser *)opponent {
	if ([self hasActiveCall]) {
		DDLogError(@"Trying to call while already calling. Returning.");
		return;
	}
	
	NSParameterAssert(opponent);
	NSCAssert(![opponent.ID isEqualToNumber:@0], @"Invalid opponent ID");
	
	if (![self.signalingChannel.state isEqualToString:SVSignalingChannelState.established]) {
		DDLogWarn(@"Chat is not connected");
		return;
	}
	
	SessionDetails *sessionDetails = [[SessionDetails alloc] initWithInitiator:self.currentUser membersIDs:@[opponent.ID, self.currentUser.ID]];
	self.sessions[sessionDetails.sessionID] = sessionDetails;
	
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

- (void)acceptCallFromOpponent:(SVUser *)opponent {
	
	SVSignalingMessage *offerSignalingMessage = nil;
	
	for (CallServicePendingRequest *request in self.pendingRequests.allValues) {
		if ([request.initiator isEqual:opponent]) {
			offerSignalingMessage = request.offerSignalingMessage;
		}
	}
	NSParameterAssert(offerSignalingMessage);
	
	SessionDetails *sessionDetails = [[SessionDetails alloc] initWithSignalingMessage:offerSignalingMessage];
	sessionDetails.sessionState = SessionDetailsStateOfferReceived;
	self.sessions[sessionDetails.sessionID] = sessionDetails;
	
	self.peerConnection = [self.factory peerConnectionWithConfiguration:[self defaultConfigurationWithCurrentICEServers] constraints:[self defaultAnswerConstraints] delegate:self];
	[self.peerConnection addStream:[self createLocalMediaStream]];
	self.peerConnection.delegate = self;
	
	[_messageQueue insertObject:offerSignalingMessage atIndex:0];
	self.isReceivedSDP = YES;

	[self drainMessageQueueIfReady];
}

- (void)hangup {
	
	if (self.state == kClientStateDisconnected) {
		[self clearSession];
		return;
	}
	
	if ([self hasActiveCall] && [self.signalingChannel.state isEqualToString:SVSignalingChannelState.established]) {
		
		for (NSNumber *opponentID in [self.activeSession membersIDs]) {
			SVUser *opponent = [self.cacheService cachedUserWithID:opponentID.intValue];
			if (opponent != nil) {
				[self sendHangupToUser:opponent completion:^(NSError * _Nullable error) {
					if (error) {
						DDLogWarn(@"Did not send hangup to the opponent %@", opponent);
					}
				}];
			}
		}
	}
	
	[self clearSession];
}

- (void)sendHangupToUser:(SVUser *)user completion:(void(^)(NSError * _Nullable error))completion {
	SVSignalingMessage *hangupMessage = [SVSignalingMessage messageWithType:SVSignalingMessageType.hangup params:nil];
	
	[self sendSignalingMessage:hangupMessage toUser:user completion:completion];
}

- (void)sendRejectToUser:(SVUser *)user completion:(void(^)(NSError * _Nullable error))completion {
	
	for (SessionDetails *sessionDetails in [self.sessions allValues]) {
		if ([sessionDetails initiatorID] == user.ID.unsignedIntegerValue) {
			sessionDetails.sessionState = SessionDetailsStateRejected;
		}
	}
	
	SVSignalingMessage *rejectMessage = [SVSignalingMessage messageWithType:SVSignalingMessageType.reject params:nil];
	[self sendSignalingMessage:rejectMessage toUser:user completion:completion];
}

- (void)sendSignalingMessageToActiveSessionUsers:(SVSignalingMessage *)signalingMessage {
	
	NSParameterAssert(self.activeSession);
	
	for (NSNumber *opponentID in [self.activeSession membersIDs]) {
		SVUser *opponent = [self.cacheService cachedUserWithID:opponentID.intValue];
		if (opponent != nil && ![opponent.ID isEqualToNumber:self.currentUser.ID]) {
			signalingMessage.sessionID = self.activeSession.sessionID;
			signalingMessage.membersIDs = self.activeSession.membersIDs;
			signalingMessage.initiatorID = @(self.activeSession.initiatorID);
			
			[self.signalingChannel sendMessage:signalingMessage toUser:opponent completion:^(NSError * _Nullable error) {
				if (error) {
					DDLogWarn(@"Error sending signaling message: %@ error: %@", signalingMessage, error);
				}
			}];
		}
	}
}

- (void)sendSignalingMessage:(SVSignalingMessage *)signalingMessage toUser:(SVUser *)user completion:(void(^)(NSError * _Nullable error))completion {
	
	[self.signalingChannel sendMessage:signalingMessage toUser:user completion:^(NSError * _Nullable error) {
		if (error) {
			DDLogWarn(@"Error sending signaling message: %@ error: %@", signalingMessage, error);
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
	[self stopDialing];
	
	for (RTCMediaStream *stream in self.peerConnection.localStreams) {
		[self.peerConnection removeStream:stream];
	}
	[self.peerConnection close];
	self.peerConnection = nil;
	
	[self.dataChannel close];
	self.dataChannel = nil;
	
	self.isReceivedSDP = NO;
	self.messageQueue = [NSMutableArray array];
	
	self.localPendingSDPSignalingMessage = nil;
}

- (BOOL)hasActiveCall {
	return [self activeSession] != nil;
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
		
	} else if ([message.type isEqualToString:SVSignalingMessageType.candidates] ) {
		
		SVSignalingMessageICE *candidateMessage = (SVSignalingMessageICE *)message;
		NSAssert([message isKindOfClass:[SVSignalingMessageICE class]], @"Incorrect class");
		
		[self.peerConnection addICECandidate:candidateMessage.iceCandidate];
	} else if ([message.type isEqualToString:SVSignalingMessageType.hangup] ) {
		if ([self.multicastDelegate respondsToSelector:@selector(callService:didReceiveHangupFromOpponent:)]) {
			[self.multicastDelegate callService:self didReceiveHangupFromOpponent:message.sender];
		}
		[self clearSession];
	} else if ([message.type isEqualToString:SVSignalingMessageType.reject]) {
		if ([self.multicastDelegate respondsToSelector:@selector(callService:didReceiveRejectFromOpponent:)]) {
			[self.multicastDelegate callService:self didReceiveRejectFromOpponent:message.sender];
		}
		[self clearSession];
	}
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

- (SVUser *)currentUser {
	return self.signalingChannel.user;
}

#pragma mark - SignalingProcessor observer

- (void)didReceiveICECandidates:(SignalingProcessor * _Nonnull)signalingProcessor fromOpponent:(SVUser * _Nonnull)fromOpponent sessionDetails:(SessionDetails * _Nonnull)sessionDetails signalingMessage:(SVSignalingMessageICE * _Nonnull)signalingMessage {
	[_messageQueue addObject:signalingMessage];
}

- (void)didReceiveOffer:(SignalingProcessor * _Nonnull)signalingProcessor fromOpponent:(SVUser * _Nonnull)fromOpponent sessionDetails:(SessionDetails * _Nonnull)sessionDetails signalingMessage:(SVSignalingMessageSDP * _Nonnull)signalingMessage {
	SessionDetails *existentSession = self.sessions[sessionDetails.sessionID];
	if (existentSession == nil) {
		self.sessions[sessionDetails.sessionID] = sessionDetails;
	}
	BOOL shouldRejectCall = [self hasActiveCall] ;
	
	if (!shouldRejectCall) {
		shouldRejectCall = existentSession.sessionState == SessionDetailsStateRejected;
	}
	
	if (shouldRejectCall) {
		[self sendRejectToUser:fromOpponent completion:^(NSError * _Nullable error) {
			if (!error) {
				DDLogInfo(@"Sent reject to: %@", fromOpponent);
			}
		}];
		
		return;
	}
	
	NSCAssert(self.peerConnection == nil, @"At the time of answer there should be no active peerconnection");
	NSCAssert(!self.isInitiator, @"Invalid state, you should be answering side");
	
	if (self.pendingRequests[fromOpponent.ID] == nil) {
		CallServicePendingRequest *pendingRequest = [[CallServicePendingRequest alloc] initWithOfferSignalingMessage:signalingMessage];
		self.pendingRequests[fromOpponent.ID] = pendingRequest;
		
		
		[self.multicastDelegate callService:self didReceiveCallRequestFromOpponent:pendingRequest.initiator];
	}
	
	[self drainMessageQueueIfReady];
}

- (void)didReceiveAnswer:(SignalingProcessor * _Nonnull)signalingProcessor fromOpponent:(SVUser * _Nonnull)fromOpponent sessionDetails:(SessionDetails * _Nonnull)sessionDetails signalingMessage:(SVSignalingMessageSDP * _Nonnull)signalingMessage {
	SessionDetails *existentSession = self.sessions[sessionDetails.sessionID];
	if (existentSession == nil) {
		NSLog(@"Warning: received answer for undefined session %@", existentSession);
		return;
	}
	existentSession.sessionState = SessionDetailsStateAnswerReceived;
	self.isReceivedSDP = YES;
	// Offers and answers must be processed before any other message, so we
	// place them at the front of the queue.
	[_messageQueue insertObject:signalingMessage atIndex:0];
 
	[self drainMessageQueueIfReady];
}

- (void)didReceiveHangup:(SignalingProcessor * _Nonnull)signalingProcessor fromOpponent:(SVUser * _Nonnull)fromOpponent sessionDetails:(SessionDetails * _Nonnull)sessionDetails signalingMessage:(SVSignalingMessage * _Nonnull)signalingMessage {
	// Handle only messages from current call (if exists)
	// Everybody is able to send current user hangup messages
	SessionDetails *existentSessionDetails = self.sessions[sessionDetails.sessionID];
	if (existentSessionDetails == nil) {
		// Hangup for undefined session
		return;
	}
	if (existentSessionDetails.sessionState != SessionDetailsStateClosed && existentSessionDetails.sessionState != SessionDetailsStateRejected) {
		// Disconnects can be processed immediately.
		[self processSignalingMessage:signalingMessage];
	}
	[self drainMessageQueueIfReady];
}

- (void)didReceiveReject:(SignalingProcessor * _Nonnull)signalingProcessor fromOpponent:(SVUser * _Nonnull)fromOpponent sessionDetails:(SessionDetails * _Nonnull)sessionDetails signalingMessage:(SVSignalingMessage * _Nonnull)signalingMessage {
	// Handle only messages from current call (if exists)
	// Everybody is able to send current user reject messages
	SessionDetails *existentSessionDetails = self.sessions[sessionDetails.sessionID];
	if (existentSessionDetails == nil) {
		// Reject for undefined session
		return;
	}
	if (existentSessionDetails.sessionState != SessionDetailsStateClosed && existentSessionDetails.sessionState != SessionDetailsStateRejected) {
		// Disconnects can be processed immediately.
		[self processSignalingMessage:signalingMessage];
	}
	[self.sessions[sessionDetails.sessionID] setSessionState:SessionDetailsStateRejected];
	[self drainMessageQueueIfReady];
}

- (void)channel:(id<SVSignalingChannelProtocol>)channel didChangeState:(NSString *)signalingState {
	if ([signalingState isEqualToString:SVSignalingChannelState.error] ||
		[signalingState isEqualToString:SVSignalingChannelState.closed]) {
		self.state = kClientStateDisconnected;
		[self clearSession];
	}
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
		//
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

#pragma mark - Timed actions, dialing, waiting etc

/// Will repeatedly send offer signaling messages in case user was not in application or just launch it
- (void)startDialing {
	
	NSParameterAssert([self activeSession]);
	SessionDetails *sessionDetails = [self activeSession];
	NSAssert(self.sessions.allKeys.count > 0, @"Session details must be saved to 'sessions' dictionary");
	NSDate *startedDialingDate = [NSDate date];
	__weak __typeof(self)weakSelf = self;
	self.dialingTimer = [[SVTimer alloc] initWithInterval:self.dialingInterval tolerance:1000 repeats:YES queue:dispatch_get_main_queue() block: ^{
		
		__typeof(self)strongSelf = weakSelf;
		
		if ([strongSelf activeSession] == nil) {
			[strongSelf stopDialing];
			return;
		}
		
		NSTimeInterval passedSeconds = [[NSDate date] timeIntervalSinceDate:startedDialingDate];
		if (passedSeconds > strongSelf.dialingTimerTimeout) {
			if ([strongSelf.multicastDelegate respondsToSelector:@selector(callService:didAnswerTimeoutForOpponent:)]) {
				//TODO: fix[strongSelf.multicastDelegate callService:strongSelf didAnswerTimeoutForOpponent:strongSelf.opponentUser];
			}
			[strongSelf stopDialing];
		} else {
			sessionDetails.sessionState = SessionDetailsStateOfferSent;
			[strongSelf sendSignalingMessageToActiveSessionUsers:strongSelf.localPendingSDPSignalingMessage];
		}
	}];
	[self.dialingTimer start];
}

- (void)stopDialing {
	[self.dialingTimer cancel];
}

@end
