//
//  SVTimer.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 07.12.16.
//  Copyright © 2016 anton. All rights reserved.
//

import Foundation

class SVTimer: NSObject {
	private var timer: dispatch_source_t
	private(set) var interval: UInt64 // milliseconds
	private(set) var repeats: Bool
	var leeway: UInt64
	
	var isValid: Bool {
		return dispatch_source_testcancel(timer) != 0
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
		timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue)
		dispatch_source_set_event_handler(timer, block)
	}
	
	/**
	Start the timer
	The timer fires once after the specified delay plus the specified tolerance.
	*/
	func start() {
		// repeatedInterval - The nanosecond interval for the timer. Use DISPATCH_TIME_FOREVER for a one-shot timer.
		let repeatedInterval = repeats ? interval : DISPATCH_TIME_FOREVER
		dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, Int64(interval * NSEC_PER_MSEC)), repeatedInterval, UInt64(leeway * NSEC_PER_MSEC))
		dispatch_resume(timer)
	}
	
	/// Cancel the timer
	func cancel() {
		dispatch_source_cancel(timer)
	}
}
