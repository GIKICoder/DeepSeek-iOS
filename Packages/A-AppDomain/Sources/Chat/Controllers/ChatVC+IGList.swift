//
//  File.swift
//  AppDomain
//
//  Created by GIKI on 2025/2/10.
//

import Foundation
import AppFoundation
import AppInfra
import IGListKit
import IGListDiffKit
import IGListSwiftKit

extension ChatViewController: ListAdapterDataSource {
    
    public func objects(for listAdapter: ListAdapter) -> [any ListDiffable] {
        return dataCenter.sections
    }
    
    public func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        let sectionController = MessageSectionController()
        sectionController.listContext = listContext
        return sectionController
    }
    
    public func emptyView(for listAdapter: ListAdapter) -> UIView? {
        nil
    }
    
    
}
