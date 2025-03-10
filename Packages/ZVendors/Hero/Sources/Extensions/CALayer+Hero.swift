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

    extension CALayer {
        // return all animations running by this layer.
        // the returned value is mutable
        var animations: [(String, CAAnimation)] {
            if let keys = animationKeys() {
                // swiftlint:disable:next force_cast
                return keys.map { ($0, self.animation(forKey: $0)!.copy() as! CAAnimation) }
            }
            return []
        }

        func flatTransformTo(layer: CALayer) -> CATransform3D {
            var layer = layer
            var trans = layer.transform
            while let superlayer = layer.superlayer, superlayer != self, !(superlayer.delegate is UIWindow) {
                trans = CATransform3DConcat(superlayer.transform, trans)
                layer = superlayer
            }
            return trans
        }

        func removeAllHeroAnimations() {
            guard let keys = animationKeys() else { return }
            for animationKey in keys where animationKey.hasPrefix("hero.") {
                removeAnimation(forKey: animationKey)
            }
        }
    }

#endif
