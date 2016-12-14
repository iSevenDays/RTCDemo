//
//  BaseTestCase.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 05.12.16.
//  Copyright © 2016 anton. All rights reserved.
//

import Foundation
import XCTest

class BaseTestCase: XCTestCase {
	func segues(ofViewController viewController: UIViewController) -> [String] {
		let identifiers = (viewController.valueForKey("storyboardSegueTemplates") as? [AnyObject])?.flatMap({ $0.valueForKey("identifier") as? String }) ?? []
		return identifiers
	}
	
	func waitForTimeInterval(seconds: UInt64) {
		var waitCondition = true
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * NSEC_PER_SEC)), dispatch_get_main_queue()) {
			waitCondition = false
		}
		while(waitCondition) { NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: NSDate.distantFuture()) }
	}
}
