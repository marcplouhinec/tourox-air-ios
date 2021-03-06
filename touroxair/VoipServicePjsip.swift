//
//  VoipServicePjsip.swift
//  touroxair
//
//  Created by Marc Plouhinec on 16/04/16.
//  Copyright © 2016 Marc Plouhinec. All rights reserved.
//

import Foundation

// Implementation of VoipService by using PJSIP (http://www.pjsip.org)
// Thanks to http://www.pjsip.org/pjsip/docs/html/page_pjsip_sample_simple_pjsuaua_c.htm
class VoipServicePjsip: VoipService {
    
    static let instance = VoipServicePjsip()
    
    var pjsuaActive = false
    var isInConference = false
    var isDestroying = false
    var currentVoipConnectionState = VoipConnectionState.NOT_CONNECTED
    var listener: (state: VoipConnectionState) -> Void = {(state: VoipConnectionState) -> Void in}
    var currentVolume: Float = 1
    
    private init() {
    }
    
    func initialize(listener: (state: VoipConnectionState) -> Void) throws {
        NSLog("Initialize the VoIP service...")
        
        self.listener = listener
        
        if pjsuaActive {
            NSLog("Internal API PJSUA already active, destroy it first...")
            closeConnection()
            destroy()
        }
        
        var status = pjsua_create()
        guard status == Int32(PJ_SUCCESS.rawValue) else {
            throw VoipServiceError.InitializationError(message: "Error when calling pjsua_create().")
        }
        
        var config = pjsua_config()
        pjsua_config_default(&config)
        config.cb.on_call_media_state = {(call_id) -> Void in
            NSLog("on_call_media_state: call_id = \(call_id)")
            
            var callInfo = pjsua_call_info()
            pjsua_call_get_info(call_id, &callInfo)
            if callInfo.media_status == PJSUA_CALL_MEDIA_ACTIVE {
                // Thanks to http://www.xianwenchen.com/blog/2014/07/15/how-to-make-an-ios-voip-app-with-pjsip-part-5/
                pjsua_conf_connect(callInfo.conf_slot, 0)
                pjsua_conf_connect(0, callInfo.conf_slot)
                
                VoipServicePjsip.instance.onCallOnGoing()
            }
        }
        config.cb.on_reg_state2 = {(acc_id, info) -> Void in
            let status = info.memory.cbparam.memory.status
            NSLog("on_reg_state: acc_id = \(acc_id), status = \(status)")
            
            if status == Int32(PJ_SUCCESS.rawValue) {
                VoipServicePjsip.instance.onRegistrationSuccess(acc_id)
            }
        }
        
        var loggingConfig = pjsua_logging_config()
        pjsua_logging_config_default(&loggingConfig)
        loggingConfig.console_level = 1
        
        status = pjsua_init(&config, &loggingConfig, nil)
        guard status == Int32(PJ_SUCCESS.rawValue) else {
            throw VoipServiceError.InitializationError(message: "Error when calling pjsua_init().")
        }
        
        var udpTransportConfig = pjsua_transport_config()
        pjsua_transport_config_default(&udpTransportConfig)
        status = pjsua_transport_create(PJSIP_TRANSPORT_UDP, &udpTransportConfig, nil)
        guard status == Int32(PJ_SUCCESS.rawValue) else {
            throw VoipServiceError.InitializationError(message: "Error when calling pjsua_transport_create().")
        }
        
        var tcpTransportConfig = pjsua_transport_config()
        pjsua_transport_config_default(&tcpTransportConfig)
        status = pjsua_transport_create(PJSIP_TRANSPORT_UDP, &tcpTransportConfig, nil)
        guard status == Int32(PJ_SUCCESS.rawValue) else {
            throw VoipServiceError.InitializationError(message: "Error when calling pjsua_transport_create().")
        }
        
        status = pjsua_start();
        guard status == Int32(PJ_SUCCESS.rawValue) else {
            throw VoipServiceError.InitializationError(message: "Error when calling pjsua_start().")
        }
        
        pjsuaActive = true
        
        NSLog("VoIP service initialized with success!")
    }
    
    func destroy() {
        NSLog("Destroy the VoIP service...")
        isDestroying = true
        
        if pjsuaActive {
            pjsua_destroy()
            pjsuaActive = false
        }
        
        isDestroying = false
        NSLog("VoIP service destroyed.")
    }
    
    func openConnection(username: String, password: String, hostname: String) throws {
        NSLog("Open a connection to '%@' with the user '%@' and password '%@'...", hostname, username, password)
        
        var accConfig = pjsua_acc_config()
        pjsua_acc_config_default(&accConfig)
        accConfig.id = pj_str(UnsafeMutablePointer<Int8>(NSString(string: "sip:\(username)@\(hostname)").UTF8String))
        accConfig.reg_uri = pj_str(UnsafeMutablePointer<Int8>(NSString(string: "sip:\(hostname)").UTF8String))
        accConfig.cred_count = 1
        accConfig.cred_info.0.realm = pj_str(UnsafeMutablePointer<Int8>(NSString(string: "*").UTF8String))
        accConfig.cred_info.0.scheme = pj_str(UnsafeMutablePointer<Int8>(NSString(string: "digest").UTF8String))
        accConfig.cred_info.0.username = pj_str(UnsafeMutablePointer<Int8>(NSString(string: username).UTF8String))
        accConfig.cred_info.0.data_type = Int32(PJSIP_CRED_DATA_PLAIN_PASSWD.rawValue)
        accConfig.cred_info.0.data = pj_str(UnsafeMutablePointer<Int8>(NSString(string: password).UTF8String))
        
        var accId = pjsua_acc_id()
        let status = pjsua_acc_add(&accConfig, Int32(PJ_TRUE.rawValue), &accId)
        guard status == Int32(PJ_SUCCESS.rawValue) else {
            throw VoipServiceError.ConnectionError(message: "Error when calling pjsua_acc_add().")
        }
        
        NSLog("Connection opened with success!")
    }
    
    func closeConnection() {
        NSLog("Close the connection...")
        
        if isInConference {
            pjsua_call_hangup_all()
            isInConference = false
            NSLog("Connection closed.")
        }
        else {
            NSLog("No connection to close.")
        }
        
        notifyVoipConnectionStateChange(VoipConnectionState.NOT_CONNECTED)
    }
    
    func getVoipConnectionState() -> VoipConnectionState {
        return currentVoipConnectionState
    }
    
    func setVolume(value: Float) {
        self.currentVolume = value
        pjsua_conf_adjust_tx_level(0, value)
    }
    
    // MARK: Handle events
    
    private func notifyVoipConnectionStateChange(state: VoipConnectionState) {
        if currentVoipConnectionState == state {
            return
        }
    
        NSLog("notifyVoipConnectionStateChange : \(state)")
        currentVoipConnectionState = state;
    
        listener(state: currentVoipConnectionState)
    }
    
    private func onRegistrationSuccess(acc_id: pjsua_acc_id) {
        if !isInConference && !isDestroying {
            var uri = pj_str(UnsafeMutablePointer<Int8>(NSString(string: "sip:2@192.168.85.1").UTF8String))
            var callSetting = pjsua_call_setting()
            pjsua_call_setting_default(&callSetting)
            let status2 = pjsua_call_make_call(acc_id, &uri, &callSetting, nil, nil, nil)
            if status2 != Int32(PJ_SUCCESS.rawValue) {
                NSLog("Unable to call sip:2@192.168.85.1.")
            }
            
            isInConference = true
        }
    }
    
    private func onCallOnGoing() {
        notifyVoipConnectionStateChange(VoipConnectionState.ONGOING_CALL)
        setVolume(currentVolume)
    }
}