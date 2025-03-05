//
//  JXPhotoBrowserImageView.swift
//  JXPhotoBrowser
//
//  Created by 梁大红 on 2021/2/19.
//  Copyright © 2021 JiongXing. All rights reserved.
//

import UIKit

open class JXPhotoBrowserImageView: UIImageView {
    public var imageDidChangedHandler: (() -> Void)?

    override public var image: UIImage? {
        didSet {
            imageDidChangedHandler?()
        }
    }
}
