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
// Thanks to http://stackoverflow.com/questions/3562991/uibackgroundmodes-key-not-showing-in-info-plist-dropdown
// Thanks to https://github.com/BelledonneCommunications/linphone-iphone
// Thanks to http://www.sitepoint.com/using-legacy-c-apis-swift/
class VoipServiceImpl: VoipService {
    
    var linphoneCoreVTable = LinphoneCoreVTable()
    var currentVoipConnectionState = VoipConnectionState.NOT_CONNECTED
    var userData = NSObject()
    
    init() {
        linphoneCoreVTable.call_state_changed = { (lc, call, state, message) -> Void in
            print("TODO call_state_changed")
        }
        linphoneCoreVTable.registration_state_changed = { (lc, cfg, state, message) -> Void in
            print("TODO registration_state_changed")
        }
        linphoneCoreVTable.notify_presence_received = nil
        linphoneCoreVTable.new_subscription_requested = nil
        linphoneCoreVTable.auth_info_requested = { (lc, realm, username, domain) -> Void in
            print("TODO auth_info_requested")
        }
        linphoneCoreVTable.message_received = nil
        linphoneCoreVTable.dtmf_received = nil
        linphoneCoreVTable.transfer_state_changed = nil
        linphoneCoreVTable.is_composing_received = nil
        linphoneCoreVTable.configuring_status = {(lc, status, message) -> Void in
            print("TODO configuring_status")
        }
        linphoneCoreVTable.global_state_changed = {(lc, state, message) -> Void in
            print("TODO global_state_changed")
        }
        linphoneCoreVTable.notify_received = nil
        linphoneCoreVTable.call_encryption_changed = nil
    }
    
    func initialize() {
        let config: COpaquePointer = nil //TODO lp_config_new_with_factory(<#T##UnsafePointer<Int8>#>, <#T##UnsafePointer<Int8>#>)
        linphone_core_new_with_config(&linphoneCoreVTable, config, &userData)
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