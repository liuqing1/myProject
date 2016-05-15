//
//  PageControl.swift
//  fiti
//
//  Created by Daniel Contreras on 4/6/16.
//  Copyright © 2016 ReignDesign. All rights reserved.
//

import UIKit

class PageControl: UIPageControl {
    
    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func drawRect(rect: CGRect) {
     // Drawing code
     }
     */
    
    var activeImage: UIImage!
    var inactiveImage: UIImage!
    override var currentPage: Int {
        //willSet {
        didSet { //so updates will take place after page changed
            self.updateDots()
        }
    }
    
    convenience init(activeImage: UIImage, inactiveImage: UIImage) {
        self.init()
        
        self.activeImage = activeImage
        self.inactiveImage = inactiveImage
        
        self.pageIndicatorTintColor = UIColor.clearColor()
        self.currentPageIndicatorTintColor = UIColor.clearColor()
    }
    
    func updateDots() {
        for var i = 0; i < subviews.count; i++ {
            let view: UIView = subviews[i]
            if view.subviews.count == 0 {
                self.addImageViewOnDotView(view, imageSize: activeImage.size)
            }
            let imageView: UIImageView = view.subviews.first as! UIImageView
            imageView.image = self.currentPage == i ? activeImage : inactiveImage
        }
    }
    
    // MARK: - Private
    
    func addImageViewOnDotView(view: UIView, imageSize: CGSize) {
        var frame = view.frame
        frame.origin = CGPointZero
        frame.size = imageSize
        
        let imageView = UIImageView(frame: frame)
        imageView.contentMode = UIViewContentMode.Center
        view.addSubview(imageView)
    }
    
}
