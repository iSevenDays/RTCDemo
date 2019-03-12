//
//  AlertControl.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 21.12.16.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import Foundation

class AlertControl: AlertControlProtocol {
	
	func showMessage(_ message: String, title: String, overViewController: UIViewController?, actions: [UIAlertAction] , completion: (() -> Void)? = nil) {
		
		let alertControl = UIAlertController(title: title, message: message, preferredStyle: .alert)
		
		for action in actions {
			alertControl.addAction(action)
		}
		
		if let viewController = overViewController {
			viewController.present(alertControl, animated: true, completion: nil)
		} else {
			UIApplication.shared.keyWindow?.rootViewController?.present(alertControl, animated: true, completion: completion)
		}
	}
	
	func showMessage(_ message: String, title: String, overViewController: UIViewController?, completion: (() -> Void)? = nil) {
		
		let okAction = UIAlertAction(title: "Ok" , style: .default) { action in
			completion?()
		}
		
		self.showMessage(message, title: title, overViewController: overViewController, actions: [okAction], completion: completion)
	}
	
	func showErrorMessage(_ message: String, overViewController: UIViewController, completion: (() -> Void)? = nil) {
		
		self.showMessage(message, title: "Error", overViewController: overViewController, completion: completion)
	}
}
