//
//  TVOIncomingCall.h
//  TwilioVoice
//
//  Copyright © 2016 Twilio. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TVOIncomingCallDelegate.h"

/**
 * Enumeration indicating the state of the incoming call.
 */
typedef NS_ENUM(NSUInteger, TVOIncomingCallState) {
    TVOIncomingCallStatePending = 0,    ///< The incoming call has not been accepted.
    TVOIncomingCallStateConnecting,     ///< The incoming call is connecting.
    TVOIncomingCallStateConnected,      ///< The incoming call is connected.
    TVOIncomingCallStateDisconnected,   ///< The incoming call is disconnected.
    TVOIncomingCallStateCancelled       ///< The incoming call has been cancelled.
};

/**
 * The `TVOIncomingCall` object represents an incoming call. `TVOIncomingCall` objects are not created directly; they
 * are returned by the `<[TVONotificationDelegate incomingCallReceived:]>` delegate method.
 */
@interface TVOIncomingCall : NSObject

/**
 * @name Properties
 */

/**
 * The `<TVOIncomingCallDelegate>` object that will receive call state updates.
 *
 * @see TVOIncomingCallDelegate
 */
@property (nonatomic, weak, nullable) id<TVOIncomingCallDelegate> delegate;

/**
 * `From` value of the incoming call.
 */
@property (nonatomic, strong, readonly, nonnull) NSString *from;

/**
 * `To` value of the incoming call.
 */
@property (nonatomic, strong, readonly, nonnull) NSString *to;

/**
 * `Call SID` value of the incoming call.
 */
@property (nonatomic, strong, readonly, nonnull) NSString *callSid;

/**
 * Property that defines if the incoming call is muted.
 *
 * Setting the property will only take effect if the `<state>` is `TVOIncomingCallStateConnected`.
 */
@property (nonatomic, assign, getter=isMuted) BOOL muted;

/**
 * State of the incoming call.
 *
 * @see TVOIncomingCallState
 */
@property (nonatomic, assign, readonly) TVOIncomingCallState state;

/**
 * @name General Call Actions
 */

/**
 * Disconnects the incoming call.
 *
 * Calling this method on a `TVOIncomingCall` that has the `<state>` of `TVOIncomingCallStateDisconnected` will have no effect.
 */
- (void)disconnect;

/**
 * Send a string of digits.
 *
 * Calling this method on a `TVOIncomingCall` that does not have the `<state>` of `TVOIncomingCallStateConnected`
 * will have no effect.
 *
 * @param digits A string of characters to be played. Valid values are '0' - '9', '*', '#', and 'w'. 
 *               Each 'w' will cause a 500 ms pause between digits sent.
 */
- (void)sendDigits:(nonnull NSString *)digits;

/**
 * @name Incoming Call Actions
 */

/**
 * Accepts the incoming call.
 *
 * Calling `acceptWithDelegate:` will accept the incoming call. Calling this method on a `TVOIncomingCall` that does not
 * have a `<state>` of `TVOIncomingCallStatePending` will have no effect.
 *
 * @param delegate A `<TVOIncomingCallDelegate>` to receive call state updates.
 *
 * @see TVOIncomingCallDelegate
 */
- (void)acceptWithDelegate:(nonnull id<TVOIncomingCallDelegate>)delegate;

/**
 * Rejects the incoming call.
 *
 * Calling `reject` will notify the caller that this call was rejected. Calling this method on a `TVOIncomingCall` that
 * does not have a state of `TVOIncomingCallStatePending` will have no effect.
 */
- (void)reject;

/**
 * Ignores the incoming call.
 *
 * Calling this method on a `TVOIncomingCall` that does not have a state of `TVOIncomingCallStatePending` will have no
 * effect.
 */
- (void)ignore;

- (null_unspecified instancetype)init __attribute__((unavailable("Incoming calls cannot be instantiated directly. See `TVONotificationDelegate`")));

@end


/**
 * CallKit Call Actions
 */
@interface TVOIncomingCall (CallKitIntegration)

/**
 * UUID of the incoming call.
 *
 * Use this UUID for CallKit methods.
 */
@property (nonatomic, strong, readonly, nonnull) NSUUID *uuid;

@end
