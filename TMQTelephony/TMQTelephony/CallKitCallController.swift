//
//  CallKitWrapper.swift
//  TMQTelephony
//
//  Created by Erik Beerepoot on 2017-02-26.
//  Copyright © 2017 Barefoot Systems. All rights reserved.
//

import AVFoundation
import Foundation
import CallKit
import CleanroomLogger

import TwilioVoiceClient

class CallKitCallControllerAdapter : NSObject, SystemTelephonyAdapter, CXProviderDelegate {
    struct LocalConstants {
            static let LocalizedProviderName = "TMQTelephonyCallProvider"
    }
    
    enum CallControllerError : Error {
        case NoParticipantsInCall
        case InvalidSourceMetadata
    }
    
    let callController : CXCallController
    let callProvider : CXProvider
    
    //DI for testing
    init(callKitController : CXCallController? = nil, callKitProvider : CXProvider? = nil) {
        
        
        if callKitProvider == nil {
            //Configure a bare bones calling provider
            let providerConfiguration = CXProviderConfiguration(localizedName: LocalConstants.LocalizedProviderName)
            providerConfiguration.maximumCallGroups = 1
            providerConfiguration.maximumCallsPerCallGroup = 1
            providerConfiguration.supportsVideo = false
            providerConfiguration.supportedHandleTypes = [.generic,.phoneNumber]
            self.callProvider = CXProvider(configuration: providerConfiguration)
            
        } else {
            callProvider = callKitProvider!
        }
        
        
        if callKitController == nil {
            self.callController = CXCallController()
        } else {
            self.callController = callKitController!
        }
        
        super.init()
        
        callKitProvider?.setDelegate(self, queue: nil)
    }
    
    // MARK: -
    // MARK: SystemTelephonyAdapter
    func handleIncomingCall(_ call : Call) throws {
        //Start a call with the first participant
        guard let from = call.participants.first else {
            Log.error?.message("Received a call without an originating contact!")
            throw CallControllerError.NoParticipantsInCall
        }
        
        if from.phoneNumber == nil && from.email == nil {
            Log.error?.message("Both phone number and email are missing in source contact metadata!")
            throw CallControllerError.InvalidSourceMetadata
        }
        
        //At this point, force unwrap is safe, since we must have one or the other
        reportIncomingCall(from: from.phoneNumber ?? from.email! , uuid: call.uuid)
    }
    
    func startCall(_ call : Call) throws {
        
    }
    
    func stopCall(_ call : Call) throws {
        
    }
    
    
    // MARK: -
    // MARK: Call Kit Actions
    func reportIncomingCall(from: String, uuid: UUID) {
        let callHandle = CXHandle(type: .generic, value: from)
        
        let callUpdate = CXCallUpdate()
        callUpdate.remoteHandle = callHandle
        callUpdate.supportsDTMF = true
        callUpdate.supportsHolding = false
        callUpdate.supportsGrouping = false
        callUpdate.supportsUngrouping = false
        callUpdate.hasVideo = false
        
        callProvider.reportNewIncomingCall(with: uuid, update: callUpdate) { error in
            Log.info?.message("Received incoming call: \(uuid)")
            if let error = error {
                Log.error?.message("Failed to report incoming call. Error: \(error)")
                return
            }
            
            // RCP: Workaround per https://forums.developer.apple.com/message/169511
            VoiceClient.sharedInstance().configureAudioSession()
        }
    }

    
    func performStartCallAction(uuid: UUID, handle: String) {
        let callHandle = CXHandle(type: .generic, value: handle)
        let startCallAction = CXStartCallAction(call: uuid, handle: callHandle)
        let transaction = CXTransaction(action: startCallAction)
        
        callController.request(transaction)  { error in
            if let error = error {
                Log.error?.message("StartCallAction transaction failed: \(error)")
                return
            }
            Log.error?.message("StartCallAction transaction succeeded: \(error)")
            
            let callUpdate = CXCallUpdate()
            callUpdate.remoteHandle = callHandle
            callUpdate.supportsDTMF = true
            callUpdate.supportsHolding = false
            callUpdate.supportsGrouping = false
            callUpdate.supportsUngrouping = false
            callUpdate.hasVideo = false
            
            self.callProvider.reportCall(with: uuid, updated: callUpdate)
        }
    }
    
    
    func performEndCallAction(uuid: UUID) {
        
        let endCallAction = CXEndCallAction(call: uuid)
        let transaction = CXTransaction(action: endCallAction)
        
        callController.request(transaction) { error in
            if let error = error {
                Log.error?.message("EndCallAction transaction failed: \(error).")
                return
            }
            Log.error?.message("EndCallAction transaction succeeded")
        }
    }
    
    //MARK: -
    //MARK: CXProviderDelegate
    
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        
        
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
    }
    
    func provider(_ provider: CXProvider, timedOutPerforming action: CXAction) {
    }
    
    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
    }
    
    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
    }
    
    func providerDidBegin(_ provider: CXProvider) {
    }
    
    func providerDidReset(_ provider: CXProvider) {
    }
    
    //MARK: - 
    //MARK: Audio Handling
    func configureAudioSession(){
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategorySoloAmbient)
        } catch {
            Log.error?.message("Unable to configure audio session for call.")
        }
    }
    
}
