//
//  CallManager.swift
//  TMQTelephony
//
//  Created by Erik Beerepoot on 2017-02-19.
//  Copyright © 2017 Barefoot Systems. All rights reserved.
//

import Foundation

import CleanroomLogger
import TwilioVoiceClient

public class CallManager : NSObject, CallDelegate {
    fileprivate var notificationManager : NotificationManager? = nil
    
    ///Get list of outgoing calls, in reverse chronological order
    private(set) var outgoingCalls : [Call] = []
    
    ///Get list of all incoming calls, in reverse chronological order
    private(set) var  incomingCalls : [Call] = []
    
    ///Get list of all outgoing and incoming calls, in reverse chronological order
    public var calls : [Call] {
        get {
            return outgoingCalls + incomingCalls
        }
    }
    
    ///Get list of all currently active calls (not on hold)
    public var activeCalls : [Call] {
        get {
            return calls.filter { $0.isActive }
        }
    }
    
    public init(notificationManager : NotificationManager? = nil) {
        super.init()
        
        if notificationManager == nil {
            let notificationDelegateWrapper = TwilioNotificationDelegateAdapter(callManager: self)
            self.notificationManager = NotificationManager(notificationDelegate: notificationDelegateWrapper)
        } else {
            self.notificationManager = notificationManager!
        }
    }
    
    ///Get list of all outgoing and incoming calls matching `predicate`, in reverse chronological order
    public func calls(matching predicate : NSPredicate) -> [Call] {
        return []
    }
    
    public func call(with uuid : UUID) -> Call? {
        let call = calls.first(where: { (call) -> Bool in call.uuid == uuid})
        if call == nil {
            Log.error?.message("Queried for call with UUID: \(uuid), but no such call exists!")
        }
        return call
    }
    
    //Initiates an outgoing call
    public func call(contact : Contact) throws {
        //do a thing
    }
    
    //MARK: -
    //MARK: CallDelegate
    
    func callDidConnect(_ inCall : Call){
        guard let call = self.call(with: inCall.uuid) else {
            Log.error?.message("Call with UUID \(inCall.uuid) connected, but no such call exists!")
            return
        }
        call.isActive = true
    }
    
    func callDidDisconnect(_ inCall : Call){
        guard let call = self.call(with: inCall.uuid) else {
            Log.error?.message("Call with UUID \(inCall.uuid) disconnected, but no such call exists!")
            return
        }
        call.isActive = false
    }
    
    func callCancelled(_ inCall : Call){
        guard let call = self.call(with: inCall.uuid) else {
            Log.error?.message("Call with UUID \(inCall.uuid) was cancelled, but no such call exists!")
            return
        }
        call.isActive = false
    }
    
    func callReceived(_ inCall : Call){
        incomingCalls.append(inCall)
    }
    
    func call(_ inCall : Call, didFailWithError : Error){
        
    }
}
