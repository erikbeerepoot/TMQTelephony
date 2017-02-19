//
//  TVOOutgoingCallDelegate.h
//  TwilioVoice
//
//  Copyright © 2016 Twilio. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TVOOutgoingCall;

/**
 * Objects that adopt the `TVOOutgoingCallDelegate` protocol will be informed of the
 * lifecycle events of outgoing calls.
 */
@protocol TVOOutgoingCallDelegate <NSObject>

/**
 * @name Required Methods
 */

/**
 * Notifies the delegate that an outgoing call has connected.
 *
 * @param outgoingCall The `<TVOOutgoingCall>` that was connected.
 *
 * @see TVOOutgoingCall
 */
- (void)outgoingCallDidConnect:(nonnull TVOOutgoingCall *)outgoingCall;

/**
 * Notifies the delegate that an outgoing call has disconnected.
 *
 * @param outgoingCall The `<TVOOutgoingCall>` that was disconnected.
 *
 * @see TVOOutgoingCall
 */
- (void)outgoingCallDidDisconnect:(nonnull TVOOutgoingCall *)outgoingCall;

/**
 * Notifies the delegate that an outgoing call has encountered an error.
 *
 * @param outgoingCall The `<TVOOutgoingCall>` that encountered the error.
 * @param error The `NSError` that occurred.
 *
 * @see TVOOutgoingCall
 */
- (void)outgoingCall:(nonnull TVOOutgoingCall *)outgoingCall
    didFailWithError:(nonnull NSError *)error;

@end
