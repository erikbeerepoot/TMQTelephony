//
//  TwilioNotificationDelegateWrapper.swift
//  TMQTelephony
//
//  Created by Erik Beerepoot on 2017-02-19.
//  Copyright © 2017 Barefoot Systems. All rights reserved.
//

import Foundation

import CleanroomLogger
import TwilioVoiceClient

///Class that adapts the twilio notification interface to our own 
///Keeps our own internal api stable, allows us to swap out underlying implementation
class TwilioNotificationDelegateAdapter : NSObject, TVONotificationDelegate {
    //Dont hold a strong reference to callmanager. If it doesn't exist, we dont need to either
    weak var callManager : CallManager?
    
    init(callManager : CallManager){
        self.callManager = callManager
    }
    
    //MARK: -
    //MARK: TVONotificationDelegate
    //MARK: -
    //MARK: Incoming calls
    public func incomingCallReceived(_ incomingCall: TVOIncomingCall) {
        let call = Call(outgoing: false, uuid : incomingCall.uuid, to : incomingCall.to)        
        let contact = Contact(phoneNumber:incomingCall.from)
        call.participants.append(contact)
        
        callManager?.callReceived(call)
    }
    
    public func incomingCallCancelled(_ incomingCall: TVOIncomingCall?) {
        if let incomingCall = incomingCall, let call = callManager?.call(with: incomingCall.uuid) {
            callManager?.callCancelled(call)
        }
    }
    
    public func incomingCallDidConnect(_ incomingCall: TVOIncomingCall) {
        if let call = callManager?.call(with: incomingCall.uuid) {
            callManager?.callDidConnect(call)
        }
    }
    
    public func incomingCallDidDisconnect(_ incomingCall: TVOIncomingCall) {
        if let call = callManager?.call(with: incomingCall.uuid) {
            callManager?.callDidDisconnect(call)
        }
    }
    
    public func incomingCall(_ incomingCall: TVOIncomingCall, didFailWithError error: Error) {
        if let call = callManager?.call(with: incomingCall.uuid) {
            callManager?.call(call, didFailWithError: error)
        }
    }
    
    //MARK: -
    //MARK: Outgoing calls
    public func outgoingCallDidConnect(_ outgoingCall: TVOOutgoingCall) {
        //Query callmanager for a call, create if it doesn't exist
        var call = callManager?.call(with: outgoingCall.uuid)
        if call == nil {
            call = Call(outgoing: true, uuid : outgoingCall.uuid)
        }
        
        //we definitely have a call here -> force unwrap is safe
        callManager?.callDidConnect(call!)
    }
    
    public func outgoingCallDidDisconnect(_ outgoingCall: TVOOutgoingCall) {
        if let call = callManager?.call(with: outgoingCall.uuid) {
            callManager?.callDidConnect(call)
        }
    }
    
    public func outgoingCall(_ outgoingCall: TVOOutgoingCall, didFailWithError error: Error) {
        if let call = callManager?.call(with: outgoingCall.uuid) {
            callManager?.call(call, didFailWithError: error)
        }
    }
    
    public func notificationError(_ error: Error) {
        Log.error?.message("Received error from Twilio: \(error.localizedDescription)")
    }
    
    
}
