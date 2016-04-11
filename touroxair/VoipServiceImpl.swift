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
        
        // TODO https://github.com/BelledonneCommunications/linphone-iphone/blob/master/Classes/LinphoneManager.m#L1505
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
    private func lpConfigStringForKey(key: String?, inSection: String) -> NSString? {
        return self.lpConfigStringForKey(key, inSection: inSection, withDefault: nil)
    }
    
    private func lpConfigStringForKey(key: String?, inSection: String, withDefault: String?) -> NSString? {
        if key == nil {
            return withDefault
        }
        
        let value = lp_config_get_string(linphoneConfig!, NSString(string: inSection).UTF8String, NSString(string: key!).UTF8String, nil)
        if value == nil {
            return withDefault
        } else {
            return NSString(UTF8String: value)
        }
    }
    
    private func lpConfigSetString(value: String, key: String, inSection: String) {
        lp_config_set_string(linphoneConfig!, NSString(string: inSection).UTF8String, NSString(string: key).UTF8String, NSString(string: value).UTF8String);
    }
}