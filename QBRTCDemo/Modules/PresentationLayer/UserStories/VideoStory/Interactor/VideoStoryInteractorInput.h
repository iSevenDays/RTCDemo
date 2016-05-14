//
//  VideoStoryInteractorInput.h
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 20/01/2016.
//  Copyright 2016 Anton Sokolchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SVUser;

@protocol VideoStoryInteractorInput <NSObject>

- (void)connectToChatWithUser:(SVUser *)user callOpponent:(SVUser *)opponent;

// Pass nil to call the opponent again
- (void)startCallWithOpponent:(SVUser *)opponent;
- (void)hangup;

- (void)requestDataChannelState;

// Triggers didSendInvitationToOpenImageGallery if successful
- (void)sendInvitationMessageAndOpenImageGallery;

@end