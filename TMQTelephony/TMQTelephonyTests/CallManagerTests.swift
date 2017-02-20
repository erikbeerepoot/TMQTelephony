//
//  TMQTelephonyTests.swift
//  TMQTelephonyTests
//
//  Created by Erik Beerepoot on 2017-02-19.
//  Copyright © 2017 Barefoot Systems. All rights reserved.
//

import XCTest
import TMQTelephony

class CallManagerTests : XCTestCase {
    
    var callManager : CallManager! = nil
    
    override func setUp() {
        super.setUp()
        
        callManager = CallManager()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCallReceived(){        
        let uuid = UUID()
        let call = Call(outgoing: false, uuid: uuid)
        callManager.callReceived(call)
        
        let foundCall = callManager.call(with: uuid)
        XCTAssertNotNil(foundCall)
        XCTAssertFalse(foundCall!.isActive)
    }
    
    func testCallConnected(){
        let uuid = UUID()
        let call = Call(outgoing: false, uuid: uuid)
        callManager.callReceived(call)
        
        let foundCall = callManager.call(with: uuid)
        XCTAssertNotNil(foundCall)
        XCTAssertFalse(foundCall!.isActive)
        
        callManager.callDidConnect(call)
        XCTAssert(foundCall!.isActive)
    }
    
    
}
