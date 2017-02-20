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
    var isActive : Bool = false {
        didSet {
            if !isActive {
                endDate = Date()
            }
        }
    }
    
    ///Outbound or inbound?
    let isOutgoing : Bool
    
    ///Contacts this call was/is with
    var participants : [Contact] = []
    
    ///Date this call was started or received
    let date : Date
    private var endDate = Date()
    
    //Duration in seconds
    var duration : TimeInterval {
        get {
            if isActive {
                return date.timeIntervalSinceNow
            } else {
                return endDate.timeIntervalSince(date)
            }
        }
    }
 
    ///Is this call currently on hold
    var isOnHold : Bool = false
    
    ///Unique ID for this call
    let uuid : UUID 
    
    init(outgoing : Bool, uuid : UUID) {
        self.isOutgoing = outgoing
        self.uuid = uuid
        
        date = Date()
    }
}
