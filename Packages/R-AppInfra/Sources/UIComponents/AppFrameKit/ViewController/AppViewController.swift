import UIKit
import AppFoundation

open class AppViewController: BaseViewController {
    
    // MARK: - Properties
    
    public var contentFrame: CGRect {
        var frame = view.bounds
        // 检查navigationBar是否存在、是否已添加到视图中且不是隐藏状态
        if navigationBar.superview != nil && !navigationBar.isHidden {
            // 将contentFrame的起始位置调整到navigationBar的底部
            let navigationBarBottom = navigationBar.frame.maxY
            frame.origin.y = navigationBarBottom
            frame.size.height -= navigationBarBottom
        }
        
        return frame
    }
    
    public lazy var navigationBar: GNavigationBar = {
        let bar = GNavigationBar()
        bar.setBackgroundColor(.white)
        return bar
    }()
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override open func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    // MARK: - Public Method
    
    public func addNavigationbar(_ title:String? = nil) {
        if view.subviews.contains(navigationBar) {
            view.bringSubviewToFront(navigationBar)
            return
        }
        navigationBar.centerLabel.textColor = .black
        view.addSubview(navigationBar)
        if let title {
            navigationBar.centerLabel.text = title
        }
    }
}

extension AppViewController {
    
    @objc open func appCancel() {
        if let navigationController = self.navigationController, navigationController.viewControllers.count > 1 {
            navigationController.popViewController(animated: true)
        } else if self.presentingViewController != nil {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

