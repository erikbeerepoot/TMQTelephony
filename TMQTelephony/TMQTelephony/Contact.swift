//
//  Contact.swift
//  TMQTelephony
//
//  Created by Erik Beerepoot on 2017-02-19.
//  Copyright © 2017 Barefoot Systems. All rights reserved.
//

import Foundation

public struct Contact {
    //First name of this contact
    public let firstName : String?
    
    //Last name of this contact
    public let lastName : String?
    
    ///Email of this contact
    public let email : String?
    
    ///Phone number of this contact
    public let phoneNumber : String?
    
    ///Have we blocked this person?
    public let isBlocked : Bool?
    
    public init(firstName : String? = nil, lastName : String? = nil, email : String? = nil, phoneNumber : String? = nil, isBlocked : Bool? = false){
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phoneNumber = phoneNumber
        self.isBlocked = isBlocked
    }
    
    
}
