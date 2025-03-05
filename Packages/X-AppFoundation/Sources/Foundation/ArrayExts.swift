//
//  ArrayExtensions.swift
//  AppFoundation
//
//  Created by GIKI on 2025/1/10.
//

import UIKit

extension Array {
  public var second: Element? {
    self[safe: 1]
  }

  public var third: Element? {
    self[safe: 2]
  }

  public subscript(safe index: Int) -> Element? {
    indices ~= index ? self[index] : nil
  }
}

extension Array where Element: Comparable {
    /// Index of min element in Array
    public var indexOfMinElement: Int? {
        guard count > 0 else { return nil }
        var min = first
        var index = 0

        for i in indices {
            let currentItem = self[i]
            if let minumum = min, currentItem < minumum {
                min = currentItem
                index = i
            }
        }

        return index
    }

    public func removeDuplicates() -> [Element] {
        reduce(into: [Element]()) {
            if !$0.contains($1) {
                $0.append($1)
            }
        }
    }
}
