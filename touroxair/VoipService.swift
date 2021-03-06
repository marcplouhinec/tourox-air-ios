//
//  VoipService.swift
//  touroxair
//
//  Created by Marc Plouhinec on 09/04/16.
//  Copyright © 2016 Marc Plouhinec. All rights reserved.
//

import Foundation

// Handle communication with the VoIP router.
protocol VoipService {
    
    // Initialize the internal SIP library. This method must be called first!
    func initialize(listener: (state: VoipConnectionState) -> Void) throws
    
    // Destroy the SIP library resources.
    func destroy()
    
    // Open a connection with the VoIP router.
    func openConnection(username: String, password: String, hostname: String) throws
    
    // Close the connection with the router.
    func closeConnection()

    // Return the current connection state
    func getVoipConnectionState() -> VoipConnectionState
    
    // Set the audio volume (0 = muted, 1 = max)
    func setVolume(value: Float)
}