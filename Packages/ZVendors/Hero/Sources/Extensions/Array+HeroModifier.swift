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

import Foundation

#if canImport(CoreGraphics)
    import CoreGraphics
#endif

extension Array {
    func get(_ index: Int) -> Element? {
        if index < count {
            return self[index]
        }
        return nil
    }
}

extension Array where Element: ExprNode {
    #if canImport(CoreGraphics)
        func getCGFloat(_ index: Int) -> CGFloat? {
            if let s = get(index) as? NumberNode {
                return CGFloat(s.value)
            }
            return nil
        }
    #endif
    func getDouble(_ index: Int) -> Double? {
        if let s = get(index) as? NumberNode {
            return Double(s.value)
        }
        return nil
    }

    func getFloat(_ index: Int) -> Float? {
        if let s = get(index) as? NumberNode {
            return s.value
        }
        return nil
    }

    func getBool(_ index: Int) -> Bool? {
        if let s = get(index) as? VariableNode, let f = Bool(s.name) {
            return f
        }
        return nil
    }
}
