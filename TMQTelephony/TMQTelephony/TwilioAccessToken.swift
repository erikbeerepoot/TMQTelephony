//
//  TwilioAccessToken.swift
//  TMQTelephony
//
//  Created by Erik Beerepoot on 2017-02-19.
//  Copyright © 2017 Barefoot Systems. All rights reserved.
//

import Foundation
import CleanroomLogger

class TwilioAccessToken {
    struct Constants {
        static let AccessTokenURL = URL(string: "https://lit-wave-83454.herokuapp.com/")!
    }
    
    let accessTokenURL : URL
    
    public var token : String? = nil
    
    init?(accessTokenURL : URL? = nil) {
        //We can inject a custom refresh url
        if let url = accessTokenURL {
            self.accessTokenURL = url
        } else {
            //or use the default one 
            self.accessTokenURL = Constants.AccessTokenURL
        }
    }
    
    //fetches thte current access token
    public func fetch() -> String? {
        do {
            token = try String(contentsOf: accessTokenURL, encoding: .utf8)
        } catch {
            Log.error?.message("Unable to refresh access token! \(error)")
            token = nil
        }
        return token
    }
    
}
