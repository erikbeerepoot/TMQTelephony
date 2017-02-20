//
//  TMQTelephonyTests.swift
//  TMQTelephonyTests
//
//  Created by Erik Beerepoot on 2017-02-19.
//  Copyright © 2017 Barefoot Systems. All rights reserved.
//

import XCTest
import TMQTelephony

enum MockError : Error {
    case fake
}

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
    
    //Expect call to exist, but isActive to be false
    func testCallReceived(){
        let uuid = UUID()
        let call = Call(outgoing: false, uuid: uuid)
        callManager.callReceived(call)
        
        let foundCall = callManager.call(with: uuid)
        XCTAssertNotNil(foundCall)
        XCTAssertFalse(foundCall!.isActive)
    }
    
    //Expect isActive to go from false to true
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
    
    //Expect isActive to go from true to false
    func testCallDisconnected(){
        let uuid = UUID()
        let call = Call(outgoing: false, uuid: uuid)
        callManager.callReceived(call)
        
        let foundCall = callManager.call(with: uuid)
        XCTAssertNotNil(foundCall)
        XCTAssertFalse(foundCall!.isActive)
        
        callManager.callDidConnect(call)
        XCTAssert(foundCall!.isActive)
        
        callManager.callDidDisconnect(call)
        XCTAssertFalse(foundCall!.isActive)
    }
    
    //Expect duration to increase
    func testCallDuration(){
        let uuid = UUID()
        let call = Call(outgoing: false, uuid: uuid)
        callManager.callReceived(call)
        
        let foundCall = callManager.call(with: uuid)
        XCTAssertNotNil(foundCall)
        XCTAssertFalse(foundCall!.isActive)
        
        callManager.callDidConnect(call)
        XCTAssert(foundCall!.isActive)
        
        sleep(1)
        
        //Should be almost 1
        XCTAssertGreaterThanOrEqual(call.duration, 1)
        XCTAssertLessThan(call.duration, 1.2)
        
        callManager.callDidDisconnect(call)
        XCTAssertFalse(foundCall!.isActive)
        
        sleep(1)
        
        //Should still be almost 1
        XCTAssertGreaterThanOrEqual(call.duration, 1)
        XCTAssertLessThan(call.duration, 1.2)
    }
    
    //Expect duration to increase (since the call was connected, and then failed)
    func testActiveCallFailed(){
        let uuid = UUID()
        let call = Call(outgoing: false, uuid: uuid)
        callManager.callReceived(call)
        
        let foundCall = callManager.call(with: uuid)
        XCTAssertNotNil(foundCall)
        XCTAssertFalse(foundCall!.isActive)
        
        callManager.callDidConnect(call)
        XCTAssert(foundCall!.isActive)
        
        sleep(1)
        
        callManager.call(call, didFailWithError: MockError.fake)
        XCTAssertFalse(foundCall!.isActive)
        XCTAssertGreaterThanOrEqual(call.duration, 1)
        XCTAssertLessThan(call.duration, 1.2)
        
        sleep(1)
        XCTAssertGreaterThanOrEqual(call.duration, 1)
        XCTAssertLessThan(call.duration, 1.2)
        
    }
    
    ///Expect duration to stay 0
    func testNeverConnectedCallFailed(){
        let uuid = UUID()
        let call = Call(outgoing: false, uuid: uuid)
        callManager.callReceived(call)
        
        let foundCall = callManager.call(with: uuid)
        XCTAssertNotNil(foundCall)
        XCTAssertFalse(foundCall!.isActive)
        
        sleep(1)
        
        callManager.call(call, didFailWithError: MockError.fake)
        XCTAssertFalse(foundCall!.isActive)
        XCTAssertGreaterThanOrEqual(call.duration, 0)
        XCTAssertLessThan(call.duration, 0.1)
    }
    
    
}
