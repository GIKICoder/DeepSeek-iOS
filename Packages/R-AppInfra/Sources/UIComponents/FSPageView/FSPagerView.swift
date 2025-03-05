//
//  FSPagerView.swift
//  FSPagerView
//
//  Created by Wenchao Ding on 17/12/2016.
//  Copyright © 2016 Wenchao Ding. All rights reserved.
//
//  https://github.com/WenchaoD
//
//  FSPagerView is an elegant Screen Slide Library implemented primarily with UICollectionView. It is extremely helpful for making Banner、Product Show、Welcome/Guide Pages、Screen/ViewController Sliders.
//

import UIKit

@objc
public protocol FSPagerViewDataSource: NSObjectProtocol {
    /// Asks your data source object for the number of items in the pager view.
    @objc(numberOfItemsInPagerView:)
    func numberOfItems(in pagerView: FSPagerView) -> Int

    /// Asks your data source object for the cell that corresponds to the specified item in the pager view.
    @objc(pagerView:cellForItemAtIndex:)
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell
}

@objc
public protocol FSPagerViewDelegate: NSObjectProtocol {
    /// Asks the delegate if the item should be highlighted during tracking.
    @objc(pagerView:shouldHighlightItemAtIndex:)
    optional func pagerView(_ pagerView: FSPagerView, shouldHighlightItemAt index: Int) -> Bool

    /// Tells the delegate that the item at the specified index was highlighted.
    @objc(pagerView:didHighlightItemAtIndex:)
    optional func pagerView(_ pagerView: FSPagerView, didHighlightItemAt index: Int)

    /// Asks the delegate if the specified item should be selected.
    @objc(pagerView:shouldSelectItemAtIndex:)
    optional func pagerView(_ pagerView: FSPagerView, shouldSelectItemAt index: Int) -> Bool

    /// Tells the delegate that the item at the specified index was selected.
    @objc(pagerView:didSelectItemAtIndex:)
    optional func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int)

    /// Tells the delegate that the specified cell is about to be displayed in the pager view.
    @objc(pagerView:willDisplayCell:forItemAtIndex:)
    optional func pagerView(_ pagerView: FSPagerView, willDisplay cell: FSPagerViewCell, forItemAt index: Int)

    /// Tells the delegate that the specified cell was removed from the pager view.
    @objc(pagerView:didEndDisplayingCell:forItemAtIndex:)
    optional func pagerView(_ pagerView: FSPagerView, didEndDisplaying cell: FSPagerViewCell, forItemAt index: Int)

    /// Tells the delegate when the pager view is about to start scrolling the content.
    @objc(pagerViewWillBeginDragging:)
    optional func pagerViewWillBeginDragging(_ pagerView: FSPagerView)

    /// Tells the delegate when the user finishes scrolling the content.
    @objc(pagerViewWillEndDragging:targetIndex:)
    optional func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int)

    /// Tells the delegate when the user scrolls the content view within the receiver.
    @objc(pagerViewDidScroll:)
    optional func pagerViewDidScroll(_ pagerView: FSPagerView)

    /// Tells the delegate when a scrolling animation in the pager view concludes.
    @objc(pagerViewDidEndScrollAnimation:)
    optional func pagerViewDidEndScrollAnimation(_ pagerView: FSPagerView)

    /// Tells the delegate that the pager view has ended decelerating the scrolling movement.
    @objc(pagerViewDidEndDecelerating:)
    optional func pagerViewDidEndDecelerating(_ pagerView: FSPagerView)
}

@IBDesignable
open class FSPagerView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    // MARK: - Public properties

    /// The object that acts as the data source of the pager view.
    @IBOutlet open weak var dataSource: (any FSPagerViewDataSource)?

    /// The object that acts as the delegate of the pager view.
    @IBOutlet open weak var delegate: (any FSPagerViewDelegate)?

    /// The scroll direction of the pager view. Default is horizontal.
    @objc
    open var scrollDirection: FSPagerView.ScrollDirection = .horizontal {
        didSet {
            collectionViewLayout.forceInvalidate()
        }
    }

    /// The time interval of automatic sliding. 0 means disabling automatic sliding. Default is 0.
    @IBInspectable
    open var automaticSlidingInterval: CGFloat = 0.0 {
        didSet {
            cancelTimer()
            if automaticSlidingInterval > 0 {
                startTimer()
            }
        }
    }

    /// The spacing to use between items in the pager view. Default is 0.
    @IBInspectable
    open var interitemSpacing: CGFloat = 0 {
        didSet {
            collectionViewLayout.forceInvalidate()
        }
    }

    /// The item size of the pager view. When the value of this property is FSPagerView.automaticSize, the items fill the entire visible area of the pager view. Default is FSPagerView.automaticSize.
    @IBInspectable
    open var itemSize: CGSize = automaticSize {
        didSet {
            collectionViewLayout.forceInvalidate()
        }
    }

    /// A Boolean value indicates that whether the pager view has infinite items. Default is false.
    @IBInspectable
    open var isInfinite: Bool = false {
        didSet {
            collectionViewLayout.needsReprepare = true
            collectionView.reloadData()
        }
    }

    /// An unsigned integer value that determines the deceleration distance of the pager view, which indicates the number of passing items during the deceleration. When the value of this property is FSPagerView.automaticDistance, the actual 'distance' is automatically calculated according to the scrolling speed of the pager view. Default is 1.
    @IBInspectable
    open var decelerationDistance: UInt = 1

    /// A Boolean value that determines whether scrolling is enabled.
    @IBInspectable
    open var isScrollEnabled: Bool {
        set { collectionView.isScrollEnabled = newValue }
        get { return collectionView.isScrollEnabled }
    }

    /// A Boolean value that controls whether the pager view bounces past the edge of content and back again.
    @IBInspectable
    open var bounces: Bool {
        set { collectionView.bounces = newValue }
        get { return collectionView.bounces }
    }

    /// A Boolean value that determines whether bouncing always occurs when horizontal scrolling reaches the end of the content view.
    @IBInspectable
    open var alwaysBounceHorizontal: Bool {
        set { collectionView.alwaysBounceHorizontal = newValue }
        get { return collectionView.alwaysBounceHorizontal }
    }

    /// A Boolean value that determines whether bouncing always occurs when vertical scrolling reaches the end of the content view.
    @IBInspectable
    open var alwaysBounceVertical: Bool {
        set { collectionView.alwaysBounceVertical = newValue }
        get { return collectionView.alwaysBounceVertical }
    }

    /// A Boolean value that controls whether the infinite loop is removed if there is only one item. Default is false.
    @IBInspectable
    open var removesInfiniteLoopForSingleItem: Bool = false {
        didSet {
            reloadData()
        }
    }

    /// The background view of the pager view.
    @IBInspectable
    open var backgroundView: UIView? {
        didSet {
            if let backgroundView = backgroundView {
                if backgroundView.superview != nil {
                    backgroundView.removeFromSuperview()
                }
                insertSubview(backgroundView, at: 0)
                setNeedsLayout()
            }
        }
    }

    /// The transformer of the pager view.
    @objc
    open var transformer: FSPagerViewTransformer? {
        didSet {
            transformer?.pagerView = self
            collectionViewLayout.forceInvalidate()
        }
    }

    // MARK: - Public readonly-properties

    /// Returns whether the user has touched the content to initiate scrolling.
    @objc
    open var isTracking: Bool {
        return collectionView.isTracking
    }

    /// The percentage of x position at which the origin of the content view is offset from the origin of the pagerView view.
    @objc
    open var scrollOffset: CGFloat {
        let contentOffset = max(collectionView.contentOffset.x, collectionView.contentOffset.y)
        let scrollOffset = Double(contentOffset / collectionViewLayout.itemSpacing)
        return fmod(CGFloat(scrollOffset), CGFloat(numberOfItems))
    }

    /// The underlying gesture recognizer for pan gestures.
    @objc
    open var panGestureRecognizer: UIPanGestureRecognizer {
        return collectionView.panGestureRecognizer
    }

    @objc open fileprivate(set) dynamic var currentIndex: Int = 0

    // MARK: - Private properties

    weak var collectionViewLayout: FSPagerViewLayout!
    weak var collectionView: FSPagerCollectionView!
    weak var contentView: UIView!
    var timer: Timer?
    var numberOfItems: Int = 0
    var numberOfSections: Int = 0

    fileprivate var dequeingSection = 0
    fileprivate var centermostIndexPath: IndexPath {
        guard numberOfItems > 0, collectionView.contentSize != .zero else {
            return IndexPath(item: 0, section: 0)
        }
        let sortedIndexPaths = collectionView.indexPathsForVisibleItems.sorted { l, r -> Bool in
            let leftFrame = self.collectionViewLayout.frame(for: l)
            let rightFrame = self.collectionViewLayout.frame(for: r)
            var leftCenter: CGFloat, rightCenter: CGFloat, ruler: CGFloat
            switch self.scrollDirection {
            case .horizontal:
                leftCenter = leftFrame.midX
                rightCenter = rightFrame.midX
                ruler = self.collectionView.bounds.midX
            case .vertical:
                leftCenter = leftFrame.midY
                rightCenter = rightFrame.midY
                ruler = self.collectionView.bounds.midY
            }
            return abs(ruler - leftCenter) < abs(ruler - rightCenter)
        }
        let indexPath = sortedIndexPaths.first
        if let indexPath = indexPath {
            return indexPath
        }
        return IndexPath(item: 0, section: 0)
    }

    fileprivate var isPossiblyRotating: Bool {
        guard let animationKeys = contentView.layer.animationKeys() else {
            return false
        }
        let rotationAnimationKeys = ["position", "bounds.origin", "bounds.size"]
        return animationKeys.contains(where: { rotationAnimationKeys.contains($0) })
    }

    fileprivate var possibleTargetingIndexPath: IndexPath?

    // MARK: - Overriden functions

    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        backgroundView?.frame = bounds
        contentView.frame = bounds
        collectionView.frame = contentView.bounds
    }

    override open func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if newWindow != nil {
            startTimer()
        } else {
            cancelTimer()
        }
    }

    #if TARGET_INTERFACE_BUILDER

        override open func prepareForInterfaceBuilder() {
            super.prepareForInterfaceBuilder()
            contentView.layer.borderWidth = 1
            contentView.layer.cornerRadius = 5
            contentView.layer.masksToBounds = true
            contentView.frame = bounds
            let label = UILabel(frame: contentView.bounds)
            label.textAlignment = .center
            label.font = UIFont.boldSystemFont(ofSize: 25)
            label.text = "FSPagerView"
            contentView.addSubview(label)
        }

    #endif

    deinit {
        self.collectionView.dataSource = nil
        self.collectionView.delegate = nil
    }

    // MARK: - UICollectionViewDataSource

    public func numberOfSections(in _: UICollectionView) -> Int {
        guard let dataSource = dataSource else {
            return 1
        }
        numberOfItems = dataSource.numberOfItems(in: self)
        guard numberOfItems > 0 else {
            return 0
        }
        numberOfSections = isInfinite && (numberOfItems > 1 || !removesInfiniteLoopForSingleItem) ? Int(Int16.max) / numberOfItems : 1
        return numberOfSections
    }

    public func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return numberOfItems
    }

    public func collectionView(_: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let index = indexPath.item
        dequeingSection = indexPath.section
        let cell = dataSource!.pagerView(self, cellForItemAt: index)
        return cell
    }

    // MARK: - UICollectionViewDelegate

    public func collectionView(_: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        guard let function = delegate?.pagerView(_:shouldHighlightItemAt:) else {
            return true
        }
        let index = indexPath.item % numberOfItems
        return function(self, index)
    }

    public func collectionView(_: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        guard let function = delegate?.pagerView(_:didHighlightItemAt:) else {
            return
        }
        let index = indexPath.item % numberOfItems
        function(self, index)
    }

    public func collectionView(_: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let function = delegate?.pagerView(_:shouldSelectItemAt:) else {
            return true
        }
        let index = indexPath.item % numberOfItems
        return function(self, index)
    }

    public func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let function = delegate?.pagerView(_:didSelectItemAt:) else {
            return
        }
        possibleTargetingIndexPath = indexPath
        defer {
            self.possibleTargetingIndexPath = nil
        }
        let index = indexPath.item % numberOfItems
        function(self, index)
    }

    public func collectionView(_: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let function = delegate?.pagerView(_:willDisplay:forItemAt:) else {
            return
        }
        let index = indexPath.item % numberOfItems
        function(self, cell as! FSPagerViewCell, index)
    }

    public func collectionView(_: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let function = delegate?.pagerView(_:didEndDisplaying:forItemAt:) else {
            return
        }
        let index = indexPath.item % numberOfItems
        function(self, cell as! FSPagerViewCell, index)
    }

    public func scrollViewDidScroll(_: UIScrollView) {
        if !isPossiblyRotating && numberOfItems > 0 {
            // In case someone is using KVO
            let currentIndex = lround(Double(scrollOffset)) % numberOfItems
            if currentIndex != self.currentIndex {
                self.currentIndex = currentIndex
            }
        }
        guard let function = delegate?.pagerViewDidScroll else {
            return
        }
        function(self)
    }

    public func scrollViewWillBeginDragging(_: UIScrollView) {
        if let function = delegate?.pagerViewWillBeginDragging(_:) {
            function(self)
        }
        if automaticSlidingInterval > 0 {
            cancelTimer()
        }
    }

    public func scrollViewWillEndDragging(_: UIScrollView, withVelocity _: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if let function = delegate?.pagerViewWillEndDragging(_:targetIndex:) {
            let contentOffset = scrollDirection == .horizontal ? targetContentOffset.pointee.x : targetContentOffset.pointee.y
            let targetItem = lround(Double(contentOffset / collectionViewLayout.itemSpacing))
            function(self, targetItem % numberOfItems)
        }
        if automaticSlidingInterval > 0 {
            startTimer()
        }
    }

    public func scrollViewDidEndDecelerating(_: UIScrollView) {
        if let function = delegate?.pagerViewDidEndDecelerating {
            function(self)
        }
    }

    public func scrollViewDidEndScrollingAnimation(_: UIScrollView) {
        if let function = delegate?.pagerViewDidEndScrollAnimation {
            function(self)
        }
    }

    // MARK: - Public functions

    /// Register a class for use in creating new pager view cells.
    ///
    /// - Parameters:
    ///   - cellClass: The class of a cell that you want to use in the pager view.
    ///   - identifier: The reuse identifier to associate with the specified class. This parameter must not be nil and must not be an empty string.
    @objc(registerClass:forCellWithReuseIdentifier:)
    open func register(_ cellClass: Swift.AnyClass?, forCellWithReuseIdentifier identifier: String) {
        collectionView.register(cellClass, forCellWithReuseIdentifier: identifier)
    }

    /// Register a nib file for use in creating new pager view cells.
    ///
    /// - Parameters:
    ///   - nib: The nib object containing the cell object. The nib file must contain only one top-level object and that object must be of the type FSPagerViewCell.
    ///   - identifier: The reuse identifier to associate with the specified nib file. This parameter must not be nil and must not be an empty string.
    @objc(registerNib:forCellWithReuseIdentifier:)
    open func register(_ nib: UINib?, forCellWithReuseIdentifier identifier: String) {
        collectionView.register(nib, forCellWithReuseIdentifier: identifier)
    }

    /// Returns a reusable cell object located by its identifier
    ///
    /// - Parameters:
    ///   - identifier: The reuse identifier for the specified cell. This parameter must not be nil.
    ///   - index: The index specifying the location of the cell.
    /// - Returns: A valid FSPagerViewCell object.
    @objc(dequeueReusableCellWithReuseIdentifier:atIndex:)
    open func dequeueReusableCell(withReuseIdentifier identifier: String, at index: Int) -> FSPagerViewCell {
        let indexPath = IndexPath(item: index, section: dequeingSection)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        guard cell.isKind(of: FSPagerViewCell.self) else {
            fatalError("Cell class must be subclass of FSPagerViewCell")
        }
        return cell as! FSPagerViewCell
    }

    /// Reloads all of the data for the collection view.
    @objc(reloadData)
    open func reloadData() {
        collectionViewLayout.needsReprepare = true
        collectionView.reloadData()
    }

    /// Selects the item at the specified index and optionally scrolls it into view.
    ///
    /// - Parameters:
    ///   - index: The index path of the item to select.
    ///   - animated: Specify true to animate the change in the selection or false to make the change without animating it.
    @objc(selectItemAtIndex:animated:)
    open func selectItem(at index: Int, animated: Bool) {
        let indexPath = nearbyIndexPath(for: index)
        let scrollPosition: UICollectionView.ScrollPosition = scrollDirection == .horizontal ? .centeredHorizontally : .centeredVertically
        collectionView.selectItem(at: indexPath, animated: animated, scrollPosition: scrollPosition)
    }

    /// Deselects the item at the specified index.
    ///
    /// - Parameters:
    ///   - index: The index of the item to deselect.
    ///   - animated: Specify true to animate the change in the selection or false to make the change without animating it.
    @objc(deselectItemAtIndex:animated:)
    open func deselectItem(at index: Int, animated: Bool) {
        let indexPath = nearbyIndexPath(for: index)
        collectionView.deselectItem(at: indexPath, animated: animated)
    }

    /// Scrolls the pager view contents until the specified item is visible.
    ///
    /// - Parameters:
    ///   - index: The index of the item to scroll into view.
    ///   - animated: Specify true to animate the scrolling behavior or false to adjust the pager view’s visible content immediately.
    @objc(scrollToItemAtIndex:animated:)
    open func scrollToItem(at index: Int, animated: Bool) {
        guard index < numberOfItems else {
            fatalError("index \(index) is out of range [0...\(numberOfItems - 1)]")
        }
        let indexPath = { () -> IndexPath in
            if let indexPath = self.possibleTargetingIndexPath, indexPath.item == index {
                defer {
                    self.possibleTargetingIndexPath = nil
                }
                return indexPath
            }
            return self.numberOfSections > 1 ? self.nearbyIndexPath(for: index) : IndexPath(item: index, section: 0)
        }()
        let contentOffset = collectionViewLayout.contentOffset(for: indexPath)
        collectionView.setContentOffset(contentOffset, animated: animated)
    }

    /// Returns the index of the specified cell.
    ///
    /// - Parameter cell: The cell object whose index you want.
    /// - Returns: The index of the cell or NSNotFound if the specified cell is not in the pager view.
    @objc(indexForCell:)
    open func index(for cell: FSPagerViewCell) -> Int {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return NSNotFound
        }
        return indexPath.item
    }

    /// Returns the visible cell at the specified index.
    ///
    /// - Parameter index: The index that specifies the position of the cell.
    /// - Returns: The cell object at the corresponding position or nil if the cell is not visible or index is out of range.
    @objc(cellForItemAtIndex:)
    open func cellForItem(at index: Int) -> FSPagerViewCell? {
        let indexPath = nearbyIndexPath(for: index)
        return collectionView.cellForItem(at: indexPath) as? FSPagerViewCell
    }

    // MARK: - Private functions

    fileprivate func commonInit() {
        // Content View
        let contentView = UIView(frame: CGRect.zero)
        contentView.backgroundColor = UIColor.clear
        addSubview(contentView)
        self.contentView = contentView

        // UICollectionView
        let collectionViewLayout = FSPagerViewLayout()
        let collectionView = FSPagerCollectionView(frame: CGRect.zero, collectionViewLayout: collectionViewLayout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.clear
        self.contentView.addSubview(collectionView)
        self.collectionView = collectionView
        self.collectionViewLayout = collectionViewLayout
    }

    fileprivate func startTimer() {
        guard automaticSlidingInterval > 0 && timer == nil else {
            return
        }
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(automaticSlidingInterval), target: self, selector: #selector(flipNext(sender:)), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: .common)
    }

    @objc
    fileprivate func flipNext(sender _: Timer?) {
        guard let _ = superview, let _ = window, numberOfItems > 0, !self.isTracking else {
            return
        }
        let contentOffset: CGPoint = {
            let indexPath = self.centermostIndexPath
            let section = self.numberOfSections > 1 ? (indexPath.section + (indexPath.item + 1) / self.numberOfItems) : 0
            let item = (indexPath.item + 1) % self.numberOfItems
            return self.collectionViewLayout.contentOffset(for: IndexPath(item: item, section: section))
        }()
        collectionView.setContentOffset(contentOffset, animated: true)
    }

    fileprivate func cancelTimer() {
        guard timer != nil else {
            return
        }
        timer!.invalidate()
        timer = nil
    }

    fileprivate func nearbyIndexPath(for index: Int) -> IndexPath {
        // Is there a better algorithm?
        let currentIndex = self.currentIndex
        let currentSection = centermostIndexPath.section
        if abs(currentIndex - index) <= numberOfItems / 2 {
            return IndexPath(item: index, section: currentSection)
        } else if index - currentIndex >= 0 {
            return IndexPath(item: index, section: currentSection - 1)
        } else {
            return IndexPath(item: index, section: currentSection + 1)
        }
    }
}

public extension FSPagerView {
    /// Constants indicating the direction of scrolling for the pager view.
    @objc
    enum ScrollDirection: Int {
        /// The pager view scrolls content horizontally
        case horizontal
        /// The pager view scrolls content vertically
        case vertical
    }

    /// Requests that FSPagerView use the default value for a given distance.
    static let automaticDistance: UInt = 0

    /// Requests that FSPagerView use the default value for a given size.
    static let automaticSize: CGSize = .zero
}
