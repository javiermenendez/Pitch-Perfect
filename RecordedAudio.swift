//
//  File.swift
//  Pitch Perfect
//
//  Created by Javier Menendez on 8/3/15.
//  Copyright (c) 2015 Menulio Baxter Inc. All rights reserved.
//

import Foundation

class RecordedAudio: NSObject{
    var filePathUrl: NSURL!
    var title: String!
    
    init(filePathUrl: NSURL!, title: String!){
        self.filePathUrl = filePathUrl
        self.title = title
    }
}