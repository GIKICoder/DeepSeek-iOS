
import UIKit

@MainActor
public class AutoFooterView: BaseFooterView {
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView) {
        guard !refreshingState.isRefreshing,
            scrollView.contentSize.height > scrollView.bounds.height,
            scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.bounds.height + scrollView.contentInsetBottom
            else { return }
        beginRefreshing()
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !refreshingState.isRefreshing,
            scrollView.contentSize.height > scrollView.bounds.height,
            scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.bounds.height + scrollView.contentInsetBottom
            else { return }
        beginRefreshing()
    }
    
}
