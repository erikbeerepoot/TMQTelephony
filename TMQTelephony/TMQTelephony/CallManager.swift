//
//  CallManager.swift
//  TMQTelephony
//
//  Created by Erik Beerepoot on 2017-02-19.
//  Copyright © 2017 Barefoot Systems. All rights reserved.
//

import Foundation

class CallManager {
    ///Get list of outgoing calls, in reverse chronological order
    private(set) var outgoingCalls : [Call] = []
    
    ///Get list of all incoming calls, in reverse chronological order
    private(set) var  incomingCalls : [Call] = []
    
    ///Get list of all outgoing and incoming calls, in reverse chronological order
    var calls : [Call] {
        get {
            return outgoingCalls + incomingCalls
        }
    }
    
    ///Get list of all currently active calls
    var activeCalls : [Call] {
        get {
            return calls.filter { $0.isActive }
        }
    }
    
    ///Get list of all outgoing and incoming calls matching `predicate`, in reverse chronological order
    func calls(matching predicate : NSPredicate) -> [Call] {
        return []
    }
    
    //Initiates an outgoing call
    func call(contact : Contact) throws {
        //do a thing
    }
}
