//
//  FakeAlertControl.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 31.12.16.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import Foundation

#if QBRTCDemo_s
	@testable
	import QBRTCDemo_s
#elseif QBRTCDemo
	@testable
	import QBRTCDemo
#endif

class FakeAlertControl: AlertControlProtocol {
	
	func showErrorMessage(_ message: String, overViewController: UIViewController, completion: (() -> Void)?) {
		completion?()
	}
	
	func showMessage(_ message: String, title: String, overViewController: UIViewController?, completion: (() -> Void)?) {
		completion?()
	}
	
	func showMessage(_ message: String, title: String, overViewController: UIViewController?, actions: [UIAlertAction], completion: (() -> Void)?) {
		completion?()
	}
}
