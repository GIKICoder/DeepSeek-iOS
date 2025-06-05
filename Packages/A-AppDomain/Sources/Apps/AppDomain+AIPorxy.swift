//
//  AppDomain+AIPorxy.swift
//  AppDomain
//
//  Created by GIKI on 2025/6/5.
//

import AIProxy
import Foundation

extension AppDomain {

    func setupAIProxy() {
        AIProxy.configure(
            logLevel: .debug,
            printRequestBodies: true,
            printResponseBodies: true,
            resolveDNSOverTLS: true,
            useStableID: true
        )
    }

}
