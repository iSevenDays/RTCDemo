//
//  TimersFactory.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 13.12.16.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import Foundation

// Timers Factory is used to create timers with default settings
class TimersFactory {
	
	// in milliseconds
	let dialingTimeInterval: UInt64 = 5000
	
	// in milliseconds
	let tolerance: UInt64 = 500
	
	/*
	* @param block - will be called repeatedly with time interval (in milliseconds)
	* specified in dialingTimeInterval
	* 
	* @param expirationBlock - will be called after timer expires, call may be delayed as specified in 'tolerance'
	*/
	func createDialingTimerWithExpirationTime(_ expirationTime: TimeInterval, block: @escaping () -> Void?, expirationBlock: @escaping () -> Void) -> SVTimer {
		let startTime = CACurrentMediaTime()
		
		return SVTimer(interval: DispatchTimeInterval.milliseconds(Int(dialingTimeInterval)), tolerance: Int(tolerance), repeats: true, queue: DispatchQueue.main, block: {
			
			let elapsedTimeInSeconds = CACurrentMediaTime() - startTime
			let elapsedTimeMilliSeconds = elapsedTimeInSeconds * 1000
			
			guard elapsedTimeMilliSeconds < expirationTime else {
				expirationBlock()
				return
			}
			
			block()
		})
	}
	
}
