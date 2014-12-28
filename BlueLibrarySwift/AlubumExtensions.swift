//
//  AlubumExtensions.swift
//  BlueLibrarySwift
//
//  Created by Đinh Văn Nhật on 2014/12/28.
//  Copyright (c) 2014年 Dinh Van Nhat. All rights reserved.
//

import Foundation

extension Album {
    func ae_tableRepresentation() -> (titles:[String], values:[String]) {
        return (["Artist", "Album", "Genre", "Year"], [artist, title, genre, year])
    }
}
