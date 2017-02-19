//
//  TVONotificationDelegate.h
//  TwilioVoice
//
//  Copyright © 2016 Twilio. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TVOIncomingCall;

/**
 * The `TVONotificationDelegate`'s methods allow the delegate to be informed when
 * incoming calls are received or cancelled.
 */
@protocol TVONotificationDelegate <NSObject>

/**
 * Notifies the delegate that an incoming call has been received.
 *
 * @param incomingCall A `<TVOIncomingCall>` object.
 *
 * @see TVOIncomingCall
 */
- (void)incomingCallReceived:(nonnull TVOIncomingCall *)incomingCall;

/**
 * Notifies the delegate that an incoming call has been cancelled.
 *
 * @param incomingCall A `<TVOIncomingCall>` object. ***Note:*** This may be `nil` if
 *                     a `<TVOIncomingCall>` object was not previously created.
 *
 * @see TVOIncomingCall
 */
- (void)incomingCallCancelled:(nullable TVOIncomingCall *)incomingCall;

/**
 * Notifies the delegate that an error occurred when processing the `VoIP`
 * push notification payload.
 *
 * @param error An `NSError` object describing the error.
 */
- (void)notificationError:(nonnull NSError *)error;

@end
