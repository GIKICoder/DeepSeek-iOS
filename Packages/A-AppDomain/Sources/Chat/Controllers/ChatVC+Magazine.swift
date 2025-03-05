//
//  File.swift
//  AppDomain
//
//  Created by GIKI on 2025/2/10.
//

import UIKit
import MagazineLayout
import AppFoundation
import AppInfra

// MARK: UICollectionViewDelegateMagazineLayout

extension ChatViewController: UICollectionViewDelegateMagazineLayout {
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeModeForItemAt indexPath: IndexPath)
    -> MagazineLayoutItemSizeMode
    {
        let layout = MagazineLayoutItemSizeMode(widthMode: .fullWidth(respectsHorizontalInsets: true), heightMode: .static(height: 0))
        let sections = dataCenter.sections
        guard let section = sections[safe: indexPath.section] else {
            logUI("Empty layout")
            return layout
        }
        guard let messageLayout = section.messageLayouts[safe: indexPath.item] else {
            logUI("Empty layout 2222")
            return layout
        }
        return MagazineLayoutItemSizeMode(widthMode: .fullWidth(respectsHorizontalInsets: true), heightMode: .static(height: messageLayout.itemSize.height))
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        visibilityModeForHeaderInSectionAtIndex index: Int)
    -> MagazineLayoutHeaderVisibilityMode
    {
        return .hidden
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        visibilityModeForFooterInSectionAtIndex index: Int)
    -> MagazineLayoutFooterVisibilityMode
    {
        return .hidden
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        visibilityModeForBackgroundInSectionAtIndex index: Int)
    -> MagazineLayoutBackgroundVisibilityMode
    {
        let sections = dataCenter.sections
        guard let section = sections[safe: index] else { return .hidden}
        
        return section.background.visibilityMode ? MagazineLayoutBackgroundVisibilityMode.visible : MagazineLayoutBackgroundVisibilityMode.hidden
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        horizontalSpacingForItemsInSectionAtIndex index: Int)
    -> CGFloat
    {
        return 0
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        verticalSpacingForElementsInSectionAtIndex index: Int)
    -> CGFloat
    {
        return 0
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetsForSectionAtIndex index: Int)
    -> UIEdgeInsets
    {
        return UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetsForItemsInSectionAtIndex index: Int)
    -> UIEdgeInsets
    {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        finalLayoutAttributesForRemovedItemAt indexPath: IndexPath,
        byModifying finalLayoutAttributes: UICollectionViewLayoutAttributes)
    {
        // Fade and drop out
        finalLayoutAttributes.alpha = 0
        finalLayoutAttributes.transform = .identity
            //.init(scaleX: 0.2, y: 0.2)
    }
    
}
