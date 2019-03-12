//
//  ImageGalleryStoryInteractorImagesInput.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 3/3/16.
//  Copyright © 2016 anton. All rights reserved.
//

import Foundation

protocol ImageGalleryStoryCollectionViewInteractorInput: UICollectionViewDataSource {
	
	func addImage(_ image: UIImage)
	func imageAt(_ index: Int) -> UIImage?
	func imagesCount() -> Int
}

