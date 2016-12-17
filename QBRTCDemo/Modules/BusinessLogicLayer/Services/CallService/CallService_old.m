//
//  CallService.m
//  RTCDemo
//
//  Created by Anton Sokolchenko on 1/25/16.
//  Copyright © 2016 anton. All rights reserved.
//

// TODO: re-implement data channel methods

@interface CallService()<RTCDataChannelDelegate>

@property (atomic, strong) NSMutableArray *messageQueue;
@property (nonatomic, strong) RTCPeerConnectionFactory *factory;
@property (nonatomic, strong) RTCDataChannel *dataChannel;


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

@end
