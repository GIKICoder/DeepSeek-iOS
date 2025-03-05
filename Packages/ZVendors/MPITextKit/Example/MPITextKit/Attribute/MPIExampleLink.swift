//
//  MPIExampleLink.swift
//  MPITextKit_Example
//
//  Created by Tpphha on 2020/4/23.
//  Copyright © 2020 美图网. All rights reserved.
//

import MPITextKit
import UIKit

public enum MPIExampleLinkType: Int, CustomDebugStringConvertible {
    case unknown
    case url
    case hashtag
    case mention

    public var debugDescription: String {
        switch self {
        case .unknown:
            return "unknown"
        case .url:
            return "url"
        case .hashtag:
            return "hashtag"
        case .mention:
            return "mention"
        }
    }
}

public class MPIExampleLink: MPITextLink {
    var linkType: MPIExampleLinkType

    override init() {
        linkType = .unknown
        super.init()
    }

    override public var hash: Int {
//            return super.hash ^ NSNumber.init(value: self.linkType.rawValue).hash
        var hasher = Hasher()
        hasher.combine(super.hash)
        hasher.combine(linkType)
        let hash = hasher.finalize()
        return hash
    }

    override public func isEqual(_ object: Any?) -> Bool {
        if !super.isEqual(object) {
            return false
        }

        guard let other = object as! MPIExampleLink? else {
            return false
        }

        return linkType == other.linkType
    }
}
