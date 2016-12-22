//
//  AlertControl.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 21.12.16.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import Foundation


class AlertControl {
	
	class func showMessage(message: String, title: String, overViewController: UIViewController?, actions: [UIAlertAction] , completion: (() -> Void)? = nil){
		
		let alertControl = UIAlertController(title: title, message: message, preferredStyle: .Alert)
		
		for action in actions {
			alertControl.addAction(action)
		}
		
		if let viewController = overViewController {
			viewController.presentViewController(alertControl, animated: true, completion: nil)
		} else {
			UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alertControl, animated: true, completion: completion)
		}
	}
	
	class func showMessage(message: String, title: String, overViewController: UIViewController?, completion: (() -> Void)? = nil){
		
		let okAction = UIAlertAction(title: "Ok" , style: .Default) { action in
			completion?()
		}
		
		self.showMessage(message, title: title, overViewController: overViewController, actions: [okAction], completion: completion)
	}
	
	class func showErrorMessage(message: String, overViewController: UIViewController){
		
		self.showMessage(message, title: "Error", overViewController: overViewController)
	}
}
