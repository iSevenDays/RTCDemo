//
//  SVSignalingMessageICE.h
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 11/16/15.
//  Copyright © 2015 anton. All rights reserved.
//

#import "SVSignalingMessage.h"
@class RTCICECandidate;

@interface SVSignalingMessageICE : SVSignalingMessage

- (instancetype)initWithICECandidate:(RTCICECandidate *)iceCandidate;

@property (nonatomic, strong, readonly) RTCICECandidate *iceCandidate;

@end
