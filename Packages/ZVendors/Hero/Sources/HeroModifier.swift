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
    import CoreGraphics
    import QuartzCore
    import UIKit

    public final class HeroModifier {
        let apply: (inout HeroTargetState) -> Void
        public init(applyFunction: @escaping (inout HeroTargetState) -> Void) {
            apply = applyFunction
        }
    }

    // basic modifiers
    public extension HeroModifier {
        /**
         Fade the view during transition
         */
        static var fade = HeroModifier { targetState in
            targetState.opacity = 0
        }

        /**
         Force don't fade view during transition
         */
        static var forceNonFade = HeroModifier { targetState in
            targetState.nonFade = true
        }

        /**
         Set the position for the view to animate from/to.
         - Parameters:
         - position: position for the view to animate from/to
         */
        static func position(_ position: CGPoint) -> HeroModifier {
            return HeroModifier { targetState in
                targetState.position = position
            }
        }

        /**
         Set the size for the view to animate from/to.
         - Parameters:
         - size: size for the view to animate from/to
         */
        static func size(_ size: CGSize) -> HeroModifier {
            return HeroModifier { targetState in
                targetState.size = size
            }
        }
    }

    // transform modifiers
    public extension HeroModifier {
        /**
         Set the transform for the view to animate from/to. Will override previous perspective, scale, translate, & rotate modifiers
         - Parameters:
         - t: the CATransform3D object
         */
        static func transform(_ t: CATransform3D) -> HeroModifier {
            return HeroModifier { targetState in
                targetState.transform = t
            }
        }

        /**
         Set the perspective on the transform. use in combination with the rotate modifier.
         - Parameters:
         - perspective: set the camera distance of the transform
         */
        static func perspective(_ perspective: CGFloat) -> HeroModifier {
            return HeroModifier { targetState in
                var transform = targetState.transform ?? CATransform3DIdentity
                transform.m34 = 1.0 / -perspective
                targetState.transform = transform
            }
        }

        /**
         Scale 3d
         - Parameters:
         - x: scale factor on x axis, default 1
         - y: scale factor on y axis, default 1
         - z: scale factor on z axis, default 1
         */
        static func scale(x: CGFloat = 1, y: CGFloat = 1, z: CGFloat = 1) -> HeroModifier {
            return HeroModifier { targetState in
                targetState.transform = CATransform3DScale(targetState.transform ?? CATransform3DIdentity, x, y, z)
            }
        }

        /**
         Scale in x & y axis
         - Parameters:
         - xy: scale factor in both x & y axis
         */
        static func scale(_ xy: CGFloat) -> HeroModifier {
            return .scale(x: xy, y: xy)
        }

        /**
         Translate 3d
         - Parameters:
         - x: translation distance on x axis in display pixel, default 0
         - y: translation distance on y axis in display pixel, default 0
         - z: translation distance on z axis in display pixel, default 0
         */
        static func translate(x: CGFloat = 0, y: CGFloat = 0, z: CGFloat = 0) -> HeroModifier {
            return HeroModifier { targetState in
                targetState.transform = CATransform3DTranslate(targetState.transform ?? CATransform3DIdentity, x, y, z)
            }
        }

        static func translate(_ point: CGPoint, z: CGFloat = 0) -> HeroModifier {
            return translate(x: point.x, y: point.y, z: z)
        }

        /**
         Rotate 3d
         - Parameters:
         - x: rotation on x axis in radian, default 0
         - y: rotation on y axis in radian, default 0
         - z: rotation on z axis in radian, default 0
         */
        static func rotate(x: CGFloat = 0, y: CGFloat = 0, z: CGFloat = 0) -> HeroModifier {
            return HeroModifier { targetState in
                targetState.transform = CATransform3DRotate(targetState.transform ?? CATransform3DIdentity, x, 1, 0, 0)
                targetState.transform = CATransform3DRotate(targetState.transform!, y, 0, 1, 0)
                targetState.transform = CATransform3DRotate(targetState.transform!, z, 0, 0, 1)
            }
        }

        static func rotate(_ point: CGPoint, z: CGFloat = 0) -> HeroModifier {
            return rotate(x: point.x, y: point.y, z: z)
        }

        /**
         Rotate 2d
         - Parameters:
         - z: rotation in radian
         */
        static func rotate(_ z: CGFloat) -> HeroModifier {
            return .rotate(z: z)
        }
    }

    // MARK: UIKit

    public extension HeroModifier {
        /**
         Set the backgroundColor for the view to animate from/to.
         - Parameters:
         - backgroundColor: backgroundColor for the view to animate from/to
         */
        static func backgroundColor(_ backgroundColor: UIColor) -> HeroModifier {
            return HeroModifier { targetState in
                targetState.backgroundColor = backgroundColor.cgColor
            }
        }

        /**
         Set the borderColor for the view to animate from/to.
         - Parameters:
         - borderColor: borderColor for the view to animate from/to
         */
        static func borderColor(_ borderColor: UIColor) -> HeroModifier {
            return HeroModifier { targetState in
                targetState.borderColor = borderColor.cgColor
            }
        }

        /**
         Set the shadowColor for the view to animate from/to.
         - Parameters:
         - shadowColor: shadowColor for the view to animate from/to
         */
        static func shadowColor(_ shadowColor: UIColor) -> HeroModifier {
            return HeroModifier { targetState in
                targetState.shadowColor = shadowColor.cgColor
            }
        }

        /**
         Create an overlay on the animating view.
         - Parameters:
         - color: color of the overlay
         - opacity: opacity of the overlay
         */
        static func overlay(color: UIColor, opacity: CGFloat) -> HeroModifier {
            return HeroModifier { targetState in
                targetState.overlay = (color.cgColor, opacity)
            }
        }
    }

    public extension HeroModifier {
        /**
         Set the opacity for the view to animate from/to.
         - Parameters:
         - opacity: opacity for the view to animate from/to
         */
        static func opacity(_ opacity: CGFloat) -> HeroModifier {
            return HeroModifier { targetState in
                targetState.opacity = Float(opacity)
            }
        }

        /**
         Set the cornerRadius for the view to animate from/to.
         - Parameters:
         - cornerRadius: cornerRadius for the view to animate from/to
         */
        static func cornerRadius(_ cornerRadius: CGFloat) -> HeroModifier {
            return HeroModifier { targetState in
                targetState.cornerRadius = cornerRadius
            }
        }

        /**
         Set the zPosition for the view to animate from/to.
         - Parameters:
         - zPosition: zPosition for the view to animate from/to
         */
        static func zPosition(_ zPosition: CGFloat) -> HeroModifier {
            return HeroModifier { targetState in
                targetState.zPosition = zPosition
            }
        }

        /**
         Set the contentsRect for the view to animate from/to.
         - Parameters:
         - contentsRect: contentsRect for the view to animate from/to
         */
        static func contentsRect(_ contentsRect: CGRect) -> HeroModifier {
            return HeroModifier { targetState in
                targetState.contentsRect = contentsRect
            }
        }

        /**
         Set the contentsScale for the view to animate from/to.
         - Parameters:
         - contentsScale: contentsScale for the view to animate from/to
         */
        static func contentsScale(_ contentsScale: CGFloat) -> HeroModifier {
            return HeroModifier { targetState in
                targetState.contentsScale = contentsScale
            }
        }

        /**
         Set the borderWidth for the view to animate from/to.
         - Parameters:
         - borderWidth: borderWidth for the view to animate from/to
         */
        static func borderWidth(_ borderWidth: CGFloat) -> HeroModifier {
            return HeroModifier { targetState in
                targetState.borderWidth = borderWidth
            }
        }

        /**
         Set the shadowOpacity for the view to animate from/to.
         - Parameters:
         - shadowOpacity: shadowOpacity for the view to animate from/to
         */
        static func shadowOpacity(_ shadowOpacity: CGFloat) -> HeroModifier {
            return HeroModifier { targetState in
                targetState.shadowOpacity = Float(shadowOpacity)
            }
        }

        /**
         Set the shadowOffset for the view to animate from/to.
         - Parameters:
         - shadowOffset: shadowOffset for the view to animate from/to
         */
        static func shadowOffset(_ shadowOffset: CGSize) -> HeroModifier {
            return HeroModifier { targetState in
                targetState.shadowOffset = shadowOffset
            }
        }

        /**
         Set the shadowRadius for the view to animate from/to.
         - Parameters:
         - shadowRadius: shadowRadius for the view to animate from/to
         */
        static func shadowRadius(_ shadowRadius: CGFloat) -> HeroModifier {
            return HeroModifier { targetState in
                targetState.shadowRadius = shadowRadius
            }
        }

        /**
         Set the shadowPath for the view to animate from/to.
         - Parameters:
         - shadowPath: shadowPath for the view to animate from/to
         */
        static func shadowPath(_ shadowPath: CGPath) -> HeroModifier {
            return HeroModifier { targetState in
                targetState.shadowPath = shadowPath
            }
        }

        /**
         Set the masksToBounds for the view to animate from/to.
         - Parameters:
         - masksToBounds: masksToBounds for the view to animate from/to
         */
        static func masksToBounds(_ masksToBounds: Bool) -> HeroModifier {
            return HeroModifier { targetState in
                targetState.masksToBounds = masksToBounds
            }
        }
    }

    // timing modifiers
    public extension HeroModifier {
        /**
         Sets the duration of the animation for a given view. If not used, Hero will use determine the duration based on the distance and size changes.
         - Parameters:
         - duration: duration of the animation

         Note: a duration of .infinity means matching the duration of the longest animation. same as .durationMatchLongest
         */
        static func duration(_ duration: TimeInterval) -> HeroModifier {
            return HeroModifier { targetState in
                targetState.duration = duration
            }
        }

        /**
         Sets the duration of the animation for a given view to match the longest animation of the transition.
         */
        static var durationMatchLongest: HeroModifier = HeroModifier { targetState in
            targetState.duration = .infinity
        }

        /**
         Sets the delay of the animation for a given view.
         - Parameters:
         - delay: delay of the animation
         */
        static func delay(_ delay: TimeInterval) -> HeroModifier {
            return HeroModifier { targetState in
                targetState.delay = delay
            }
        }

        /**
         Sets the timing function of the animation for a given view. If not used, Hero will use determine the timing function based on whether or not the view is entering or exiting the screen.
         - Parameters:
         - timingFunction: timing function of the animation
         */
        static func timingFunction(_ timingFunction: CAMediaTimingFunction) -> HeroModifier {
            return HeroModifier { targetState in
                targetState.timingFunction = timingFunction
            }
        }

        /**
         (iOS 9+) Use spring animation with custom stiffness & damping. The duration will be automatically calculated. Will be ignored if arc, timingFunction, or duration is set.
         - Parameters:
         - stiffness: stiffness of the spring
         - damping: damping of the spring
         */
        @available(iOS 9, *)
        static func spring(stiffness: CGFloat, damping: CGFloat) -> HeroModifier {
            return HeroModifier { targetState in
                targetState.spring = (stiffness, damping)
            }
        }
    }

    // other modifiers
    public extension HeroModifier {
        /**
         Transition from/to the state of the view with matching heroID
         Will also force the view to use global coordinate space.

         The following layer properties will be animated from the given view.

         position
         bounds.size
         cornerRadius
         transform
         shadowColor
         shadowOpacity
         shadowOffset
         shadowRadius
         shadowPath

         Note that the following properties **won't** be taken from the source view.

         backgroundColor
         borderWidth
         borderColor

         - Parameters:
         - heroID: the source view's heroId.
         */
        static func source(heroID: String) -> HeroModifier {
            return HeroModifier { targetState in
                targetState.source = heroID
            }
        }

        /**
         Works in combination with position modifier to apply a natural curve when moving to the destination.
         */
        static var arc: HeroModifier = .arc()

        /**
         Works in combination with position modifier to apply a natural curve when moving to the destination.
         - Parameters:
         - intensity: a value of 1 represent a downward natural curve ╰. a value of -1 represent a upward curve ╮.
         default is 1.
         */
        static func arc(intensity: CGFloat = 1) -> HeroModifier {
            return HeroModifier { targetState in
                targetState.arc = intensity
            }
        }

        /**
         Cascade applys increasing delay modifiers to subviews
         */
        static var cascade: HeroModifier = .cascade()

        /**
         Cascade applys increasing delay modifiers to subviews
         - Parameters:
         - delta: delay in between each animation
         - direction: cascade direction
         - delayMatchedViews: whether or not to delay matched subviews until all cascading animation have started
         */
        static func cascade(delta: TimeInterval = 0.02,
                            direction: CascadeDirection = .topToBottom,
                            delayMatchedViews: Bool = false) -> HeroModifier
        {
            return HeroModifier { targetState in
                targetState.cascade = (delta, direction, delayMatchedViews)
            }
        }
    }

    // conditional modifiers
    public extension HeroModifier {
        /**
         Apply modifiers only if the condition return true.
         */
        static func when(_ condition: @escaping (HeroConditionalContext) -> Bool, _ modifiers: [HeroModifier]) -> HeroModifier {
            return HeroModifier { targetState in
                if targetState.conditionalModifiers == nil {
                    targetState.conditionalModifiers = []
                }
                targetState.conditionalModifiers!.append((condition, modifiers))
            }
        }

        static func when(_ condition: @escaping (HeroConditionalContext) -> Bool, _ modifiers: HeroModifier...) -> HeroModifier {
            return .when(condition, modifiers)
        }

        static func whenMatched(_ modifiers: HeroModifier...) -> HeroModifier {
            return .when({ $0.isMatched }, modifiers)
        }

        static func whenPresenting(_ modifiers: HeroModifier...) -> HeroModifier {
            return .when({ $0.isPresenting }, modifiers)
        }

        static func whenDismissing(_ modifiers: HeroModifier...) -> HeroModifier {
            return .when({ !$0.isPresenting }, modifiers)
        }

        static func whenAppearing(_ modifiers: HeroModifier...) -> HeroModifier {
            return .when({ $0.isAppearing }, modifiers)
        }

        static func whenDisappearing(_ modifiers: HeroModifier...) -> HeroModifier {
            return .when({ !$0.isAppearing }, modifiers)
        }
    }
#endif
