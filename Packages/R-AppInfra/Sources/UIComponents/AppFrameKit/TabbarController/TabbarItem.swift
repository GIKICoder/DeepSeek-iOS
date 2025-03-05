//
//  TabbarItem.swift
//  AppInfra
//
//  Created by GIKI on 2025/1/13.
//

import UIKit

public class TabBarItem: NSObject {
    var title: String
    var image: UIImage
    var selectedImage: UIImage
    var tag: Int
    
    public init(title: String, image: UIImage, selectedImage: UIImage, tag: Int) {
        self.title = title
        self.image = image
        self.selectedImage = selectedImage
        self.tag = tag
        super.init()
    }
}
