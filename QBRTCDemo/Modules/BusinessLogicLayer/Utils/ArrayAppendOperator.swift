//
//  ArrayAppendOperator.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 09.12.16.
//  Copyright © 2016 anton. All rights reserved.
//

import Foundation

extension Array {
	
}

func += <V> (inout left: [V], right: V) {
	left.append(right)
}
