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
import TwilioVoiceClient

class NotificationManager : NSObject, PKPushRegistryDelegate {
    let accessToken = TwilioAccessToken()
    let voipRegistry : PKPushRegistry
    
    var deviceToken : String? = nil
    
    override init() {
        voipRegistry = PKPushRegistry(queue: DispatchQueue.main)
        
        super.init()
        
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = [.voIP]
    }
    
    //MARK: -
    //MARK: PKPushRegistryDelegate 
    
    
    ///current push token is now invalid, deregister
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenForType type: PKPushType) {
        guard type == .voIP else {
            return
        }
        
        guard let accessToken = accessToken?.fetch() else {
            Log.error?.message("Could not de-register with Twilio due to missing access token!")
            return
        }
        
        guard let deviceToken = deviceToken else {
            Log.error?.message("Could not de-register with Twilio due to missing device token!")
            return
        }
        
        VoiceClient.sharedInstance().unregister(withAccessToken: accessToken, deviceToken: deviceToken) { (error) in
            
            guard error == nil else {
                Log.error?.message("Encountered an error in de-registering with Twilio. Error: \(error)")
                return
            }
            Log.info?.message("Successfully de-registered with Twilio.")
            self.deviceToken = nil
        }
    }
    
    ///Updated creds, re-register with server
    func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials:    PKPushCredentials, forType type: PKPushType) {
        guard type == .voIP else {
            return
        }
        
        guard let accessToken = accessToken?.fetch() else {
            Log.error?.message("Could not re-register with Twilio due to missing access token")
            return
        }
        
        let deviceToken = extract(deviceToken: credentials.token)
        self.deviceToken = deviceToken
        
        VoiceClient.sharedInstance().register(withAccessToken: accessToken, deviceToken: deviceToken) { (error) in
            
            guard error == nil else {
                Log.error?.message("Encountered an error in registering with Twilio. Error: \(error)")
                return
            }
            Log.info?.message("Successfully registered with Twilio.")
        }
    }
    
    ///Handle an incoming VoIP push notification
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, forType type: PKPushType) {
        guard type == .voIP else {
            return
        }
        Log.info?.message("Received incoming VoIP push.")
    }
    
    //MARK: -
    //MARK: Helper methods
    
    ///Extracts the device token from Data respresenting the notification payload
    func extract(deviceToken from : Data) -> String {
        let token = from.reduce("", {$0 + String(format: "%02X", $1)})
        return token.uppercased();
    }
    
}
