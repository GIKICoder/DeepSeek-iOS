// The MIT License (MIT)
//
// Copyright (c) 2016 Luke Zhao <me@lkzhao.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#if canImport(UIKit)

    import UIKit

    public class HeroContext {
        var heroIDToSourceView = [String: UIView]()
        var heroIDToDestinationView = [String: UIView]()
        var snapshotViews = [UIView: UIView]()
        var viewAlphas = [UIView: CGFloat]()
        var targetStates = [UIView: HeroTargetState]()
        var superviewToNoSnapshotSubviewMap: [UIView: [(Int, UIView)]] = [:]
        var insertToViewFirst = false

        var defaultCoordinateSpace: HeroCoordinateSpace = .local

        init(container: UIView) {
            self.container = container
        }

        func set(fromViews: [UIView], toViews: [UIView]) {
            self.fromViews = fromViews
            self.toViews = toViews
            process(views: fromViews, idMap: &heroIDToSourceView)
            process(views: toViews, idMap: &heroIDToDestinationView)
        }

        func process(views: [UIView], idMap: inout [String: UIView]) {
            for view in views {
                view.layer.removeAllHeroAnimations()
                let targetState: HeroTargetState?
                if let modifiers = view.hero.modifiers {
                    targetState = HeroTargetState(modifiers: modifiers)
                } else {
                    targetState = nil
                }
                if targetState?.forceAnimate == true || container.convert(view.bounds, from: view).intersects(container.bounds) {
                    if let heroID = view.hero.id {
                        idMap[heroID] = view
                    }
                    targetStates[view] = targetState
                }
            }
        }

        /**
         The container holding all of the animating views
         */
        public let container: UIView

        /**
         A flattened list of all views from source ViewController
         */
        public var fromViews: [UIView] = []

        /**
         A flattened list of all views from destination ViewController
         */
        public var toViews: [UIView] = []
    }

    // public
    extension HeroContext {
        /**
         - Returns: a source view matching the heroID, nil if not found
         */
        func sourceView(for heroID: String) -> UIView? {
            return heroIDToSourceView[heroID]
        }

        /**
         - Returns: a destination view matching the heroID, nil if not found
         */
        func destinationView(for heroID: String) -> UIView? {
            return heroIDToDestinationView[heroID]
        }

        /**
         - Returns: a view with the same heroID, but on different view controller, nil if not found
         */
        func pairedView(for view: UIView) -> UIView? {
            if let id = view.hero.id {
                if sourceView(for: id) == view {
                    return destinationView(for: id)
                } else if destinationView(for: id) == view {
                    return sourceView(for: id)
                }
            }
            return nil
        }

        /**
         - Returns: a snapshot view for animation
         */
        func snapshotView(for view: UIView) -> UIView {
            if let snapshot = snapshotViews[view] {
                return snapshot
            }

            var containerView = container
            let coordinateSpace = targetStates[view]?.coordinateSpace ?? defaultCoordinateSpace
            switch coordinateSpace {
            case .local:
                containerView = view
                while containerView != container, snapshotViews[containerView] == nil, let superview = containerView.superview {
                    containerView = superview
                }
                if let snapshot = snapshotViews[containerView] {
                    containerView = snapshot
                }

                if let visualEffectView = containerView as? UIVisualEffectView {
                    containerView = visualEffectView.contentView
                }
            case .global:
                break
            }

            unhide(view: view)

            // capture a snapshot without alpha, cornerRadius, or shadows
            let oldMaskedCorners: CACornerMask = {
                if #available(iOS 11, tvOS 11, *) {
                    return view.layer.maskedCorners
                } else {
                    return []
                }
            }()
            let oldCornerRadius = view.layer.cornerRadius
            let oldAlpha = view.alpha
            let oldShadowRadius = view.layer.shadowRadius
            let oldShadowOffset = view.layer.shadowOffset
            let oldShadowPath = view.layer.shadowPath
            let oldShadowOpacity = view.layer.shadowOpacity
            view.layer.cornerRadius = 0
            view.alpha = 1
            view.layer.shadowRadius = 0.0
            view.layer.shadowOffset = .zero
            view.layer.shadowPath = nil
            view.layer.shadowOpacity = 0.0

            let snapshot: UIView
            let snapshotType: HeroSnapshotType = self[view]?.snapshotType ?? .optimized

            switch snapshotType {
            case .normal:
                snapshot = view.snapshotView() ?? UIView()
            case .layerRender:
                snapshot = view.slowSnapshotView()
            case .noSnapshot:
                if let superview = view.superview, superview != container {
                    if superviewToNoSnapshotSubviewMap[superview] == nil {
                        superviewToNoSnapshotSubviewMap[superview] = []
                    }
                    if let index = superview.subviews.firstIndex(of: view) {
                        superviewToNoSnapshotSubviewMap[superview]!.append((index, view))
                    }
                }
                snapshot = view
            case .optimized:
                #if os(tvOS)
                    snapshot = view.snapshotView(afterScreenUpdates: true)!
                #else
                    if let customSnapshotView = view as? HeroCustomSnapshotView, let snapshotView = customSnapshotView.heroSnapshot {
                        snapshot = snapshotView
                    } else if #available(iOS 9.0, *), let stackView = view as? UIStackView {
                        snapshot = stackView.slowSnapshotView()
                    } else if let imageView = view as? UIImageView, view.subviews.filter({ !$0.isHidden }).isEmpty {
                        let contentView = UIImageView(image: imageView.image)
                        contentView.frame = imageView.bounds
                        contentView.contentMode = imageView.contentMode
                        contentView.tintColor = imageView.tintColor
                        contentView.backgroundColor = imageView.backgroundColor
                        contentView.layer.magnificationFilter = imageView.layer.magnificationFilter
                        contentView.layer.minificationFilter = imageView.layer.minificationFilter
                        contentView.layer.minificationFilterBias = imageView.layer.minificationFilterBias
                        let snapShotView = UIView()
                        snapShotView.addSubview(contentView)
                        snapshot = snapShotView
                    } else if let barView = view as? UINavigationBar, barView.isTranslucent {
                        let newBarView = UINavigationBar(frame: barView.frame)

                        newBarView.barStyle = barView.barStyle
                        newBarView.tintColor = barView.tintColor
                        newBarView.barTintColor = barView.barTintColor
                        newBarView.clipsToBounds = false

                        // take a snapshot without the background
                        barView.layer.sublayers![0].opacity = 0
                        let realSnapshot = barView.snapshotView(afterScreenUpdates: true)!
                        barView.layer.sublayers![0].opacity = 1

                        newBarView.addSubview(realSnapshot)
                        snapshot = newBarView
                    } else if let effectView = view as? UIVisualEffectView {
                        snapshot = UIVisualEffectView(effect: effectView.effect)
                        snapshot.frame = effectView.bounds
                    } else {
                        snapshot = view.snapshotView() ?? UIView()
                    }
                #endif
            }

            #if os(tvOS)
                if let imageView = view as? UIImageView, imageView.adjustsImageWhenAncestorFocused {
                    snapshot.frame = imageView.focusedFrameGuide.layoutFrame
                }
            #endif

            if #available(iOS 11, tvOS 11, *) {
                view.layer.maskedCorners = oldMaskedCorners
            }
            view.layer.cornerRadius = oldCornerRadius
            view.alpha = oldAlpha
            view.layer.shadowRadius = oldShadowRadius
            view.layer.shadowOffset = oldShadowOffset
            view.layer.shadowPath = oldShadowPath
            view.layer.shadowOpacity = oldShadowOpacity

            snapshot.layer.anchorPoint = view.layer.anchorPoint
            if let superview = view.superview {
                snapshot.layer.position = containerView.convert(view.layer.position, from: superview)
            }
            snapshot.layer.transform = containerView.layer.flatTransformTo(layer: view.layer)
            snapshot.layer.bounds = view.layer.bounds
            snapshot.hero.id = view.hero.id

            if snapshotType != .noSnapshot {
                if !(view is UINavigationBar), let contentView = snapshot.subviews.get(0) {
                    // the Snapshot's contentView must have hold the cornerRadius value,
                    // since the snapshot might not have maskToBounds set
                    if #available(iOS 11, tvOS 11, *) {
                        contentView.layer.maskedCorners = view.layer.maskedCorners
                    }
                    contentView.layer.cornerRadius = view.layer.cornerRadius
                    contentView.layer.masksToBounds = true
                }

                if #available(iOS 11, tvOS 11, *) {
                    snapshot.layer.maskedCorners = view.layer.maskedCorners
                }
                snapshot.layer.cornerRadius = view.layer.cornerRadius
                snapshot.layer.allowsGroupOpacity = false
                snapshot.layer.zPosition = view.layer.zPosition
                snapshot.layer.opacity = view.layer.opacity
                snapshot.layer.isOpaque = view.layer.isOpaque
                snapshot.layer.anchorPoint = view.layer.anchorPoint
                snapshot.layer.masksToBounds = view.layer.masksToBounds
                snapshot.layer.borderColor = view.layer.borderColor
                snapshot.layer.borderWidth = view.layer.borderWidth
                snapshot.layer.contentsRect = view.layer.contentsRect
                snapshot.layer.contentsScale = view.layer.contentsScale

                if self[view]?.displayShadow ?? true {
                    snapshot.layer.shadowRadius = view.layer.shadowRadius
                    snapshot.layer.shadowOpacity = view.layer.shadowOpacity
                    snapshot.layer.shadowColor = view.layer.shadowColor
                    snapshot.layer.shadowOffset = view.layer.shadowOffset
                    snapshot.layer.shadowPath = view.layer.shadowPath
                }

                hide(view: view)
            }

            if
                let pairedView = pairedView(for: view),
                let pairedSnapshot = snapshotViews[pairedView],
                let siblingViews = pairedView.superview?.subviews,
                let index = siblingViews.firstIndex(of: pairedView)
            {
                let nextSiblings = siblingViews[index + 1 ..< siblingViews.count]
                containerView.addSubview(pairedSnapshot)
                containerView.addSubview(snapshot)
                for subview in pairedView.subviews {
                    insertGlobalViewTree(view: subview)
                }
                for sibling in nextSiblings {
                    insertGlobalViewTree(view: sibling)
                }
            } else {
                containerView.addSubview(snapshot)
            }
            containerView.addSubview(snapshot)
            snapshotViews[view] = snapshot
            return snapshot
        }

        func insertGlobalViewTree(view: UIView) {
            if targetStates[view]?.coordinateSpace == .global, let snapshot = snapshotViews[view] {
                container.addSubview(snapshot)
            }
            for subview in view.subviews {
                insertGlobalViewTree(view: subview)
            }
        }

        subscript(view: UIView) -> HeroTargetState? {
            get {
                return targetStates[view]
            }
            set {
                targetStates[view] = newValue
            }
        }

        func clean() {
            for (superview, subviews) in superviewToNoSnapshotSubviewMap {
                for (index, view) in subviews.reversed() {
                    superview.insertSubview(view, at: index)
                }
            }
        }
    }

    // internal
    extension HeroContext {
        public func hide(view: UIView) {
            if viewAlphas[view] == nil {
                if view is UIVisualEffectView {
                    view.isHidden = true
                    viewAlphas[view] = 1
                } else {
                    viewAlphas[view] = view.alpha
                    view.alpha = 0
                }
            }
        }

        public func unhide(view: UIView) {
            if let oldAlpha = viewAlphas[view] {
                if view is UIVisualEffectView {
                    view.isHidden = false
                } else {
                    view.alpha = oldAlpha
                }
                viewAlphas[view] = nil
            }
        }

        func unhideAll() {
            for view in viewAlphas.keys {
                unhide(view: view)
            }
            viewAlphas.removeAll()
        }

        func unhide(rootView: UIView) {
            unhide(view: rootView)
            for subview in rootView.subviews {
                unhide(rootView: subview)
            }
        }

        func removeAllSnapshots() {
            for (view, snapshot) in snapshotViews {
                if view != snapshot {
                    snapshot.removeFromSuperview()
                } else {
                    view.layer.removeAllHeroAnimations()
                }
            }
        }

        func removeSnapshots(rootView: UIView) {
            if let snapshot = snapshotViews[rootView] {
                if rootView != snapshot {
                    snapshot.removeFromSuperview()
                } else {
                    rootView.layer.removeAllHeroAnimations()
                }
            }
            for subview in rootView.subviews {
                removeSnapshots(rootView: subview)
            }
        }

        func snapshots(rootView: UIView) -> [UIView] {
            var snapshots = [UIView]()
            for v in rootView.flattenedViewHierarchy {
                if let snapshot = snapshotViews[v] {
                    snapshots.append(snapshot)
                }
            }
            return snapshots
        }

        func loadViewAlpha(rootView: UIView) {
            if let storedAlpha = rootView.hero.storedAlpha {
                rootView.alpha = storedAlpha
                rootView.hero.storedAlpha = nil
            }
            for subview in rootView.subviews {
                loadViewAlpha(rootView: subview)
            }
        }

        func storeViewAlpha(rootView: UIView) {
            rootView.hero.storedAlpha = viewAlphas[rootView]
            for subview in rootView.subviews {
                storeViewAlpha(rootView: subview)
            }
        }
    }

    /// Allows a view to create their own custom snapshot when using **Optimized** snapshot
    public protocol HeroCustomSnapshotView {
        var heroSnapshot: UIView? { get }
    }

#endif
