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

///Abstract interface to hide call SDK details, as they differ for different versions of iOS
public protocol SystemTelephonyAdapter {
    func handleIncomingCall(_ : Call) throws
    func startCall(_ : Call) throws
    func stopCall(_ : Call) throws
    
}

public class CallManager : NSObject, CallDelegate {
    fileprivate var notificationManager : NotificationManager? = nil
    
    ///Get list of outgoing calls, in reverse chronological order
    private(set) var outgoingCalls : [Call] = []
    
    ///Get list of all incoming calls, in reverse chronological order
    private(set) var  incomingCalls : [Call] = []
    
    private(set) var telephonyService : SystemTelephonyAdapter? = nil
    
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
    
    public init(notificationManager : NotificationManager? = nil, telephonyService : SystemTelephonyAdapter? = nil) {
        if telephonyService != nil {
            self.telephonyService = telephonyService!
        }
        
        let os = ProcessInfo().operatingSystemVersion
        if os.majorVersion >= 10 {
            Log.debug?.message("iOS 10 or higher. Using CallKit.")
            self.telephonyService = CallKitCallController()
        } else {
            Log.debug?.message("Pre iOS 10. Falling back to old VoIP frameworks")
            fatalError("Not implemented yet")
        }
        
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
        return [] //STUB
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
    
    public func callDidConnect(_ inCall : Call){
        guard let call = self.call(with: inCall.uuid) else {
            Log.error?.message("Call with UUID \(inCall.uuid) connected, but no such call exists!")
            return
        }
                
        do {
            try telephonyService?.startCall(inCall)
            call.isActive = true
        } catch {
            Log.error?.message("Unable to start call: \(inCall). Error: \(error)")
        }
    }
    
    public func callDidDisconnect(_ inCall : Call){
        guard let call = self.call(with: inCall.uuid) else {
            Log.error?.message("Call with UUID \(inCall.uuid) disconnected, but no such call exists!")
            return
        }
        
        do {
            try telephonyService?.stopCall(inCall)
            call.isActive = false
        } catch {
            Log.error?.message("Unable to stop call: \(inCall). Error: \(error)")
        }
    }
    
    public func callCancelled(_ inCall : Call){
        guard let call = self.call(with: inCall.uuid) else {
            Log.error?.message("Call with UUID \(inCall.uuid) was cancelled, but no such call exists!")
            return
        }
        
        
        do {
            try telephonyService?.stopCall(inCall)
            call.isActive = false
        } catch {
            Log.error?.message("Unable to stop call: \(inCall). Error: \(error)")
        }

    }
    
    public func callReceived(_ inCall : Call){
        incomingCalls.append(inCall)
        
        do {
            try telephonyService?.handleIncomingCall(inCall)
        } catch {
            Log.error?.message("Unable to handle incoming call: \(inCall). Error: \(error)")
        }

    }
    
    public func call(_ inCall : Call, didFailWithError : Error){
        guard let call = self.call(with: inCall.uuid) else {
            Log.error?.message("Call with UUID \(inCall.uuid) failed, but no such call exists!")
            return
        }
        call.isActive = false
    }
}
