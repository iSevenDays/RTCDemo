//
//  ImageGalleryStoryInteractorImagesInput.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 3/3/16.
//  Copyright © 2016 anton. All rights reserved.
//

import Foundation

protocol ImageGalleryStoryCollectionViewInteractorInput: UICollectionViewDataSource {
	
	func addImage(image: UIImage)
	func imageAt(index: Int) -> UIImage?
	func imagesCount() -> Int
}

