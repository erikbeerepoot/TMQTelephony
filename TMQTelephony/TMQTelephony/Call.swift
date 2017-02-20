//
//  Call .swift
//  TMQTelephony
//
//  Created by Erik Beerepoot on 2017-02-19.
//  Copyright © 2017 Barefoot Systems. All rights reserved.
//

import Foundation

struct Call {

    ///Is this call in progress?
    var isActive : Bool = false
    
    ///Outbound or inbound?
    let isOutgoing : Bool = false
    
    ///Contacts this call was/is with
    var participants : [Contact] = []
    
    ///Date this call was started or received
    let date : Date
    
    //Duration in seconds
    var duration : TimeInterval = 0.0
 
    ///Is this call currently on hold
    var isOnHold : Bool = false
    
    init() {
        date = Date()
    }
}
