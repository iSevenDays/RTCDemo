//
//  SVTimer.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 07.12.16.
//  Copyright © 2016 anton. All rights reserved.
//

import Foundation

class SVTimer: NSObject {
	private var timer: dispatch_source_t?
	private(set) var interval: UInt64 // milliseconds
	private(set) var repeats: Bool
	private(set) var block: dispatch_block_t
	private(set) var queue: dispatch_queue_t
	var leeway: UInt64
	
	var isValid: Bool {
		if let timer = timer {
			return dispatch_source_testcancel(timer) != 0
		}
		return false
	}
	
	/*
	 * Initialize a timer
	 * 
	 * @param interval - interval in milliseconds after wich a timer will be started,
	 * if repeats - block will be called until cancelled with given time interval
	 * 
	 * @param tolerance - a tolerance in milliseconds the fire data can deviate
	 * Must be positive. Can improve battery life
	*/
	init(interval: UInt64, tolerance: UInt64, repeats: Bool, queue: dispatch_queue_t, block: dispatch_block_t) {
		self.interval = interval
		leeway = tolerance
		self.repeats = repeats
		self.queue = queue
		self.block = block
	}
	
	/**
	Start the timer
	The timer fires once after the specified delay plus the specified tolerance.
	*/
	func start() {
		guard timer == nil else { return } // double start
		
		timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue)
		dispatch_source_set_event_handler(timer!, block)
		// repeatedInterval - The nanosecond interval for the timer. Use DISPATCH_TIME_FOREVER for a one-shot timer.
		
		let repeatedInterval = repeats ? UInt64(interval * NSEC_PER_MSEC) : DISPATCH_TIME_FOREVER
		dispatch_source_set_timer(timer!, dispatch_time(DISPATCH_TIME_NOW, Int64(interval * NSEC_PER_MSEC)), repeatedInterval, UInt64(leeway * NSEC_PER_MSEC))
		dispatch_resume(timer!)	
	}
	
	/// Cancel the timer
	func cancel() {
		if let timer = timer {
			if isValid {
				dispatch_source_cancel(timer)
			}
		}
		timer = nil
	}
	
	deinit {
		cancel()
	}
}
