//
//  WholeNumberKeypad.h
//  myStudentAid2.1
//
//  Created by Jerry Walton on 10/27/18.
//

#import <Cordova/CDV.h>

NS_ASSUME_NONNULL_BEGIN

@interface WholeNumberKeypad : CDVPlugin

typedef enum : NSUInteger {
    WholeNumberKeyPad = 0,
    WholeNumberKeyPadNegative = 1
} WHOLE_NUMBER_KEYPAD_TYPE;

// OK plugin-result with int message sent upon each value change
-(void) show:(CDVInvokedUrlCommand*)command value:(int)value keyPadType:(WHOLE_NUMBER_KEYPAD_TYPE)keyPadType;

// CDVCommandStatus_NO_RESULT sent upon 
-(void) hide:(CDVInvokedUrlCommand*)command;
@end

NS_ASSUME_NONNULL_END
