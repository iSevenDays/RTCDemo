//
//  CallServiceDataChannelAdditionsProtocol.h
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 2/13/16.
//  Copyright © 2016 anton. All rights reserved.
//

#ifndef CallServiceDataChannelAdditionProtocol_h
#define CallServiceDataChannelAdditionProtocol_h

#import <Foundation/Foundation.h>

@protocol CallServiceDataChannelAdditionsProtocol <NSObject>

/**
 *  When enabled, connection will be created with data channel support
 *  Has no effect when already in a call
 *  By default enabled
 */
@property (nonatomic, assign, getter=isDataChannelEnabled) BOOL dataChannelEnabled;

- (void)sendText:(NSString *)text;
- (void)sendData:(NSData *)data;

@end

#endif /* CallServiceDataChannelAdditionProtocol_h */
