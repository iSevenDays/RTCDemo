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
	 * @param block - will be called repeatedly with time interval
     * specified in dialingTimeInterval
	 */
	func createDialingTimerWithBlock(block: () -> Void) -> SVTimer {
		return SVTimer(interval: dialingTimeInterval, tolerance: tolerance, repeats: true, queue: dispatch_get_main_queue(), block: block)
	}
	
	/*
	* @param block - will be called repeatedly with time interval (in milliseconds)
	* specified in dialingTimeInterval
	* 
	* @param expirationBlock - will be called after timer expires, call may be delayed as specified in 'tolerance'
	*/
	func createDialingTimerWithExpirationTime(expirationTime: NSTimeInterval, block: () -> Void?, expirationBlock: () -> Void) -> SVTimer {
		let startTime = CACurrentMediaTime()
		
		return SVTimer(interval: dialingTimeInterval, tolerance: tolerance, repeats: true, queue: dispatch_get_main_queue(), block: {
			let elapsedTime = CACurrentMediaTime() - startTime
			
			guard elapsedTime < expirationTime else {
				expirationBlock()
				return
			}
			
			block()
		})
	}
	
}
