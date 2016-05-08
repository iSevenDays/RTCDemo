//
//  XCTest+Optionals.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 07/05/16.
//  Copyright © 2016 anton. All rights reserved.
//

import Foundation
import XCTest

extension XCTestCase {
	
	func XCTAssertEqualOptional<T: Equatable>(@autoclosure a: () -> [T]?, @autoclosure _ b: () -> [T]?, _ message: String? = nil, file: StaticString = #file, line: UInt = #line) {
		if let _a = a() {
			if let _b = b() {
				XCTAssertEqual(_a, _b, (message != nil ? message! : ""), file: file, line: line)
			} else {
				XCTFail((message != nil ? message! : "a != nil, b == nil"), file: file, line: line)
			}
		} else if b() != nil {
			XCTFail((message != nil ? message! : "a == nil, b != nil"), file: file, line: line)
		}
	}
	
}