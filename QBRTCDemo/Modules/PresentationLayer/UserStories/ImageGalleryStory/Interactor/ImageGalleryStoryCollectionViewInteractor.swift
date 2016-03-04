//
//  ImageGalleryStoryCollectionViewInteractor.swift
//  QBRTCDemo
//
//  Created by Anton Sokolchenko on 3/3/16.
//  Copyright © 2016 anton. All rights reserved.
//

import Foundation

let imageGalleryStoryCollectionViewCellIdentifier = "imageGalleryStoryCollectionViewCellIdentifier"

class ImageGalleryStoryCollectionViewInteractor : NSObject, UICollectionViewDataSource, ImageGalleryStoryCollectionViewInteractorInput, ImageGalleryStoryInteractorImagesOutput {
	
	var images: [UIImage] = []
	weak var output: ImageGalleryStoryCollectionViewInteractorOutput!
	
	func addImage(image: UIImage) {
		self.images.append(image)
		
		self.output.didUpdateImages()
	}
	
	func imageAt(index: Int) -> UIImage? {
		if images.count < index {
			return self.images[index]
		}
		return nil;
	}
	
	func imagesCount() -> UInt {
		return UInt(images.count)
	}
	
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return images.count
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier(imageGalleryStoryCollectionViewCellIdentifier, forIndexPath: indexPath) as! ImageGalleryStoryCollectionViewCell
		
		cell.imageView?.image = self.images[indexPath.row]
		
		return cell
		
	}
	
	
	// ImageGalleryStoryInteractorImagesOutput
	
	func didReceiveImage(image: UIImage) {
		self.addImage(image)
	}
}