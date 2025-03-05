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
        /**
         Update the progress for the interactive transition.
         - Parameters:
         - progress: the current progress, must be between 0...1
         */
        func update(_ percentageComplete: CGFloat) {
            guard state == .animating else {
                startingProgress = percentageComplete
                return
            }
            progressRunner.stop()
            progress = Double(percentageComplete.clamp(0, 1))
        }

        /**
         Finish the interactive transition.
         Will stop the interactive transition and animate from the
         current state to the **end** state
         */
        func finish(animate: Bool = true) {
            guard state == .animating || state == .notified || state == .starting else { return }
            if !animate {
                complete(finished: true)
                return
            }
            var maxTime: TimeInterval = 0
            for animator in animators {
                maxTime = max(maxTime, animator.resume(timePassed: progress * totalDuration,
                                                       reverse: false))
            }
            complete(after: maxTime, finishing: true)
        }

        /**
         Cancel the interactive transition.
         Will stop the interactive transition and animate from the
         current state to the **beginning** state
         */
        func cancel(animate: Bool = true) {
            guard state == .animating || state == .notified || state == .starting else { return }
            if !animate {
                complete(finished: false)
                return
            }
            var maxTime: TimeInterval = 0
            for animator in animators {
                var adjustedProgress = progress
                if adjustedProgress < 0 {
                    adjustedProgress = -adjustedProgress
                }
                maxTime = max(maxTime, animator.resume(timePassed: adjustedProgress * totalDuration,
                                                       reverse: true))
            }
            complete(after: maxTime, finishing: false)
        }

        /**
         Override modifiers during an interactive animation.

         For example:

         Hero.shared.apply([.position(x:50, y:50)], to:view)

         will set the view's position to 50, 50
         - Parameters:
         - modifiers: the modifiers to override
         - view: the view to override to
         */
        func apply(modifiers: [HeroModifier], to view: UIView) {
            guard state == .animating else { return }
            let targetState = HeroTargetState(modifiers: modifiers)
            if let otherView = context.pairedView(for: view) {
                for animator in animators {
                    animator.apply(state: targetState, to: otherView)
                }
            }
            for animator in animators {
                animator.apply(state: targetState, to: view)
            }
        }

        /**
         Override target state during an interactive animation.

         For example:

         Hero.shared.changeTarget([.position(x:50, y:50)], to:view)

         will animate the view's position to 50, 50 once `finish(animate:)` is called
         - Parameters:
         - modifiers: the modifiers to override
         - isDestination: if false, it changes the starting state
         - view: the view to override to
         */
        func changeTarget(modifiers: [HeroModifier], isDestination: Bool = true, to view: UIView) {
            guard state == .animating else { return }
            let targetState = HeroTargetState(modifiers: modifiers)
            if let otherView = context.pairedView(for: view) {
                for animator in animators {
                    animator.changeTarget(state: targetState, isDestination: !isDestination, to: otherView)
                }
            }
            for animator in animators {
                animator.changeTarget(state: targetState, isDestination: isDestination, to: view)
            }
        }
    }

#endif
