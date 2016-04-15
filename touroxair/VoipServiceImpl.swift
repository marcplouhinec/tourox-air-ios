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
    var linphoneConfig: COpaquePointer?
    var linphoneCore: COpaquePointer?
    var hostname: String?
    var isInConference = false
    var timer: NSTimer? = nil
    var listener: (state: VoipConnectionState) -> Void = {(state: VoipConnectionState) -> Void in}
    var thisService : VoipServiceImpl?
    
    // Thanks to https://github.com/BelledonneCommunications/linphone-iphone/blob/master/Classes/LinphoneManager.m#L1475
    func initialize(listener: (state: VoipConnectionState) -> Void) {
        self.listener = listener
        
        // Initialize the LinphoneCoreVTable
        linphoneCoreVTable.call_state_changed = { (lc, call, state, message) -> Void in
            let messageAsString = message == nil ? "" : NSString(UTF8String: message)!
            print("call_state_changed: state = \(state), message = \(messageAsString)")
            
            if state.rawValue == LinphoneCallConnected.rawValue {
                let thisServicePointer = linphone_core_get_user_data(lc);
                print(thisServicePointer)
                //let thisService = thisServicePointer.memory as! VoipServiceImpl
                //thisService.notifyVoipConnectionStateChange(.ONGOING_CALL)
            }
        }
        linphoneCoreVTable.registration_state_changed = { (lc, cfg, state, message) -> Void in
            let messageAsString = message == nil ? "" : NSString(UTF8String: message)!
            print("registration_state_changed: state = \(state), message = \(messageAsString)")
            
        }
        linphoneCoreVTable.notify_presence_received = nil
        linphoneCoreVTable.new_subscription_requested = nil
        linphoneCoreVTable.auth_info_requested = { (lc, realm, username, domain) -> Void in
            let realmAsString = realm == nil ? "" : NSString(UTF8String: realm)!
            let usernameAsString = username == nil ? "" : NSString(UTF8String: username)!
            let domainAsString = domain == nil ? "" : NSString(UTF8String: domain)!
            print("auth_info_requested: realm = \(realmAsString), username = \(usernameAsString), domain = \(domainAsString)")
        }
        linphoneCoreVTable.message_received = nil
        linphoneCoreVTable.dtmf_received = nil
        linphoneCoreVTable.transfer_state_changed = nil
        linphoneCoreVTable.is_composing_received = nil
        linphoneCoreVTable.configuring_status = {(lc, status, message) -> Void in
            let messageAsString = message == nil ? "" : NSString(UTF8String: message)!
            print("configuring_status: state = \(status), message = \(messageAsString)")
        }
        linphoneCoreVTable.global_state_changed = {(lc, state, message) -> Void in
            let messageAsString = message == nil ? "" : NSString(UTF8String: message)!
            print("global_state_changed: state = \(state), message = \(messageAsString)")
        }
        linphoneCoreVTable.notify_received = nil
        linphoneCoreVTable.call_encryption_changed = nil

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
        thisService = self;
        linphoneCore = linphone_core_new_with_config(&linphoneCoreVTable, linphoneConfig!, &thisService)
    }
    
    func destroy() {
        if let currentLinphoneCore = linphoneCore {
            linphone_core_destroy(currentLinphoneCore)
        }
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
        
        notifyVoipConnectionStateChange(.NOT_CONNECTED)
    }
    
    func getVoipConnectionState() -> VoipConnectionState {
        return currentVoipConnectionState
    }
    
    private func notifyVoipConnectionStateChange(state: VoipConnectionState) {
        if currentVoipConnectionState == state {
            return
        }
        
        currentVoipConnectionState = state
        
        listener(state: currentVoipConnectionState)
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