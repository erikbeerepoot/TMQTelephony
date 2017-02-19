//
//  Notifications.swift
//  TMQTelephony
//
//  Created by Erik Beerepoot on 2017-02-19.
//  Copyright © 2017 Barefoot Systems. All rights reserved.
//

import Dispatch
import Foundation
import PushKit

import CleanroomLogger

class NotificationManager : NSObject, PKPushRegistryDelegate {
    var voipRegistry : PKPushRegistry? = nil
    
    func registerForNotifications(){
        voipRegistry = PKPushRegistry(queue: DispatchQueue.main)
        voipRegistry!.delegate = self
        voipRegistry!.desiredPushTypes = [.voIP]
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenForType type: PKPushType) {
        //current push token is now invalid
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials:    PKPushCredentials, forType type: PKPushType) {
        //handle updated creds
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, forType type: PKPushType) {
        guard type == .voIP else {
            return
        }
        Log.info?.message("Received incoming VoIP push.")
        
    }
    
}
