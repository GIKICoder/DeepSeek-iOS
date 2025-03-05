
import UIKit

@MainActor
public class AutoHeaderView: BaseHeaderView {
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView) {
        guard !refreshingState.isRefreshing && refreshingState.canRefreshing else { return }
        let contentOffsetY = scrollView.contentOffset.y + scrollView.contentInsetTop
        guard contentOffsetY < 0 && -contentOffsetY >= height else { return }
        beginRefreshing()
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !refreshingState.isRefreshing && refreshingState.canRefreshing else { return }
        let contentOffsetY = scrollView.contentOffset.y + scrollView.contentInsetTop
        guard contentOffsetY < 0 && -contentOffsetY >= height else { return }
        beginRefreshing()
    }
    
}
