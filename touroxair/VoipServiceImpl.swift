//
//  VoipServiceImpl.swift
//  touroxair
//
//  Created by Marc Plouhinec on 09/04/16.
//  Copyright © 2016 Marc Plouhinec. All rights reserved.
//

import Foundation

// Default implementation of VoipService
// Thanks to https://ftp.yzu.edu.tw/nongnu/linphone/docs/liblinphone/group__IOS.html
// Thqnks to http://stackoverflow.com/questions/3562991/uibackgroundmodes-key-not-showing-in-info-plist-dropdown
// Thanks to https://github.com/BelledonneCommunications/linphone-iphone
class VoipServiceImpl: VoipService {
    
    var currentVoipConnectionState = VoipConnectionState.NOT_CONNECTED
    
    func initialize() {
        // TODO
    }
    
    func destroy() {
        // TODO
    }
    
    func registerVoipConnectionStateChangedListener(listener: VoipConnectionStateChangedListener) {
        // TODO
    }
    
    func openConnection(username: String, password: String, hostname: String) {
        // TODO
    }
    
    func closeConnection() {
        // TODO
    }
    
    func getVoipConnectionState() -> VoipConnectionState {
        return currentVoipConnectionState
    }

}