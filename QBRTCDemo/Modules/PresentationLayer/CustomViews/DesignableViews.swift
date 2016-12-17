//
//  DesignableView.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 17.12.16.
//  Copyright © 2016 Anton Sokolchenko. All rights reserved.
//

import Foundation

extension UIView {
	@IBInspectable var cornerRadius: CGFloat {
		get {
			return layer.cornerRadius
		}
		set {
			layer.cornerRadius = newValue
			layer.masksToBounds = newValue > 0
		}
	}
}


@IBDesignable
class DesignableView: UIView {
	
}

@IBDesignable
class DesignableButton: UIButton {
	
}
