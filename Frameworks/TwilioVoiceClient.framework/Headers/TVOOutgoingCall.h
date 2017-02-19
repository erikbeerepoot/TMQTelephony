//
//  TVOOutgoingCall.h
//  TwilioVoice
//
//  Copyright © 2016 Twilio. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TVOOutgoingCallDelegate.h"

/**
 * Enumeration indicating the state of the outgoing call.
 */
typedef NS_ENUM(NSUInteger, TVOOutgoingCallState) {
    TVOOutgoingCallStateConnecting = 0, ///< The outgoing call is connecting.
    TVOOutgoingCallStateConnected,      ///< The outgoing call is connected.
    TVOOutgoingCallStateDisconnected    ///< The outgoing call is disconnected.
};

/**
 * The `TVOOutgoingCall` object represents an outgoing call. `TVOOutgoingCall` objects are not created directly; they
 * are returned by the `<[VoiceClient call:params:delegate:]>` method.
 */
@interface TVOOutgoingCall : NSObject

/**
 * @name Properties
 */

/**
 * The `<TVOOutgoingCallDelegate>` object that will receive call state updates.
 *
 * @see TVOOutgoingCallDelegate
 */
@property (nonatomic, weak, nullable) id<TVOOutgoingCallDelegate> delegate;

/**
 * `Call SID` value of the outgoing call.
 */
@property (nonatomic, strong, readonly, nonnull) NSString *callSid;

/**
 * Property that defines if the outgoing call is muted.
 *
 * Setting the property will only take effect if the `<state>` is `TVOOutgoingCallStateConnected`.
 */
@property (nonatomic, assign, getter=isMuted) BOOL muted;

/**
 * State of the outgoing call.
 *
 * @see TVOOutgoingCallState
 */
@property (nonatomic, assign, readonly) TVOOutgoingCallState state;

/**
 * @name General Call Actions
 */

/**
 * Disconnects the outgoing call.
 *
 * Calling this method on a `TVOOutgoingCall` that has the `<state>` of `TVOOutgoingCallStateDisconnected` will have no effect.
 */
- (void)disconnect;

/**
 * Send a string of digits.
 *
 * Calling this method on a `TVOOutgoingCall` that does not have the `<state>` of `TVOOutgoingCallStateConnected`
 * will have no effect.
 *
 * @param digits A string of characters to be played. Valid values are '0' - '9', '*', '#', and 'w'. 
 *               Each 'w' will cause a 500 ms pause between digits sent.
 */
- (void)sendDigits:(nonnull NSString *)digits;

- (null_unspecified instancetype)init __attribute__((unavailable("Outgoing calls cannot be instantiated directly. See `VoiceClient call:params:delegate:`")));

@end


/**
 * CallKit Call Actions
 */
@interface TVOOutgoingCall (CallKitIntegration)

/**
 * UUID of the outgoing call.
 *
 * Use this UUID for CallKit methods.
 */
@property (nonatomic, strong, nonnull) NSUUID *uuid;

@end
