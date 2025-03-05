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
 
    
    fileprivate var isUserInitiatedScrolling: Bool {
        collectionView.isDragging || collectionView.isDecelerating
    }
    
}

// MARK: - Action Method

extension ChatViewController {

    
    @objc func headerRefresh() {
        logUI("headerRefresh xxxxxx")
        loadMoreDatas()
    }

    @objc func panCollectionView() {
        view.endEditing(true)
    }
    
}

