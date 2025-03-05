//
//  MessageBindingSectionController.swift
//  AppDomain
//
//  Created by GIKI on 2025/2/11.
//

import UIKit
import IGListKit
import IGListDiffKit
import IGListSwiftKit
import AppFoundation
import AppInfra
import MagazineLayout

final class MessageBindingSectionController: ListBindingSectionController<ChatSection>, ListBindingSectionControllerDataSource,ListSupplementaryViewSource {
    
    public var listContext: ChatContext?
    
    override init() {
        super.init()
        dataSource = self
        supplementaryViewSource = self
    }
    
    // MARK: - Override
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let chatSection = object, let viewModel = viewModels[safe: index] as? ChatMessageLayout else {
            fatalError()
        }
        guard let cell = collectionContext?.dequeueReusableCell(of: viewModel.cellType, for: self, at: index) else { fatalError() }
        
        if let modifiable = cell as? ChatCellModifiable {
            modifiable.configureContext(listContext)
            modifiable.configure(section: chatSection, layout: viewModel, index: index)
        }
    
        if let editCell = cell as? EditNotifierDelegate {
            listContext?.editNotifier.add(delegate: editCell)
            listContext?.editNotifier.setIsEditing(listContext?.editNotifier.isEditing ?? false, duration: .notAnimated)
        }
        return cell
    }
    
    // MARK: - DataSource
    
    func sectionController(_ sectionController: ListBindingSectionController<any ListDiffable>, viewModelsFor object: Any) -> [any ListDiffable] {
        guard let object = object as? ChatSection else { fatalError() }
        return object.messageLayouts
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<any ListDiffable>, cellForViewModel viewModel: Any, at index: Int) -> any UICollectionViewCell & ListBindable {
        
        return UICollectionViewCell()
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<any ListDiffable>, sizeForViewModel viewModel: Any, at index: Int) -> CGSize {
        CGSize(width: AppF.screenWidth, height: 0.01)
    }
    
    // MARK: - ListSupplementaryViewSource
    func supportedElementKinds() -> [String] {
        return [MagazineLayout.SupplementaryViewKind.sectionBackground]
    }
    
    func viewForSupplementaryElement(ofKind elementKind: String, at index: Int) -> UICollectionReusableView {
        if elementKind == MagazineLayout.SupplementaryViewKind.sectionBackground {
            if let background = collectionContext.dequeueReusableSupplementaryView(ofKind: MagazineLayout.SupplementaryViewKind.sectionBackground, for: self, class: ChatBackgroundDecorationView.self, at: index) as? ChatBackgroundDecorationView {
                background.model = object
                listContext?.editNotifier.add(delegate: background)
                listContext?.editNotifier.setIsEditing(listContext?.editNotifier.isEditing ?? false, duration: .notAnimated)
                return background
            }
        }
        return UICollectionReusableView()
    }
    
    func sizeForSupplementaryView(ofKind elementKind: String, at index: Int) -> CGSize {
        CGSize(width: 0, height: 0)
    }
}

extension UICollectionViewCell : @retroactive ListBindable {
    
    public func bindViewModel(_ viewModel: Any) {
        
    }
}
