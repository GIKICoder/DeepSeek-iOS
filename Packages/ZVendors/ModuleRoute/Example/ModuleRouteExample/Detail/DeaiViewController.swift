//
//  DeaiViewController.swift
//  ModuleRouteExample
//
//  Created by GIKI on 2025/2/15.
//

import UIKit

// MARK: - Detail View Controller
class DetailViewController: UIViewController {
    var item: ItemModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }
    
    private func setupUI() {
        let label = UILabel()
        label.text = item?.title
        label.textAlignment = .center
        label.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        label.center = view.center
        view.addSubview(label)
    }
}

