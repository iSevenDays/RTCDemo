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
	func addImage(_ image: UIImage) {
		images.append(image)
		
		output.didUpdateImages()
	}
	
	func imageAt(_ index: Int) -> UIImage? {
		if images.count > index {
			return images[index]
		}
		return nil;
	}
	
	func imagesCount() -> Int {
		return images.count
	}
	
	// MARK: UICollectionView
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return imagesCount()
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: imageGalleryStoryCollectionViewCellIdentifier, for: indexPath as IndexPath) as! ImageGalleryStoryCollectionViewCell

		cell.imageView?.image = images[indexPath.row]
		
		return cell
		
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: 100, height: 100)
	}
	
	
	// MARK: ImageGalleryStoryInteractorImagesOutput
	
	func didReceiveImage(_ image: UIImage) {
		addImage(image)
	}
}
