import UIKit

public enum UIScrollViewAutoDirection: Int {
    case vertical
    case horizontal
}

public extension UIScrollView {
    private struct AssociatedKeys {
        static var scrollPointsPerSecond = UnsafeRawPointer(bitPattern: 1)!
        static var autoScrollDisplayLink = UnsafeRawPointer(bitPattern: 2)!
        static var repeatCount = UnsafeRawPointer(bitPattern: 3)!
        static var totalRepeatCount = UnsafeRawPointer(bitPattern: 4)!
        static var autoDirection = UnsafeRawPointer(bitPattern: 5)!
    }
    
    private static let defaultScrollPointsPerSecond: CGFloat = 15.0
    
    var scrollPointsPerSecond: CGFloat {
        get {
            return (objc_getAssociatedObject(self, AssociatedKeys.scrollPointsPerSecond) as? CGFloat) ?? UIScrollView.defaultScrollPointsPerSecond
        }
        set {
            objc_setAssociatedObject(self, AssociatedKeys.scrollPointsPerSecond, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var isScrolling: Bool {
        return autoScrollDisplayLink != nil
    }
    
    var totalRepeatCount: Int {
        get {
            return (objc_getAssociatedObject(self, AssociatedKeys.totalRepeatCount) as? Int) ?? 1
        }
        set {
            let value = newValue == Int.max ? 0 : newValue
            objc_setAssociatedObject(self, AssociatedKeys.totalRepeatCount, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var autoDirection: UIScrollViewAutoDirection {
        get {
            return (objc_getAssociatedObject(self, AssociatedKeys.autoDirection) as? UIScrollViewAutoDirection) ?? .vertical
        }
        set {
            objc_setAssociatedObject(self, AssociatedKeys.autoDirection, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var currentRepeatCount: Int {
        get {
            return (objc_getAssociatedObject(self, AssociatedKeys.repeatCount) as? Int) ?? 1
        }
        set {
            objc_setAssociatedObject(self, AssociatedKeys.repeatCount, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var autoScrollDisplayLink: CADisplayLink? {
        get {
            return objc_getAssociatedObject(self, AssociatedKeys.autoScrollDisplayLink) as? CADisplayLink
        }
        set {
            objc_setAssociatedObject(self, AssociatedKeys.autoScrollDisplayLink, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func startScrolling() {
        stopScrolling()
        currentRepeatCount = 1
        autoScrollDisplayLink = CADisplayLink(target: self, selector: #selector(displayTick))
        autoScrollDisplayLink?.add(to: .main, forMode: .default)
    }
    
    func stopScrolling() {
        autoScrollDisplayLink?.invalidate()
        autoScrollDisplayLink = nil
    }
    
    @objc private func displayTick(_ displayLink: CADisplayLink) {
        guard window != nil else {
            stopScrolling()
            return
        }
        
        switch autoDirection {
        case .vertical:
            autoDirectionVertical(displayLink)
        case .horizontal:
            autoDirectionHorizontal(displayLink)
        }
    }
    
    private func autoDirectionHorizontal(_ displayLink: CADisplayLink) {
        let animationDuration = displayLink.duration
        let pointChange = scrollPointsPerSecond * CGFloat(animationDuration)
        let newOffset = CGPoint(x: contentOffset.x + pointChange, y: contentOffset.y)
        
        let maximumXOffset = contentSize.width - bounds.size.width
        if newOffset.x > maximumXOffset {
            if totalRepeatCount == 0 || currentRepeatCount < totalRepeatCount {
                setContentOffset(.zero, animated: false)
                currentRepeatCount += 1
            } else {
                stopScrolling()
            }
        } else {
            contentOffset = newOffset
        }
    }
    
    private func autoDirectionVertical(_ displayLink: CADisplayLink) {
        let animationDuration = displayLink.duration
        let pointChange = scrollPointsPerSecond * CGFloat(animationDuration)
        let newOffset = CGPoint(x: contentOffset.x, y: contentOffset.y + pointChange)
        
        let maximumYOffset = contentSize.height - bounds.size.height
        if newOffset.y > maximumYOffset {
            if totalRepeatCount == 0 || currentRepeatCount < totalRepeatCount {
                setContentOffset(.zero, animated: false)
                currentRepeatCount += 1
            } else {
                stopScrolling()
            }
        } else {
            contentOffset = newOffset
        }
    }
}
