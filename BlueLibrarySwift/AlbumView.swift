//
//  AlbumView.swift
//  BlueLibrarySwift
//
//  Created by Đinh Văn Nhật on 2014/12/24.
//  Copyright (c) 2014年 Raywenderlich. All rights reserved.
//

import UIKit

class AlbumView: UIView {
    private let coverImage: UIImageView!
    private let indicator: UIActivityIndicatorView!

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(frame: CGRect, albumCover: String) {
        super.init(frame: frame)
        backgroundColor = UIColor.blackColor()
        coverImage = UIImageView(frame: CGRectMake(5, 5, frame.size.width - 10, frame.size.height - 10))
        addSubview(coverImage)
        
        coverImage.addObserver(self, forKeyPath: "image", options: nil, context: nil)
        
        indicator = UIActivityIndicatorView()
        indicator.center = center
        indicator.activityIndicatorViewStyle = .WhiteLarge
        indicator.startAnimating()
        addSubview(indicator)
        
        NSNotificationCenter.defaultCenter().postNotificationName("BLDownloadImageNotification", object: self, userInfo: ["imageView":coverImage, "coverUrl" : albumCover])
        
    }
    
    deinit {
        coverImage.removeObserver(self, forKeyPath: "image")
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if keyPath == "image" {
            indicator.stopAnimating()
        }
    }
    
    func highlightAlbum(#didHighlightView: Bool) {
        if didHighlightView == true {
            backgroundColor = UIColor.whiteColor()
        } else {
            backgroundColor = UIColor.blackColor()
        }
    }
}
