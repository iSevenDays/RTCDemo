//
//  AlertControlProtocol.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 30.12.16.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import Foundation

protocol AlertControlProtocol: class {
	func showMessage(_ message: String, title: String, overViewController: UIViewController?, actions: [UIAlertAction] , completion: (() -> Void)?)
	func showMessage(_ message: String, title: String, overViewController: UIViewController?, completion: (() -> Void)?)
	func showErrorMessage(_ message: String, overViewController: UIViewController, completion: (() -> Void)?)
}
