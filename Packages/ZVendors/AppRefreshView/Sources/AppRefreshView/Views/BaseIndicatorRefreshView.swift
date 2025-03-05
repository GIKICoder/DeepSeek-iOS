
import UIKit

@available(iOS 13.0, *)
@MainActor
public class BaseIndicatorRefreshView: RefreshView {
    
    let indicator: UIActivityIndicatorView

    override init(height: CGFloat) {
        self.indicator = UIActivityIndicatorView(style: .medium)
        super.init(height: height)
        addSubview(indicator)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        indicator.center = CGPoint(x: bounds.midX, y: bounds.midY)
    }

    override func didUpdateState(_ isRefreshing: Bool) {
        isRefreshing ? indicator.startAnimating() : indicator.stopAnimating()
    }
    
    override func didUpdateProgress(_ progress: CGFloat) {
        
    }
    
}
