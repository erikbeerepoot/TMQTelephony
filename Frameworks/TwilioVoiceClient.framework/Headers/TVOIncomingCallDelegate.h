//
//  TVOIncomingCallDelegate.h
//  TwilioVoice
//
//  Copyright © 2016 Twilio. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TVOIncomingCall;

/**
 * Objects that adopt the `TVOIncomingCallDelegate` protocol will be informed of the
 * lifecycle events of incoming calls.
 */
@protocol TVOIncomingCallDelegate <NSObject>

/**
 * @name Required Methods
 */

/**
 * Notifies the delegate that an incoming call has connected.
 *
 * @param incomingCall The `<TVOIncomingCall>` that was connected.
 *
 * @see TVOIncomingCall
 */
- (void)incomingCallDidConnect:(nonnull TVOIncomingCall *)incomingCall;

/**
 * Notifies the delegate that an incoming call has disconnected.
 *
 * @param incomingCall The `<TVOIncomingCall>` that was disconnected.
 *
 * @see TVOIncomingCall
 */
- (void)incomingCallDidDisconnect:(nonnull TVOIncomingCall *)incomingCall;

/**
 * Notifies the delegate that an incoming call has encountered an error.
 *
 * @param incomingCall The `<TVOIncomingCall>` that encountered the error.
 * @param error The `NSError` that occurred.
 *
 * @see TVOIncomingCall
 */
- (void)incomingCall:(nonnull TVOIncomingCall *)incomingCall
    didFailWithError:(nonnull NSError *)error;

@end
