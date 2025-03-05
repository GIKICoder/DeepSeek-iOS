//
//  HistoryViewController.swift
//  AppDomain
//
//  Created by GIKI on 2025/1/22.
//

import UIKit
import AppInfra
import AppServices
import AppFoundation
import IQListKit

public class HistoryViewController: AppViewController {
    
    enum Section {
        case main
    }
    
    
    let provider = NetworkProvider<ChatApi>()
    var tableView: UITableView!
    private lazy var list = IQList(listView: tableView, delegateDataSource: self)

    private var page:Int = 1
    private var pageSize:Int = 200
    
    private var dataSource:[ChatChannelHistory] = []
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        list.removeDuplicates = true
//        list.noItemStateView = customNoItemsView
        list.noItemStateView?.tintColor = UIColor.black
        list.noItemImage = UIImage(named: "gen_feed_empty")
        list.noItemMessage = "No content yet~"
        list.noItemAction(title: "Reload", target: self, action: #selector(refreshData))
        loadDatas()
    }

}

extension HistoryViewController {
    
     func loadDatas() {
        
        list.isLoading = true
        let historyApi = ChatApi.channelHistory(page: page, pageSize: pageSize)
        provider.request(historyApi, type: [ChatChannelHistory].self) {[weak self] result in
            guard let self else { return }
            switch result {
            case .success(let success):
                logUI("\(success)")
                dataSource = success
                reloadDataSource(false)
            case .failure(let failure):
                logUI("\(failure)")
                reloadDataSource(false)
            }
        }
    }
    
    @objc func refreshData() {
        loadDatas()
    }
}

extension HistoryViewController {

    func setupTableView() {

        tableView = UITableView(frame: contentFrame, style: .plain)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(hex: "#F4F4F4")
        view.addSubview(tableView)
    }

    func reloadDataSource(_ animation:Bool = true) {
        list.reloadData ({[dataSource = self.dataSource] builder in
            let section = IQSection(identifier: Section.main)
            builder.append([section])
            builder.append(HistoryTableViewCell.self, models: dataSource)
        },animatingDifferences: animation)
    }

}



extension HistoryViewController: IQListViewDelegateDataSource {
 
    public func listView(_ listView: IQListView, modifyCell cell: some IQModelableCell, at indexPath: IndexPath) {
       
    }

    public func listView(_ listView: IQListView, didSelect item: IQItem, at indexPath: IndexPath) {
        guard let model = item.model as? ChatChannelHistory else {
            return
        }
//        let entrance = MessageEntrance()
//        entrance.channel = model.channel
//        let chat = MessageViewController(entrance: entrance)
//        self.navigationController?.pushViewController(chat, animated: true)
    }
    
    public func listView(_ listView: IQListView, canEdit item: IQItem, at indexPath: IndexPath) -> Bool? {
        return true
    }
    
    public func tableView(_ tableView: UITableView,
                            shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
        return true
    }
}
