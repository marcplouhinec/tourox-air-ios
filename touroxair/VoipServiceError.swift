//
//  VoipServiceError.swift
//  touroxair
//
//  Created by Marc Plouhinec on 16/04/16.
//  Copyright © 2016 Marc Plouhinec. All rights reserved.
//

enum VoipServiceError: ErrorType {
    case InitializationError(message: String)
    case ConnectionError(message: String)
}