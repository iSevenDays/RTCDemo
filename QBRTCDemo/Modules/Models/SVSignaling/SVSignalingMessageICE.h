//
//  SVSignalingMessageICE.h
//  RTCDemo
//
//  Created by Anton Sokolchenko on 11/16/15.
//  Copyright © 2015 anton. All rights reserved.
//

#import "SVSignalingMessage.h"
@class RTCICECandidate;
@class SessionDetails;

@interface SVSignalingMessageICE : SVSignalingMessage

- (nonnull instancetype)initWithICECandidate:(nonnull RTCICECandidate *)iceCandidate sessionDetails:(SessionDetails *_Nonnull)sessiondetails;

@property (nonatomic, strong, readonly, nonnull) RTCICECandidate *iceCandidate;

@end
