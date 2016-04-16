//
//  ApplicationServices.swift
//  touroxair
//
//  Created by Marc Plouhinec on 15/04/16.
//  Copyright © 2016 Marc Plouhinec. All rights reserved.
//

import Foundation

// Provide services to the other classes as singletons.
class ApplicationServices {
    static func getVoipService() -> VoipService {
        return VoipServicePjsip.instance
    }
}