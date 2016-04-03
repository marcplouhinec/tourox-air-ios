//
//  VoipConnectionState.swift
//  touroxair
//
//  Created by Marc Plouhinec on 03/04/16.
//  Copyright © 2016 Marc Plouhinec. All rights reserved.
//

import Foundation

enum VoipConnectionState {
    case NOT_CONNECTED, UNABLE_TO_CONNECT, CONNECTED_WAITING_FOR_CALL, ONGOING_CALL
}