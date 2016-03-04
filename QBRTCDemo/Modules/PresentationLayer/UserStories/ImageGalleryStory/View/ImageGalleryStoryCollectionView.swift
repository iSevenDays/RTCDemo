//
//  ImageGalleryStoryCollectionView.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 3/3/16.
//  Copyright © 2016 anton. All rights reserved.
//

import Foundation

class ImageGalleryStoryCollectionView: UICollectionView {
	
	var interactor :protocol<UICollectionViewDataSource, ImageGalleryStoryCollectionViewInteractorInput, ImageGalleryStoryInteractorImagesOutput>!
	
	
}