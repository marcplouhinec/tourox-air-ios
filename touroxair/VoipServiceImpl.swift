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
    
    var currentVoipConnectionState = VoipConnectionState.NOT_CONNECTED
    
    /*var linphoneCoreVTable = VoipServiceImpl.initializeLinphoneCoreVTable()
    var linphoneConfig: COpaquePointer?
    var linphoneCore: COpaquePointer?
    var hostname: String?
    var isInConference = false
    var timer: NSTimer? = nil
    var listener: (state: VoipConnectionState) -> Void = {(state: VoipConnectionState) -> Void in}*/
 
    // Thanks to https://github.com/BelledonneCommunications/linphone-iphone/blob/master/Classes/LinphoneManager.m#L1475
    func initialize(listener: (state: VoipConnectionState) -> Void) throws {
        /*NSLog("Initialize the VoIP service...")
        
        self.listener = listener

        // Prepare the LibLinphone configuration
        let resourceLinphonercPath = bundleFile("linphonerc")
        let linphonercPath = documentFile("linphonerc")
        copyFile(resourceLinphonercPath!, dst: linphonercPath!, override: true)
        
        let resourceLinphonercFactoryPath = bundleFile("linphonerc_factory")
        linphoneConfig = lp_config_new_with_factory(NSString(string: linphonercPath!).UTF8String, NSString(string: resourceLinphonercFactoryPath!).UTF8String)
        
        let ring = NSString(string: bundleFile("notes_of_the_optimistic.caf")!).lastPathComponent
        let ringback = NSString(string: bundleFile("ringback.wav")!).lastPathComponent
        let hold = NSString(string: bundleFile("hold.mkv")!).lastPathComponent
        
        lpConfigSetString(bundleFile(ring)!, key: "local_ring", inSection: "sound")
        lpConfigSetString(bundleFile(ringback)!, key: "remote_ring", inSection: "sound")
        lpConfigSetString(bundleFile(hold)!, key: "hold_music", inSection: "sound")

        // Create the LinphoneCore object
        let pointerToSelf = VoipServiceImpl.bridge(self)
        linphoneCore = linphone_core_new_with_config(&linphoneCoreVTable, linphoneConfig!, pointerToSelf)
        linphone_core_set_user_agent(linphoneCore!, NSString(string: "Tourox").UTF8String, NSString(string: "1.0").UTF8String)
        
        let dumpedConfig = lp_config_dump_as_xml(linphoneConfig!)
        let test = NSString(UTF8String: dumpedConfig)
        print(test)
        
        NSLog("VoIP service initialized with success!")*/
    }
    
    func destroy() {
        /*NSLog("Destroy the VoIP service...")
        
        if let currentLinphoneCore = linphoneCore {
            linphone_core_destroy(currentLinphoneCore)
            NSLog("VoIP service destroyed with success!")
        }
        else {
            NSLog("Nothing to destroy.")
        }*/
    }
    
    func openConnection(username: String, password: String, hostname: String) throws {
        /*NSLog("Open a connection to '%@' with the user '%@' and password '%@'...", hostname, username, password)
        
        self.hostname = hostname
        
        let authInfo = linphone_auth_info_new(NSString(string: username).UTF8String, nil, NSString(string: password).UTF8String, nil, nil, NSString(string: hostname).UTF8String)
        linphone_core_add_auth_info(linphoneCore!, authInfo)
        
        let proxyConfig = linphone_core_create_proxy_config(linphoneCore!)
        linphone_proxy_config_set_identity(proxyConfig, NSString(string: "sip:\(username)@\(hostname)").UTF8String)
        linphone_proxy_config_set_server_addr(proxyConfig, NSString(string: hostname).UTF8String)
        linphone_proxy_config_enable_register(proxyConfig, 1)
        linphone_core_add_proxy_config(linphoneCore!, proxyConfig)
        linphone_core_set_network_reachable(linphoneCore!, 1)
        
        linphoneCoreIterate()
        timer = NSTimer.scheduledTimerWithTimeInterval(0.02, target: self, selector: #selector(VoipServiceImpl.linphoneCoreIterate), userInfo: nil, repeats: true)
        
        linphone_core_refresh_registers(linphoneCore!)
        
        /*dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            NSLog("Start kick off network connection...")
            var unmanagedWriteStream : Unmanaged<CFWriteStream>?
            CFStreamCreatePairWithSocketToHost(nil, "192.168.85.1", 5060, nil, &unmanagedWriteStream)
            let writeStream = unmanagedWriteStream!.takeRetainedValue()
            let res = CFWriteStreamOpen(writeStream)
            if !res {
                NSLog("Error: could not open write stream!")
                return
            }
            
            // Check stream status and handle timeout
            var timeoutReached = false
            let startTime = time(nil)
            var loopTime : time_t = 0
            var status = CFWriteStreamGetStatus(writeStream)
            NSLog("status: \(status.rawValue)")
            while (status != .Open && status != .Error) {
                sleep(1)
                status = CFWriteStreamGetStatus(writeStream)
                NSLog("status: \(status.rawValue)")
                loopTime = time(nil)
                if loopTime - startTime >= 5 {
                    timeoutReached = true
                    break
                }
            }
            
            if status == .Open {
                let buff = [UInt8]("hello".utf8)
                CFWriteStreamWrite(writeStream, buff, buff.count)
            }
            else if !timeoutReached {
                let error = CFWriteStreamCopyError(writeStream)
                NSLog("CFStreamError: \(error)")
            }
            else if timeoutReached {
                NSLog("CFStream timeout reached")
            }
            CFWriteStreamClose(writeStream);
            
            NSLog("End kick off network connection.")
        })*/
        
        NSLog("Connection opened with success!")*/
    }
    
    /*@objc private func linphoneCoreIterate() {
        linphone_core_iterate(linphoneCore!);
    }*/
    
    func closeConnection() {
        /*NSLog("Close the connection...")
        
        isInConference = false;
        
        if let currentLinphoneCore = linphoneCore {
            let currentCall = linphone_core_get_current_call(currentLinphoneCore)
            if currentCall != nil {
                linphone_core_terminate_call(currentLinphoneCore, currentCall)
                NSLog("Current call terminated.")
            }
            else {
                NSLog("No call to terminate.")
            }
        }
        
        if let currentTimer = timer {
            currentTimer.invalidate()
        }
        
        if let currentLinphoneCore = linphoneCore {
            linphone_core_set_network_reachable(currentLinphoneCore, 0)
            NSLog("Connection closed.")
        }
        else {
            NSLog("No connection to close.")
        }
        
        notifyVoipConnectionStateChange(.NOT_CONNECTED)*/
    }
    
    // MARK: Events and states
    
    func getVoipConnectionState() -> VoipConnectionState {
        return currentVoipConnectionState
    }
    /*
    private func notifyVoipConnectionStateChange(state: VoipConnectionState) {
        if currentVoipConnectionState == state {
            return
        }
        
        NSLog("notifyVoipConnectionStateChange: \(state)")
        currentVoipConnectionState = state
        
        listener(state: currentVoipConnectionState)
    }
    
    // Initialize the LinphoneCoreVTable that is used for handling events
    private static func initializeLinphoneCoreVTable() -> LinphoneCoreVTable {
        var linphoneCoreVTable = LinphoneCoreVTable()
        
        linphoneCoreVTable.call_state_changed = { (lc, call, state, message) -> Void in
            let messageAsString = message == nil ? "" : NSString(UTF8String: message)!
            NSLog("call_state_changed: state = \(state), message = \(messageAsString)")
            
            if state == LinphoneCallConnected {
                let pointerToSelf = linphone_core_get_user_data(lc)
                let mySelf : VoipServiceImpl = VoipServiceImpl.bridge(pointerToSelf)

                mySelf.notifyVoipConnectionStateChange(.ONGOING_CALL)
            }
        }
        linphoneCoreVTable.registration_state_changed = { (lc, cfg, state, message) -> Void in
            let messageAsString = message == nil ? "" : NSString(UTF8String: message)!
            NSLog("registration_state_changed: state = \(state), message = \(messageAsString)")
            
            if state == LinphoneRegistrationOk {
                let pointerToSelf = linphone_core_get_user_data(lc)
                let mySelf : VoipServiceImpl = VoipServiceImpl.bridge(pointerToSelf)
                
                if !mySelf.isInConference {
                    linphone_core_invite(lc, NSString(string: "sip:2@\(mySelf.hostname!)").UTF8String)
                    mySelf.isInConference = true
                }
            }
        }
        linphoneCoreVTable.notify_presence_received = nil
        linphoneCoreVTable.new_subscription_requested = nil
        linphoneCoreVTable.auth_info_requested = { (lc, realm, username, domain) -> Void in
            let realmAsString = realm == nil ? "" : NSString(UTF8String: realm)!
            let usernameAsString = username == nil ? "" : NSString(UTF8String: username)!
            let domainAsString = domain == nil ? "" : NSString(UTF8String: domain)!
            NSLog("auth_info_requested: realm = \(realmAsString), username = \(usernameAsString), domain = \(domainAsString)")
        }
        linphoneCoreVTable.message_received = nil
        linphoneCoreVTable.dtmf_received = nil
        linphoneCoreVTable.transfer_state_changed = nil
        linphoneCoreVTable.is_composing_received = nil
        linphoneCoreVTable.configuring_status = {(lc, status, message) -> Void in
            let messageAsString = message == nil ? "" : NSString(UTF8String: message)!
            NSLog("configuring_status: state = \(status), message = \(messageAsString)")
        }
        linphoneCoreVTable.global_state_changed = {(lc, state, message) -> Void in
            let messageAsString = message == nil ? "" : NSString(UTF8String: message)!
            NSLog("global_state_changed: state = \(state), message = \(messageAsString)")
        }
        linphoneCoreVTable.notify_received = nil
        linphoneCoreVTable.call_encryption_changed = nil
        linphoneCoreVTable.display_message = {(lc, message) -> Void in
            let messageAsString = message == nil ? "" : NSString(UTF8String: message)!
            NSLog("display_message: message = \(messageAsString)")
        }
        linphoneCoreVTable.display_warning = {(lc, message) -> Void in
            let messageAsString = message == nil ? "" : NSString(UTF8String: message)!
            NSLog("display_warning: message = \(messageAsString)")
        }
        linphoneCoreVTable.display_status = {(lc, message) -> Void in
            let messageAsString = message == nil ? "" : NSString(UTF8String: message)!
            NSLog("display_status: message = \(messageAsString)")
        }
        
        return linphoneCoreVTable
    }
    
    // MARK: Internal methods specific for LibLinphone
    
    // Thanks to https://github.com/BelledonneCommunications/linphone-iphone/blob/master/Classes/LinphoneManager.m#L2089
    private func bundleFile(file: NSString) -> String? {
        let result = NSBundle.mainBundle().pathForResource(file.stringByDeletingPathExtension, ofType: file.pathExtension)
        NSLog("bundleFile(\(file)) -> \(result)")
        return result
    }
    
    // Thanks to https://github.com/BelledonneCommunications/linphone-iphone/blob/master/Classes/LinphoneManager.m#L2093
    private func documentFile(file: String) -> String? {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsPath = paths.first!
        let result = NSString(string: documentsPath).stringByAppendingPathComponent(file)
        NSLog("documentFile(\(file)) -> \(result)")
        return result
    }
    
    // Thanks to https://github.com/BelledonneCommunications/linphone-iphone/blob/master/Classes/LinphoneManager.m#L2129
    private func copyFile(src: String, dst: String, override: Bool) -> Bool {
        NSLog("copyFile(src: \(src), dst: \(dst), override: \(override))")
        let fileManager = NSFileManager.defaultManager()
        
        if !fileManager.fileExistsAtPath(src) {
            NSLog("Error: the file '\(src)' doesnt exist.")
            return false
        }
        if fileManager.fileExistsAtPath(dst) {
            NSLog("The destination file '\(dst)' already exist.")
            if override {
                do {
                    try fileManager.removeItemAtPath(dst)
                    NSLog("Existing destination file '\(dst)' deleted.")
                } catch {
                    NSLog("Error: the destination file '\(dst)' cannot be deleted.")
                    return false
                }
            }
            else {
                NSLog("The destination file '\(dst)' already exist and is left untouched.")
                return false
            }
        }
        do {
            try fileManager.copyItemAtPath(src, toPath: dst)
        } catch {
            NSLog("Error: the file '\(src)' cannot be copied to \(dst).")
            return false
        }
        NSLog("The file '\(src)' has been successfully copied to \(dst).")
        return true
    }
    
    // Thanks to https://github.com/BelledonneCommunications/linphone-iphone/blob/master/Classes/LinphoneManager.m#L2206
    private func lpConfigSetString(value: String, key: String, inSection: String) {
        lp_config_set_string(linphoneConfig!, NSString(string: inSection).UTF8String, NSString(string: key).UTF8String, NSString(string: value).UTF8String);
    }
    
    // MARK: C compatibility helpers
    
    // Thanks to http://stackoverflow.com/a/33310021
    private static func bridge<T : AnyObject>(obj : T) -> UnsafeMutablePointer<Void> {
        return UnsafeMutablePointer(Unmanaged.passUnretained(obj).toOpaque())
    }
    
    // Thanks to http://stackoverflow.com/a/33310021
    private static func bridge<T : AnyObject>(ptr : UnsafeMutablePointer<Void>) -> T {
        return Unmanaged<T>.fromOpaque(COpaquePointer(ptr)).takeUnretainedValue()
    }*/
}