//
//  LibraryAPI.swift
//  BlueLibrarySwift
//
//  Created by Đinh Văn Nhật on 2014/12/24.
//  Copyright (c) 2014年 Dinh Van Nhat. All rights reserved.
//

import UIKit

class LibraryAPI: NSObject {
    private let persistencyManager: PersistencyManager
    private let httpClient: HTTPClient
    private let isOnline: Bool
    
    override init() {
        persistencyManager = PersistencyManager()
        httpClient = HTTPClient()
        isOnline = false
        
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "downloadImage:", name: "BLDownloadImageNotification", object: nil)
        
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    class var sharedInstance: LibraryAPI {
        struct Singleton {
            static let instance = LibraryAPI()
        }
        return Singleton.instance;
    }
    
    func getAlbums() -> [Album] {
        return persistencyManager.getAlbum()
    }
    
    func addAlbum(album: Album, index: Int) {
        persistencyManager.addAlbum(album, index: index)
        if isOnline {
            httpClient.postRequest("/api/addAlbum", body: album.description())
        }
    }
    
    func deleteAlbum(index: Int) {
        persistencyManager.deleteAlbumAtIndex(index)
        if isOnline {
            httpClient.postRequest("/api/deleteAlbum", body: "\(index)")
        }
    }
    
    func downloadImage(notification: NSNotification) {
        //1
        let userInfo = notification.userInfo as [String: AnyObject]
        var imageView = userInfo["imageView"] as UIImageView?
        let coverUrl = userInfo["coverUrl"] as NSString
        
        //2
        if let imageViewUnWrapped = imageView {
            imageViewUnWrapped.image = persistencyManager.getImage(coverUrl.lastPathComponent)
            if imageViewUnWrapped.image == nil {
                //3
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                    let downloadedImage = self.httpClient.downloadImage(coverUrl)
                    //4
                    dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                        imageViewUnWrapped.image = downloadedImage
                        self.persistencyManager.saveImage(downloadedImage, filename: coverUrl.lastPathComponent)
                    })
                })
            }
        }
    }
}
