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
class DesignableImageView: UIImageView {
}


@IBDesignable
class DesignableView: UIView {
}

@IBDesignable
class DesignableButton: UIButton {
	@IBInspectable var normalBackgroundColor: UIColor? {
		didSet {
			updateSelectedBackgrounColor()
			setNeedsDisplay()
		}
	}
	
	@IBInspectable var selectedBackgroundColor: UIColor? {
		didSet {
			updateSelectedBackgrounColor()
			setNeedsDisplay()
		}
	}
	
	@IBInspectable var highlightedBackgroundColor: UIColor? {
		didSet {
			setNeedsDisplay()
		}
	}
	
	override var isHighlighted: Bool {
		didSet {
			guard highlightedBackgroundColor != nil else { return }
			if isHighlighted {
				layer.backgroundColor = highlightedBackgroundColor?.cgColor
			} else {
				layer.backgroundColor = normalBackgroundColor?.cgColor
			}
			setNeedsDisplay()
		}
	}
	
	override var isSelected: Bool {
		didSet {
			updateSelectedBackgrounColor()
			setNeedsDisplay()
		}
	}
	
	func updateSelectedBackgrounColor() {
		if isSelected {
			layer.backgroundColor = selectedBackgroundColor?.cgColor
		} else {
			layer.backgroundColor = normalBackgroundColor?.cgColor
		}
	}
}
