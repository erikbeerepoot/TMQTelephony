//
//  Call .swift
//  TMQTelephony
//
//  Created by Erik Beerepoot on 2017-02-19.
//  Copyright © 2017 Barefoot Systems. All rights reserved.
//

import Foundation

protocol CallDelegate {
    func callDidConnect(_ call : Call)
    func callDidDisconnect(_ call : Call)
    func callCancelled(_ call : Call)
    func callReceived(_ call : Call)
    func call(_ call : Call, didFailWithError : Error)
}

public class Call {
    ///Is this call in progress?
    public var isActive : Bool = false {
        didSet {
            if isActive == false && oldValue != false {
                endDate = Date()
            }
        }
    }
    
    ///Outbound or inbound?
    public let isOutgoing : Bool
    
    ///Contacts this call was/is with
    public var participants : [Contact] = []
    
    ///Date this call was started or received
    public let date : Date
    
    //Private: when this call was ended (for computing duration)
    fileprivate var endDate = Date()
    
    //Duration in seconds
    public var duration : TimeInterval {
        get {
            if isActive {
                return Date().timeIntervalSince(date)
            } else {
                return endDate.timeIntervalSince(date)
            }
        }
    }
 
    ///Is this call currently on hold
    public var isOnHold : Bool = false
    
    ///Unique ID for this call
    public let uuid : UUID
    
    public init(outgoing : Bool, uuid : UUID) {
        self.isOutgoing = outgoing
        self.uuid = uuid
        
        date = Date()
    }
}
