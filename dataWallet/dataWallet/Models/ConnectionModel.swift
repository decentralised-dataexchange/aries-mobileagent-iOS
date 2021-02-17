//
//  ConnectionModel.swift
//  AriesMobileAgent-iOS
//
//  Created by Mohamed Rebin on 21/11/20.
//

import Foundation

struct ConnectionModel {
    var name:String?
    var image:String?
    var location: String?
    
    init(name: String, image: String, location: String) {
        self.name = name
        self.image = image
        self.location = location
    }
}
