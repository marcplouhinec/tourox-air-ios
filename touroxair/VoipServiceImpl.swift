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
// Thanks to https://github.com/BelledonneCommunications/linphone-iphone
// Thanks to http://www.sitepoint.com/using-legacy-c-apis-swift/
class VoipServiceImpl: VoipService {
    
    var linphoneCoreVTable = LinphoneCoreVTable()
    var currentVoipConnectionState = VoipConnectionState.NOT_CONNECTED
    var userData = NSObject()
    var linphoneConfig: COpaquePointer?
    var linphoneCore: COpaquePointer?
    var hostname: String?
    var isInConference = false
    var timer: NSTimer? = nil
    
    init() {
        // Initialize the LinphoneCoreVTable
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
    
    // Thanks to https://github.com/BelledonneCommunications/linphone-iphone/blob/master/Classes/LinphoneManager.m#L1475
    func initialize() {
        // Prepare the LibLinphone configuration
        let resourceLinphonercPath = bundleFile("linphonerc")
        let linphonercPath = documentFile("linphonerc")
        copyFile(resourceLinphonercPath!, dst: linphonercPath!, override: false)
        
        let resourceLinphonercFactoryPath = bundleFile("linphonerc_factory")
        linphoneConfig = lp_config_new_with_factory(NSString(string: linphonercPath!).UTF8String, NSString(string: resourceLinphonercFactoryPath!).UTF8String)
        
        let ring = NSString(string: bundleFile("notes_of_the_optimistic.caf")!).lastPathComponent
        let ringback = NSString(string: bundleFile("ringback.wav")!).lastPathComponent
        let hold = NSString(string: bundleFile("hold.mkv")!).lastPathComponent
        
        lpConfigSetString(bundleFile(ring)!, key: "local_ring", inSection: "sound")
        lpConfigSetString(bundleFile(ringback)!, key: "remote_ring", inSection: "sound")
        lpConfigSetString(bundleFile(hold)!, key: "hold_music", inSection: "sound")

        // Create the LinphoneCore object
        linphoneCore = linphone_core_new_with_config(&linphoneCoreVTable, linphoneConfig!, &userData)
    }
    
    func destroy() {
        if let currentLinphoneCore = linphoneCore {
            linphone_core_destroy(currentLinphoneCore)
        }
    }
    
    func registerVoipConnectionStateChangedListener(listener: VoipConnectionStateChangedListener) {
        // TODO
    }
    
    func openConnection(username: String, password: String, hostname: String) {
        self.hostname = hostname
        
        let authInfo = linphone_auth_info_new(NSString(string: username).UTF8String, nil, NSString(string: password).UTF8String, nil, nil, NSString(string: hostname).UTF8String)
        linphone_core_add_auth_info(linphoneCore!, authInfo)
        
        let proxyConfig = linphone_core_create_proxy_config(linphoneCore!)
        linphone_proxy_config_set_identity(proxyConfig, NSString(string: "sip:" + username + "@" + hostname).UTF8String)
        linphone_proxy_config_set_server_addr(proxyConfig, NSString(string: hostname).UTF8String)
        linphone_proxy_config_enable_register(proxyConfig, 1)
        linphone_core_add_proxy_config(linphoneCore!, proxyConfig)
        
        linphone_core_iterate(linphoneCore!);
        timer = NSTimer.scheduledTimerWithTimeInterval(0.02, target: self, selector: #selector(linphoneCoreIterate), userInfo: nil, repeats: true)
        
        linphone_core_set_network_reachable(linphoneCore!, 1)
    }
    
    @objc private func linphoneCoreIterate() {
        linphone_core_iterate(linphoneCore!);
    }
    
    func closeConnection() {
        isInConference = false;
        
        if let currentLinphoneCore = linphoneCore {
            let currentCall = linphone_core_get_current_call(currentLinphoneCore)
            if currentCall != nil {
                linphone_core_terminate_call(currentLinphoneCore, currentCall)
            }
        }
        
        if let currentTimer = timer {
            currentTimer.invalidate()
        }
        
        if let currentLinphoneCore = linphoneCore {
            linphone_core_set_network_reachable(currentLinphoneCore, 0)
        }
    }
    
    func getVoipConnectionState() -> VoipConnectionState {
        return currentVoipConnectionState
    }
    
    // Thanks to https://github.com/BelledonneCommunications/linphone-iphone/blob/master/Classes/LinphoneManager.m#L2089
    private func bundleFile(file: NSString) -> String? {
        return NSBundle.mainBundle().pathForResource(file.stringByDeletingPathExtension, ofType: file.pathExtension)
    }
    
    // Thanks to https://github.com/BelledonneCommunications/linphone-iphone/blob/master/Classes/LinphoneManager.m#L2093
    private func documentFile(file: String) -> String? {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsPath = paths.first!
        return NSString(string: documentsPath).stringByAppendingPathComponent(file)
    }
    
    // Thanks to https://github.com/BelledonneCommunications/linphone-iphone/blob/master/Classes/LinphoneManager.m#L2129
    private func copyFile(src: String, dst: String, override: Bool) -> Bool {
        let fileManager = NSFileManager.defaultManager()
        
        if !fileManager.fileExistsAtPath(src) {
            return false
        }
        if fileManager.fileExistsAtPath(dst) {
            if override {
                do {
                    try fileManager.removeItemAtPath(dst)
                } catch {
                    return false
                }
            }
            else {
                return false
            }
        }
        do {
            try fileManager.copyItemAtPath(src, toPath: dst)
        } catch {
            return false
        }
        return true
    }
    
    // Thanks to https://github.com/BelledonneCommunications/linphone-iphone/blob/master/Classes/LinphoneManager.m#L2206
    private func lpConfigSetString(value: String, key: String, inSection: String) {
        lp_config_set_string(linphoneConfig!, NSString(string: inSection).UTF8String, NSString(string: key).UTF8String, NSString(string: value).UTF8String);
    }
}