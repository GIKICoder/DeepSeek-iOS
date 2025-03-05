//
//  MessageSectionController.swift
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

final class MessageSectionController: ListSectionController ,ListSupplementaryViewSource {
    
    private var chatSection: ChatSection?
    public var listContext: ChatContext?
    
    override init() {
        super.init()
        supplementaryViewSource = self
    }
    
    // MARK: - Override
    
    override func numberOfItems() -> Int {
        return chatSection?.messageLayouts.count ?? 0
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let chatSection, let layout = chatSection.messageLayouts[safe: index] else {
            fatalError()
        }
        guard let cell = collectionContext?.dequeueReusableCell(of: layout.cellType, for: self, at: index) else { fatalError() }
        
        if let modifiable = cell as? ChatCellModifiable {
            modifiable.configureContext(listContext)
            modifiable.configure(section: chatSection, layout: layout, index: index)
        }
    
        if let editCell = cell as? EditNotifierDelegate {
            listContext?.editNotifier.add(delegate: editCell)
            listContext?.editNotifier.setIsEditing(listContext?.editNotifier.isEditing ?? false, duration: .notAnimated)
        }
        return cell
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: AppF.screenWidth, height: 0.01)
    }
    
    override func didUpdate(to object: Any) {
        guard let object = object as? ChatSection else { return }
        self.chatSection = object
    }
    
    // MARK: - ListSupplementaryViewSource
    func supportedElementKinds() -> [String] {
        return [MagazineLayout.SupplementaryViewKind.sectionBackground]
    }
    
    func viewForSupplementaryElement(ofKind elementKind: String, at index: Int) -> UICollectionReusableView {
        if elementKind == MagazineLayout.SupplementaryViewKind.sectionBackground {
            if let background = collectionContext.dequeueReusableSupplementaryView(ofKind: MagazineLayout.SupplementaryViewKind.sectionBackground, for: self, class: ChatBackgroundDecorationView.self, at: index) as? ChatBackgroundDecorationView {
                background.model = chatSection
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

