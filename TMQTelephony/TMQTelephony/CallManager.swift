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
    func handleIncomingCall(_ : Call, incomingCallHandler: ((UUID)->())?) throws
    func startCall(_ : Call, startCallHandler : (@escaping (UUID)->())) throws
    func stopCall(_ : Call, stopCallHandler : (@escaping (UUID)->())) throws
}

public protocol CallManagerDelegate {
    func callConnected(call : Call)
    func callDisconnected(call : Call)
}

public class CallManager : NSObject, CallDelegate {
    fileprivate var notificationManager : NotificationManager? = nil
    
    ///Get list of outgoing calls, in reverse chronological order
    private(set) var outgoingCalls : [Call] = []
    
    ///Get list of all incoming calls, in reverse chronological order
    private(set) var  incomingCalls : [Call] = []
    
    ///Reference to the abstracted telephony framework
    private(set) var telephonyService : SystemTelephonyAdapter? = nil
    
    ///For basic call events
    public var delegate : CallManagerDelegate? = nil
    
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
            let notificationDelegateAdapter = TwilioNotificationDelegateAdapter(callManager: self)
            self.notificationManager = NotificationManager(notificationDelegate: notificationDelegateAdapter)
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
    
    
    var outgoingCall : TVOOutgoingCall? = nil
    
    //Initiates an outgoing call
    public func call(contact : Contact) throws {
        guard let notificationManager = self.notificationManager, let accessToken = TwilioAccessToken()?.fetch() else {
            return
        }
        
        //Create new call
        let call = Call(outgoing: true, uuid: UUID(), to: contact.phoneNumber)
        call.participants.append(contact)
        
        //Make it so -> 
        do {
            try telephonyService?.startCall(call, startCallHandler: { (uuid) in
                
                //TODO: Refactor to hide twilio dependent logic
                self.outgoingCall = VoiceClient.sharedInstance().call(accessToken, params: nil, delegate: notificationManager.notificationDelegate)
                self.outgoingCall?.uuid = call.uuid
                self.outgoingCalls.append(call)
                
                
            })
        } catch {
            Log.warning?.message("Unable to make call: \(call). Error: \(error).")
        }        
    }
    
    public func end(call : Call) throws {        
        do {
            try telephonyService?.stopCall(call, stopCallHandler: { (uuid) in                
                self.outgoingCall?.disconnect()
            })
        } catch {
            Log.warning?.message("Could not end call: \(call). Error: \(error).")
        }
    }
    
    //MARK: -
    //MARK: CallDelegate
    
    public func callDidConnect(_ inCall : Call){
        guard let call = self.call(with: inCall.uuid) else {
            Log.error?.message("Call with UUID \(inCall.uuid) connected, but no such call exists!")
            return
        }
        call.isActive = true
        delegate?.callConnected(call: inCall)
        
        Log.info?.message("Call \(inCall) connected.")
    }
    
    public func callDidDisconnect(_ inCall : Call){
        guard let call = self.call(with: inCall.uuid) else {
            Log.error?.message("Call with UUID \(inCall.uuid) disconnected, but no such call exists!")
            return
        }
        
        call.isActive = false
        delegate?.callDisconnected(call: inCall)
        
        Log.info?.message("Call \(inCall) disconnected.")
    }
    
    public func callCancelled(_ inCall : Call){
        guard let call = self.call(with: inCall.uuid) else {
            Log.error?.message("Call with UUID \(inCall.uuid) was cancelled, but no such call exists!")
            return
        }

        call.isActive = false
        delegate?.callDisconnected(call: inCall)
        
        Log.info?.message("Call \(inCall) cancelled.")
    }
    
    public func callReceived(_ inCall : Call){
        incomingCalls.append(inCall)
        
        do {
            try telephonyService?.handleIncomingCall(inCall,incomingCallHandler: nil)
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
