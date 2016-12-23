//
//  UIView+Shake.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 22.12.16.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import Foundation


extension UIView {
	
	func shake(count : Float? = nil,for duration : NSTimeInterval? = nil,withTranslation translation : Float? = nil) {
		let animation : CABasicAnimation = CABasicAnimation(keyPath: "transform.translation.x")
		animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
		
		animation.repeatCount = count ?? 2
		animation.duration = (duration ?? 0.5)/NSTimeInterval(animation.repeatCount)
		animation.autoreverses = true
		animation.byValue = translation ?? -5
		layer.addAnimation(animation, forKey: "shake")
	}
}
