//
//  BaseHeaderView.swift
//  HeaderFooterRefreshView
//
//  Created by Vadim Zhydenko on 05.03.2020.
//

import UIKit

@MainActor
public class BaseHeaderView: BaseIndicatorRefreshView {
    
    override func beginRefreshingAnimation(_ scrollView: UIScrollView) {
        scrollView.contentOffset.y = -height - scrollView.contentInsetTop
        scrollView.contentInset.top += height
    }
    
    override func endRefreshingAnimation(_ scrollView: UIScrollView) {
        scrollView.contentInset.top -= height
    }
    
    override func estimatedFrame(in scrollView: UIScrollView) -> CGRect {
        CGRect(x: 0, y: -height, width: scrollView.bounds.width, height: height)
    }
    
}
