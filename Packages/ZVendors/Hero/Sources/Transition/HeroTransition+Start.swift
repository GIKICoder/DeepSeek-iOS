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

    public extension HeroTransition {
        func start() {
            guard state == .notified else { return }
            state = .starting

            if let toView = toView, let fromView = fromView {
                // remember the superview of the view of the `fromViewController` which is
                // presenting the `toViewController` with `overFullscreen` `modalPresentationStyle`,
                // so that we can restore the presenting view controller's view later on dismiss
                if isPresenting, !inContainerController {
                    originalSuperview = fromView.superview
                    originalFrame = fromView.frame
                }
                if let toViewController = toViewController, let transitionContext = transitionContext {
                    toView.frame = transitionContext.finalFrame(for: toViewController)
                } else {
                    toView.frame = fromView.frame
                }
                toView.setNeedsLayout()
                if toView.window != nil {
                    toView.layoutIfNeeded()
                }
            }

            if let fvc = fromViewController, let tvc = toViewController {
                closureProcessForHeroDelegate(vc: fvc) {
                    $0.heroWillStartTransition?()
                    $0.heroWillStartAnimatingTo?(viewController: tvc)
                }

                closureProcessForHeroDelegate(vc: tvc) {
                    $0.heroWillStartTransition?()
                    $0.heroWillStartAnimatingFrom?(viewController: fvc)
                }
            }

            // take a snapshot to hide all the flashing that might happen
            fullScreenSnapshot = transitionContainer?.window?.snapshotView(afterScreenUpdates: false) ?? fromView?.snapshotView(afterScreenUpdates: false)
            if let fullScreenSnapshot = fullScreenSnapshot {
                (transitionContainer?.window ?? transitionContainer)?.addSubview(fullScreenSnapshot)
            }

            if let oldSnapshot = fromViewController?.hero.storedSnapshot {
                oldSnapshot.removeFromSuperview()
                fromViewController?.hero.storedSnapshot = nil
            }
            if let oldSnapshot = toViewController?.hero.storedSnapshot {
                oldSnapshot.removeFromSuperview()
                toViewController?.hero.storedSnapshot = nil
            }

            plugins = HeroTransition.enabledPlugins.map { $0.init() }
            processors = [
                IgnoreSubviewModifiersPreprocessor(),
                ConditionalPreprocessor(),
                DefaultAnimationPreprocessor(),
                MatchPreprocessor(),
                SourcePreprocessor(),
                CascadePreprocessor(),
            ]
            animators = [
                HeroDefaultAnimator<HeroCoreAnimationViewContext>(),
            ]

            if #available(iOS 10, tvOS 10, *) {
                animators.append(HeroDefaultAnimator<HeroViewPropertyViewContext>())
            }

            // There is no covariant in Swift, so we need to add plugins one by one.
            for plugin in plugins {
                processors.append(plugin)
                animators.append(plugin)
            }

            transitionContainer?.isUserInteractionEnabled = isUserInteractionEnabled

            // a view to hold all the animating views
            container = UIView(frame: transitionContainer?.bounds ?? .zero)
            container.isUserInteractionEnabled = false
            if !toOverFullScreen && !fromOverFullScreen {
                container.backgroundColor = containerColor
            }
            transitionContainer?.addSubview(container)

            context = HeroContext(container: container)

            for processor in processors {
                processor.hero = self
            }
            for animator in animators {
                animator.hero = self
            }

            if let toView = toView, let fromView = fromView, toView != fromView {
                // if we're presenting a view controller, remember the position & dimension
                // of the view relative to the transition container so that we can:
                // - correctly place the view in the transition container when presenting
                // - correctly place the view back to where it was when dismissing
                if isPresenting, !inContainerController {
                    originalFrameInContainer = fromView.superview?.convert(
                        fromView.frame, to: container
                    )
                }

                // when dismiss and before animating, place the `toView` to be animated
                // with the correct position and dimension in the transition container.
                // otherwise, there will be an apparent visual jagging when the animation begins.
                if !isPresenting, let frame = originalFrameInContainer {
                    toView.frame = frame
                }

                context.loadViewAlpha(rootView: toView)
                context.loadViewAlpha(rootView: fromView)
                container.addSubview(toView)
                container.addSubview(fromView)

                // when present and before animating, place the `fromView` to be animated
                // with the correct position and dimension in the transition container to
                // prevent any possible visual jagging when animation starts, even though not
                // that apparent in some cases.
                if isPresenting, let frame = originalFrameInContainer {
                    fromView.frame = frame
                }

                toView.updateConstraints()
                toView.setNeedsLayout()
                toView.layoutIfNeeded()

                context.set(fromViews: fromView.flattenedViewHierarchy, toViews: toView.flattenedViewHierarchy)
            }

            if (viewOrderingStrategy == .auto && !isPresenting && !inTabBarController) ||
                viewOrderingStrategy == .sourceViewOnTop
            {
                context.insertToViewFirst = true
            }

            for processor in processors {
                processor.process(fromViews: context.fromViews, toViews: context.toViews)
            }

            animatingFromViews = context.fromViews.filter { (view: UIView) -> Bool in
                animators.contains { $0.canAnimate(view: view, appearing: false) }
            }

            animatingToViews = context.toViews.filter { (view: UIView) -> Bool in
                animators.contains { $0.canAnimate(view: view, appearing: true) }
            }

            if let toView = toView {
                context.hide(view: toView)
            }

            #if os(tvOS)
                animate()
            #else
                if inNavigationController {
                    // When animating within navigationController, we have to dispatch later into the main queue.
                    // otherwise snapshots will be pure white. Possibly a bug with UIKit
                    DispatchQueue.main.async {
                        self.animate()
                    }
                } else {
                    animate()
                }
            #endif
        }
    }

#endif
