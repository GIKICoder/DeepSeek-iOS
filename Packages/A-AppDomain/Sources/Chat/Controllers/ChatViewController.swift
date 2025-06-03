//
//  ChatViewController.swift
//  AppDomain
//
//  Created by GIKI on 2025/2/10.
//

import UIKit
import IGListKit
import IGListSwiftKit
import AppComponents
import AppFoundation
import AppInfra
import MagazineLayout
import Combine
import AppRefreshView
import AppServices

public class ChatViewController: AppViewController {
    
    // MARK: - Public Properties
    
    // MARK: - UI Components
    let chatInputToolView = ChatInputToolView()
    var collectionView: UICollectionView! = nil
    var chatLayout: MagazineLayout! = nil
    
    lazy var adapter: ListAdapter = { return ListAdapter(updater: ListAdapterUpdater(), viewController: self) }()
    
    var listContext: ChatContext!
    
    public private(set) var dataCenter: ChatDataCenter
    public private(set) var refreshHeader: RefreshView?
    
    lazy var editedToolbar = ChatEditedToolbar()
    
    var animator: ManualAnimator?
    
    // MARK: - Private Properties
    var cancellables = Set<AnyCancellable>()
    var currentUploadID: UUID?
    
    // MARK: - Initialization
    
    deinit {
        
    }
    
    public init(entrance: ChatEntrance) {
        self.dataCenter = ChatDataCenter(entrance: entrance)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupContext()
        setupUI()
        setupToolViews()
        addHandlers()
        initializeDatas()
        setupBinding()
    }
    
    // MARK: - Setup
    
    private func setupContext() {
        listContext = ChatContext(adapter: adapter,controller: self,dataCenter: dataCenter)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        setupCollectionView()
        setupEmptyView()
        setupeditedToolbar()
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: contentFrame, collectionViewLayout: createLayout())
        collectionView.keyboardDismissMode = .onDrag
        view.addSubview(collectionView)
        collectionView.panGestureRecognizer.addTarget(self, action: #selector(panCollectionView))
        refreshHeader = collectionView.header.setAutoControl(height: 44)
        refreshHeader?.addTarget(self, action: #selector(headerRefresh), for: .valueChanged)
        adapter.dataSource = self
        adapter.collectionView = self.collectionView
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(panCollectionView))
        collectionView.addGestureRecognizer(tap)
    }
    
    private func addHandlers() {
        let handler = DefaultMessageHandler()
        handler.dataCenter = dataCenter
        handler.controller = self
        listContext.handlerChain.append(handler)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = MagazineLayout(flipsHorizontallyInOppositeLayoutDirection: false, verticalLayoutDirection: .bottomToTop)
        layout.delegateMagazineLayout = self
        chatLayout = layout
        return layout
    }
    
    private func setupEmptyView() {
        
    }
 
    private func setupeditedToolbar() {
        view.addSubview(editedToolbar)
        editedToolbar.isHidden = true
        editedToolbar.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(view.snp.bottom)
            make.height.equalTo(76+AppF.screenBottomSafeAreaHeight)
        }
        editedToolbar.selectAll = { [weak self] selected in
            guard let self else { return }
            if selected {
                listContext.editNotifier.selectAll(items: dataCenter.sections)
            } else {
                listContext.editNotifier.deselectAll()
            }
        }
        editedToolbar.shareCreateAction = { [weak self] in
            guard let self else { return }
            AppHUD.loading("笔记转录中...")
            self.createNote(with: self.selectMessages)
            self.hiddenEditAction()
        }
    }
    
    public var selectMessages: [ChatMessage] {
        let selectedSet = listContext.editNotifier.selectedItems
        return dataCenter.messages.filter { message in
            selectedSet.contains(where: { $0.message.messageId == message.messageId })
        }
    }
    
    fileprivate var isUserInitiatedScrolling: Bool {
        collectionView.isDragging || collectionView.isDecelerating
    }
    
}


// MARK: - Action Method

extension ChatViewController {
    
    func toggleNoteChat() {
        showEditAction()
    }
    
    func showEditAction() {
        self.view.endEditing(true)
        showBottomShareView()
        listContext?.editNotifier.setIsEditing(true, duration: .animated(duration: 0.25))
        let sections = dataCenter.sections
        listContext?.editNotifier.selectAll(items: sections)
    }
    
    func hiddenEditAction() {
        hideBottomShareView()
        listContext?.editNotifier.setIsEditing(false, duration: .animated(duration: 0.25))
    }
    
    @objc func headerRefresh() {
        logUI("headerRefresh xxxxxx")
        loadMoreDatas()
    }
    
    @objc func panCollectionView() {
        view.endEditing(true)
    }
    
    
    private func showBottomShareView() {
        editedToolbar.isHidden = false
        chatInputToolView.isHidden = true
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
            self.editedToolbar.snp.remakeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.bottom.equalTo(self.view.snp.bottom)
                make.height.equalTo(76+AppF.screenBottomSafeAreaHeight)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    private func hideBottomShareView() {
        chatInputToolView.isHidden = false
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
            self.editedToolbar.snp.remakeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.top.equalTo(self.view.snp.bottom)
                make.height.equalTo(76+AppF.screenBottomSafeAreaHeight)
            }
            self.view.layoutIfNeeded()
        } completion: { finish in
            self.editedToolbar.isHidden = true
        }
    }
    
}

