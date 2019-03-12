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
		let identifiers = (viewController.value(forKey: "storyboardSegueTemplates") as? [AnyObject])?.compactMap({ $0.value(forKey: "identifier") as? String }) ?? []
		return identifiers
	}
	
	func waitForTimeInterval(_ milliseconds: UInt64) {
		var waitCondition = true
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(milliseconds * NSEC_PER_MSEC)) / Double(NSEC_PER_SEC)) {
			waitCondition = false
		}
		while(waitCondition) { RunLoop.current.run(mode: RunLoop.Mode.default, before: Date.distantFuture) }
	}
}
