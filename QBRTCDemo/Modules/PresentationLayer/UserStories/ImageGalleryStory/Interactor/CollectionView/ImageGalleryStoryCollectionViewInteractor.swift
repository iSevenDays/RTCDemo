//
//  ImageGalleryStoryCollectionViewInteractor.swift
//  RTCDemo
//
//  Created by Anton Sokolchenko on 3/3/16.
//  Copyright © 2016 anton. All rights reserved.
//

import Foundation

let imageGalleryStoryCollectionViewCellIdentifier = "imageGalleryStoryCollectionViewCellIdentifier"

class ImageGalleryStoryCollectionViewInteractor : NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ImageGalleryStoryCollectionViewInteractorInput, ImageGalleryStoryInteractorImagesOutput {
	
	var images: [UIImage] = []
	weak var output: ImageGalleryStoryCollectionViewInteractorOutput!
	
	// MARK: ImageGalleryStoryCollectionViewInteractorInput
	func addImage(image: UIImage) {
		images.append(image)
		
		output.didUpdateImages()
	}
	
	func imageAt(index: Int) -> UIImage? {
		if images.count > index {
			return images[index]
		}
		return nil;
	}
	
	func imagesCount() -> Int {
		return images.count
	}
	
	// MARK: UICollectionView
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return imagesCount()
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier(imageGalleryStoryCollectionViewCellIdentifier, forIndexPath: indexPath) as! ImageGalleryStoryCollectionViewCell

		cell.imageView?.image = images[indexPath.row]
		
		return cell
		
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
		return CGSizeMake(100, 100)
	}
	
	
	// MARK: ImageGalleryStoryInteractorImagesOutput
	
	func didReceiveImage(image: UIImage) {
		addImage(image)
	}
}
