//
//  WristcamCUK_Client.swift
//  CallbackURLKitDemo
//
//  Created by Doron Adler on 01/12/2022.
//  Copyright © 2022 Endless Technologies. All rights reserved.
//

import Foundation

/*
 Client for Wristcam app
 */
public class WristcamClient: CUK_Client {
    
    public static let DownloadURL = URL(string: "https://apps.apple.com/app/apple-store/id1110297417")
    
    public init() {
        super.init(urlScheme: "wristcam")
    }
    
    public func checkInstalled() {
        if !self.appInstalled, let url = WristcamClient.DownloadURL {
            CUK_Manager.open(url: url)
        }
    }
    
    public func open(token: String,
                     onSuccess: CUK_SuccessCallback? = nil, onFailure: CUK_FailureCallback? = nil, onCancel: CUK_CancelCallback? = nil) throws {
        
        let action = "setupPartnership"
        let parameters = ["token": token]
        
        try self.perform(action: action, parameters: parameters,
                         onSuccess: onSuccess, onFailure: onFailure, onCancel: onCancel)
    }
    
}
