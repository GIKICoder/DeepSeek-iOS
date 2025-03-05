//
//  ViewController.swift
//  ModuleRouteExample
//
//  Created by GIKI on 2025/2/14.
//

import UIKit
import ModuleRoute

class ViewController: UIViewController {
    
    @MRInject var navigator: MRNavigator
//    @Inject(DetailInterface) var detail: DetailInterface
    
    
    // MARK: - Properties
    private var collectionView: UICollectionView!
    private let cellIdentifier = "Cell"
    
    // 可配置的数据源
    private var items: [ItemModel] = [
        ItemModel(title: "Item 1", color: .blue),
        ItemModel(title: "Item 2", color: .green),
        ItemModel(title: "Item 3", color: .orange),
        ItemModel(title: "Item 4", color: .purple)
    ]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    // MARK: - Setup
    private func setupCollectionView() {
        // 创建布局
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (view.frame.width - 40) / 2, height: 100)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        // 初始化 CollectionView
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // 注册 cell
        collectionView.register(CustomCell.self, forCellWithReuseIdentifier: cellIdentifier)
        
        // 设置代理
        collectionView.delegate = self
        collectionView.dataSource = self
        
        view.addSubview(collectionView)
    
    }
}

// MARK: - UICollectionViewDataSource
extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! CustomCell
        let item = items[indexPath.item]
        cell.configure(with: item)
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.item]
        if indexPath.item == 1 {
            @MRInject var detail: DetailInterface
            let result = detail.handle(route: DetailRoute())
            switch result {
            case .navigator(let vc):
                self.navigationController?.pushViewController(vc, animated: true)
            default: break
                
            }
            print(result)
        } else {
            navigator.navigate(to: ChatRoute(), from: self)
        }

    }
}

// MARK: - Custom Cell
class CustomCell: UICollectionViewCell {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(titleLabel)
        titleLabel.frame = contentView.bounds
        titleLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    func configure(with item: ItemModel) {
        titleLabel.text = item.title
        contentView.backgroundColor = item.color
        layer.cornerRadius = 8
        clipsToBounds = true
    }
}

// MARK: - Model
struct ItemModel {
    let title: String
    let color: UIColor
}

