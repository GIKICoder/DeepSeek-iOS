import UIKit

public enum AlertPriority: Int {
    case low = 0
    case medium = 1
    case high = 2
}

struct AlertRequest {
    let priority: AlertPriority
    let allowConcurrent: Bool
    let block: () -> AlertBaseView
}

// 使 AlertRequest 遵循 Equatable 以便在队列中查找和移除
extension AlertRequest: Equatable {
    static func == (lhs: AlertRequest, rhs: AlertRequest) -> Bool {
        return lhs.priority == rhs.priority &&
               lhs.allowConcurrent == rhs.allowConcurrent &&
               lhs.block as AnyObject === rhs.block as AnyObject
    }
}

public class AlertViewManager {
    
    // Singleton instance
    public static let shared = AlertViewManager()
    
    // Serial queue to manage alert operations
    private let serialQueue = DispatchQueue(label: "com.yourapp.AlertViewManager")
    
    // Queues for different priorities
    private var highPriorityQueue: [AlertRequest] = []
    private var mediumPriorityQueue: [AlertRequest] = []
    private var lowPriorityQueue: [AlertRequest] = []
    
    // 当前正在显示的弹窗数量
    private var currentVisibleCount: Int = 0
    
    private init() {
        // 监听弹窗消失通知
        NotificationCenter.default.addObserver(self, selector: #selector(handleAlertDismissed(notification:)), name: .AlertViewDidDismiss, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /// 入队弹窗
    /// - Parameters:
    ///   - priority: 弹窗优先级
    ///   - allowConcurrent: 是否允许同时弹出
    ///   - block: 创建并展示弹窗的闭包
    public func enqueueAlert(priority: AlertPriority = .medium, allowConcurrent: Bool = false, block: @escaping () -> AlertBaseView) {
        let request = AlertRequest(priority: priority, allowConcurrent: allowConcurrent, block: block)
        
        serialQueue.async { [weak self] in
            guard let self = self else { return }
            switch priority {
            case .high:
                self.highPriorityQueue.append(request)
            case .medium:
                self.mediumPriorityQueue.append(request)
            case .low:
                self.lowPriorityQueue.append(request)
            }
            self.presentNextIfPossible()
        }
    }
    
    /// 尝试展示下一个弹窗
    private func presentNextIfPossible() {
        serialQueue.async { [weak self] in
            guard let self = self else { return }
            
            // 优先级顺序查找可展示的弹窗
            let queueTypes: [AlertPriority] = [.high, .medium, .low]
            
            for priority in queueTypes {
                var queue: [AlertRequest]
                switch priority {
                case .high:
                    queue = self.highPriorityQueue
                case .medium:
                    queue = self.mediumPriorityQueue
                case .low:
                    queue = self.lowPriorityQueue
                }
                
                for (index, request) in queue.enumerated() {
                    if self.canPresentNewAlert(allowConcurrent: request.allowConcurrent) {
                        // 从相应队列中移除请求
                        switch priority {
                        case .high:
                            self.highPriorityQueue.remove(at: index)
                        case .medium:
                            self.mediumPriorityQueue.remove(at: index)
                        case .low:
                            self.lowPriorityQueue.remove(at: index)
                        }
                        // 展示弹窗
                        self.present(alertRequest: request)
                        // 如果不允许并发，停止展示更多弹窗
                        if !request.allowConcurrent {
                            return
                        }
                    }
                }
            }
        }
    }
    
    /// 判断是否可以展示新的弹窗
    /// - Parameter allowConcurrent: 当前弹窗是否允许并发展示
    /// - Returns: 是否可以展示新的弹窗
    private func canPresentNewAlert(allowConcurrent: Bool) -> Bool {
        if allowConcurrent {
            return true
        } else {
            return currentVisibleCount == 0
        }
    }
    
    /// 展示弹窗
    /// - Parameter request: 弹窗请求
    private func present(alertRequest: AlertRequest) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let alert = alertRequest.block()
            self.serialQueue.async {
                self.currentVisibleCount += 1
            }
            alert.show()
        }
    }
    
    /// 处理弹窗消失通知
    /// - Parameter notification: 通知对象
    @objc private func handleAlertDismissed(notification: Notification) {
        guard notification.object is AlertBaseView else { return }
        serialQueue.async { [weak self] in
            guard let self = self else { return }
            self.currentVisibleCount -= 1
            self.presentNextIfPossible()
        }
    }
}

/*
```
func showLanguageSelectionAlert() {
     AlertViewManager.shared.enqueueAlert(priority: .high, allowConcurrent: false) {
         let alert = HomeSelectModelAlert()
         alert.currentModel = BMAuthManage.sharedInstance().languageMode
         alert.dataSource = BMAuthManage.sharedInstance().homeItem.languageModelListMoblie
         alert.onLanguageSelected = { [weak self] selectedLanguage in
             guard let self = self else { return }
             self.updateUI()
         }
         // 定义弹窗的展示方式
         alert.showWithTopVC()
         return alert
     }
 }

```
*/
