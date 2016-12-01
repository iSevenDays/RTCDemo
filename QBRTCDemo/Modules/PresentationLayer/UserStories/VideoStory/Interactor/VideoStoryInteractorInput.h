//
//  VideoStoryInteractorInput.h
//  RTCDemo
//
//  Created by Anton Sokolchenko on 20/01/2016.
//  Copyright 2016 Anton Sokolchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SVUser;

@protocol VideoStoryInteractorInput <NSObject>

- (void)connectToChatWithUser:(SVUser *)user callOpponent:(nullable SVUser *)opponent;

- (void)startCallWithOpponent:(SVUser *)opponent;

/**
 *  Accept existent call request from opponent
 *
 *  @param opponent SVUser instance
 */
- (void)acceptCallFromOpponent:(SVUser *)opponent;

/// Hangup an active call
- (void)hangup;

- (void)requestDataChannelState;

/// Triggers didSendInvitationToOpenImageGallery if successful
- (void)sendInvitationMessageAndOpenImageGallery;

@end

NS_ASSUME_NONNULL_END
