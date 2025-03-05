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

    lazy var shareBottomView = ShareBottomToolView()
    
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
        setupShareBottomView()
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: contentFrame, collectionViewLayout: createLayout())
        collectionView.keyboardDismissMode = .onDrag
        view.addSubview(collectionView)
        refreshHeader = collectionView.header.setAutoControl(height: 44)
        refreshHeader?.addTarget(self, action: #selector(headerRefresh), for: .valueChanged)
        adapter.dataSource = self
        adapter.collectionView = self.collectionView
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
    
    private func setupShareBottomView() {
        view.addSubview(shareBottomView)
        shareBottomView.isHidden = true
        shareBottomView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(view.snp.bottom)
            make.height.equalTo(76+AppF.screenBottomSafeAreaHeight)
        }
    }
    
    fileprivate var isUserInitiatedScrolling: Bool {
        collectionView.isDragging || collectionView.isDecelerating
    }
    
}

// MARK: - Action Method

extension ChatViewController {
    
    @objc func didTapShareAction() {
        self.view.endEditing(true)
        showBottomShareView()
        listContext?.editNotifier.setIsEditing(true, duration: .animated(duration: 0.25))
        let sections = dataCenter.sections
        listContext?.editNotifier.selectAll(items: sections)
    }
    
    @objc func didTapCancelShareAction() {
        hideBottomShareView()
        listContext?.editNotifier.setIsEditing(false, duration: .animated(duration: 0.25))
    }
    
    @objc func headerRefresh() {
        logUI("headerRefresh xxxxxx")
        loadMoreDatas()
    }
    
    private func showBottomShareView() {
        shareBottomView.isHidden = false
        chatInputToolView.isHidden = true
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
            self.shareBottomView.snp.remakeConstraints { make in
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
            self.shareBottomView.snp.remakeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.top.equalTo(self.view.snp.bottom)
                make.height.equalTo(76+AppF.screenBottomSafeAreaHeight)
            }
            self.view.layoutIfNeeded()
        } completion: { finish in
            self.shareBottomView.isHidden = true
        }
    }
    
}

