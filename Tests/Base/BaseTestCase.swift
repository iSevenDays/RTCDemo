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
}
