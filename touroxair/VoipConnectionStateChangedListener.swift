//
//  VoipConnectionStateChangedListener.swift
//  touroxair
//
//  Created by Marc Plouhinec on 09/04/16.
//  Copyright © 2016 Marc Plouhinec. All rights reserved.
//

import Foundation

protocol VoipConnectionStateChangedListener {
    
    func onVoipConnectionStateChanged(state: VoipConnectionState)
    
}