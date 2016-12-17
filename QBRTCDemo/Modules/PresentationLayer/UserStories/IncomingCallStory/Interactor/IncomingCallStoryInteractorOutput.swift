//
//  IncomingCallStoryInteractorOutput.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 15/05/2016.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import Foundation

protocol IncomingCallStoryInteractorOutput: class {
	// The opponent decided to cancel the offer
	func didReceiveHangupForIncomingCall()
}
