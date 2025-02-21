//
//  MainViewController.swift
//  DeepSeek
//
//  Created by GIKI
//

import UIKit

final class MainViewController: UIViewController {
    
    // MARK: - UI Components
    private lazy var welcomeLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome to DeepSeek"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "DeepSeek"
        
        view.addSubview(welcomeLabel)
        NSLayoutConstraint.activate([
            welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            welcomeLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

// MARK: - Constants
extension MainViewController {
    private enum Constants {
        static let padding: CGFloat = 16.0
    }
} 