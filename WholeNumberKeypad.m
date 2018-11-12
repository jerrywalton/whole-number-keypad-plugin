//
//  WholeNumberKeypad.m
//  myStudentAid2.1
//
//  Created by Jerry Walton on 10/27/18.
//

#import "WholeNumberKeypad.h"

typedef enum : NSUInteger {
    WNKT_one,
    WNKT_two,
    WNKT_three,
    WNKT_four,
    WNKT_five,
    WNKT_six,
    WNKT_seven,
    WNKT_eight,
    WNKT_nine,
    WNKT_neg,
    WNKT_zero,
    WNKT_del,
    WNKT_go,
} WholeNumberKeyType;

@interface WholeKeyInfo : NSObject <NSCopying>
@property (nonatomic, assign) NSString *key;
@property (nonatomic, assign) NSString *title;
@property (nonatomic, assign) WholeNumberKeyType type;
- (id) initWithKey:(NSString*)key title:(NSString*)tite type:(WholeNumberKeyType)type;
@end

@interface WholeNumberView : UIView
-(UIView*)createWholeNumberViewWithFrame:(CGRect)frame type:(WHOLE_NUMBER_KEYPAD_TYPE)keyPadType;
@end

@implementation WholeKeyInfo

- (id) initWithKey:(NSString*)key title:(NSString*)title type:(WholeNumberKeyType)type
{
    if (self = [super init]) {
        self.key = key;
        self.title = title;
        self.type = type;
    }
    return self;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    WholeKeyInfo *info = [[WholeKeyInfo allocWithZone:zone] init];
    info.key = self.key;
    info.title = self.title;
    info.type = self.type;
    return info;
}

@end

@interface WholeNumberKeypad (){}
@property (nonatomic, weak) NSString* callbackId;
@property (nonatomic, weak) NSString* valueChangedCallbackId;
@property (nonatomic, weak) NSString* goBtnCallbackId;
@property (nonatomic, strong) NSDictionary *btnInfoDict;

@end

@protocol WholeNumberViewDelegate
- (void) valueChanged:(NSString*)value;
@end

@interface WholeNumberView()
{}
@property (nonatomic, strong) NSMutableDictionary* btnInfos;
@property (nonatomic, strong) NSArray* numberBtns;
@property (nonatomic, strong) NSArray* activeBtns;
@property (nonatomic, strong) NSMutableString *mValue;
@property (nonatomic, weak) id delegate;
@end

@implementation WholeNumberView

static NSString *ONE = @"1";
static NSString *TWO = @"2";
static NSString *THREE = @"3";
static NSString *FOUR = @"4";
static NSString *FIVE = @"5";
static NSString *SIX = @"6";
static NSString *SEVEN = @"7";
static NSString *EIGHT = @"8";
static NSString *NINE = @"9";
static NSString *ZERO = @"0";
static NSString *NEG = @"NEG";
static NSString *NEG_SIGN = @"-";
static NSString *DEL = @"DEL";
static NSString *DEL_SYM = @"⌫";
static NSString *GO = @"GO";
//NSString *buttons = @"-,0,⌫,GO";
//NSString *buttons = @"NEG,0,DEL,GO";

-(UIView*)createWholeNumberViewWithFrame:(CGRect)frame type:(WHOLE_NUMBER_KEYPAD_TYPE)keyPadType
{
    // init the buffer to hold the string value
    self.mValue = [[NSMutableString alloc] init];
    
//    static dispatch_once_t onceToken1;
//    dispatch_once(&onceToken1, ^{
    NSDictionary *nums = [[NSDictionary alloc] initWithObjectsAndKeys:
                          [[WholeKeyInfo alloc] initWithKey:ONE title:ONE type:WNKT_one], ONE,
                          [[WholeKeyInfo alloc] initWithKey:TWO title:TWO type:WNKT_two], TWO,
                          [[WholeKeyInfo alloc] initWithKey:THREE title:THREE type:WNKT_three], THREE,
                          [[WholeKeyInfo alloc] initWithKey:FOUR title:FOUR type:WNKT_four], FOUR,
                          [[WholeKeyInfo alloc] initWithKey:FIVE title:FIVE type:WNKT_five], FIVE,
                          [[WholeKeyInfo alloc] initWithKey:SIX title:SIX type:WNKT_six], SIX,
                          [[WholeKeyInfo alloc] initWithKey:SEVEN title:SEVEN type:WNKT_seven], SEVEN,
                          [[WholeKeyInfo alloc] initWithKey:EIGHT title:EIGHT type:WNKT_eight], EIGHT,
                          [[WholeKeyInfo alloc] initWithKey:NINE title:NINE type:WNKT_nine], NINE,
                          nil];
        self.btnInfos = [[NSMutableDictionary alloc] initWithDictionary:nums copyItems:false];
        self.numberBtns = [NSArray arrayWithObjects:
                          ONE,TWO,THREE,FOUR,FIVE,SIX,SEVEN,EIGHT,NINE,
                          nil];
        switch (keyPadType) {
            case WholeNumberKeyPadNegative:
                // 4 buttons across
                [self.btnInfos setObject:[[WholeKeyInfo alloc] initWithKey:DEL title:DEL type:WNKT_del] forKey:DEL];
                [self.btnInfos setObject:[[WholeKeyInfo alloc] initWithKey:ZERO title:ZERO type:WNKT_zero] forKey:ZERO];
                [self.btnInfos setObject:[[WholeKeyInfo alloc] initWithKey:NEG title:NEG type:WNKT_neg] forKey:NEG];
                [self.btnInfos setObject:[[WholeKeyInfo alloc] initWithKey:GO title:GO type:WNKT_go] forKey:GO];
                self.activeBtns = [NSArray arrayWithObjects:
                              DEL,ZERO,NEG,GO,
                              nil];
                break;
            default:
                // 3 buttons across
                [self.btnInfos setObject:[[WholeKeyInfo alloc] initWithKey:DEL title:DEL type:WNKT_del] forKey:DEL];
                [self.btnInfos setObject:[[WholeKeyInfo alloc] initWithKey:ZERO title:ZERO type:WNKT_zero] forKey:ZERO];
                [self.btnInfos setObject:[[WholeKeyInfo alloc] initWithKey:GO title:GO type:WNKT_go] forKey:GO];
                self.activeBtns = [NSArray arrayWithObjects:
                                  DEL,ZERO,GO,
                                  nil];
                break;
        }
//    });
    
    UIView *view = [[UIView alloc] init];
    [view setBackgroundColor:[UIColor grayColor]];
    
    CGFloat margin = 4.0f;
    CGFloat numWid = (frame.size.width - (margin * 4)) / 3; //100.0f;
    CGFloat btnWid = (numWid / 2) - (margin / 2);
    CGFloat height = 60.0f;
    
    CGRect kfram = frame;
    kfram.size.height = (height * 4) + (margin * 5);
    kfram.origin.y = frame.size.height - kfram.size.height;
    view.frame = kfram;

    // 9 keys (3 x 3)
    int cellCnt = 0;
    int rowCnt = 0;
    for (int i=0; i<self.numberBtns.count; i++)
    {
        NSString *key = [self.numberBtns objectAtIndex:i];
        
        if (++cellCnt % 3 == 1)
        {
            rowCnt += 1;
            cellCnt = 1;
        }
        
        CGRect frame = CGRectMake(0, 0, numWid, height);
        frame.origin.x = cellCnt > 1 ? (cellCnt - 1) * numWid : 0;
        frame.origin.x += cellCnt * margin;
        frame.origin.y = rowCnt > 1 ? (rowCnt - 1) * height : 0;
        frame.origin.y += rowCnt * margin;
        
        WholeKeyInfo *info = [self.btnInfos objectForKey:key];
        UIButton *btn = [self createButtonWithTitle:info.title frame:frame];
        
        [view addSubview:btn];
    }

    // last row has 3 or 4 buttons
    rowCnt += 1;
    cellCnt = 0;
    
    for (int i=0; i<self.activeBtns.count; i++)
    {
        NSString *key = self.activeBtns[i];
        
        cellCnt += 1;
        CGRect frame = CGRectZero;

        switch (keyPadType) {
            case WholeNumberKeyPad:
                frame = CGRectMake(0, 0, numWid, height);
                frame.origin.x = cellCnt > 1 ? (cellCnt - 1) * numWid : 0;
                frame.origin.x += cellCnt * margin;
                frame.origin.y = rowCnt > 1 ? (rowCnt - 1) * height : 0;
                frame.origin.y += rowCnt * margin;
                break;
            case WholeNumberKeyPadNegative:
                if (cellCnt < 3) {
                    frame = CGRectMake(0, 0, numWid, height);
                    frame.origin.x = cellCnt > 1 ? (cellCnt - 1) * numWid : 0;
                } else{
                    frame = CGRectMake(0, 0, btnWid, height);
                    frame.origin.x = 2 * numWid;
                    frame.origin.x += (cellCnt - 3) * btnWid;
                }
                frame.origin.x += cellCnt * margin;
                frame.origin.y = (rowCnt - 1) * height;
                frame.origin.y += rowCnt * margin;
                break;
            default:
                break;
        }
        
        WholeKeyInfo *info = [self.btnInfos objectForKey:key];
        UIButton *btn = [self createButtonWithTitle:info.title frame:frame];
        [view addSubview:btn];
    }

    return view;
}

- (UIButton*)createButtonWithTitle:(NSString*)title frame:(CGRect)frame
{
    // create button
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn setBackgroundColor:[UIColor whiteColor]];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.layer.borderWidth = 1.0f;
    btn.layer.borderColor = [UIColor darkTextColor].CGColor;
    btn.layer.cornerRadius = 6.0f;
    [btn addTarget:self action:@selector(handleBtnTouch:) forControlEvents:UIControlEventTouchDown];
    btn.exclusiveTouch = YES;
    btn.frame = frame;

    return btn;
}

- (void)handleBtnTouch:(id)sender
{
    UIButton *btn = sender;
    NSString *key = btn.currentTitle;
    WholeKeyInfo *info = [self.btnInfos objectForKey:key];
    [self handleButtonTouchWithInfo:info];
}

- (void)handleButtonTouchWithInfo:(WholeKeyInfo *)info {
    
    switch (info.type) {
        case WNKT_one:
            // add 1 to the right side of value
            [self.mValue appendString:ONE];
            break;
        case WNKT_two:
            // add 2 to the right side of value
            [self.mValue appendString:TWO];
            break;
        case WNKT_three:
            // add 3 to the right side of value
            [self.mValue appendString:THREE];
            break;
        case WNKT_four:
            // add 4 to the right side of value
            [self.mValue appendString:FOUR];
            break;
        case WNKT_five:
            // add 5 to the right side of value
            [self.mValue appendString:FIVE];
            break;
        case WNKT_six:
            // add 6 to the right side of value
            [self.mValue appendString:SIX];
            break;
        case WNKT_seven:
            // add 7 to the right side of value
            [self.mValue appendString:SEVEN];
            break;
        case WNKT_eight:
            // add 8 to the right side of value
            [self.mValue appendString:EIGHT];
            break;
        case WNKT_nine:
            // add 9 to the right side of value
            [self.mValue appendString:NINE];
            break;
        case WNKT_zero:
            // add 0 to the right side of value
            [self.mValue appendString:ZERO];
            break;
        case WNKT_del:
            // delete char from right side of value
            if (self.mValue.length > 1) {
                self.mValue = [NSMutableString stringWithString:[self.mValue substringToIndex:self.mValue.length-1]];
            } else{
                self.mValue = [NSMutableString string];
            }
            break;
        case WNKT_neg:
            // add negative sign to left side of value
            if (![self.mValue hasPrefix:@"-"]) {
                self.mValue = [NSMutableString stringWithFormat:@"-%@", self.mValue];
            }
            break;
        case WNKT_go:
            // handle the go button
            self.mValue = [NSMutableString string];
            break;
            
        default:
            break;
    }
    NSLog(@"value: %@", self.mValue);
    if (self.delegate)
    {
        [self.delegate valueChanged: self.mValue];
    }
}

@end

@interface WholeNumberKeypad() <WholeNumberViewDelegate>
@property (nonatomic, assign) int value;
@property (nonatomic, weak) UIView *wnk;
@property (nonatomic, strong) WholeNumberView *wholeNumberView;
@end

@implementation WholeNumberKeypad

-(void) show:(CDVInvokedUrlCommand*)command value:(int)value keyPadType:(WHOLE_NUMBER_KEYPAD_TYPE)keyPadType
{
    _callbackId = command.callbackId;
    _value = value;
    
    CDVPluginResult *p = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:p callbackId:_callbackId];
}

-(void) hide:(CDVInvokedUrlCommand*)command
{
    [self handleHideCommand:command];
    CDVPluginResult *p = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:p callbackId:_callbackId];
}

- (void)valueChanged:(NSString *)stringValue {
    NSLog(@"valueChanged: %@", stringValue);
    [self handleValueChanged:stringValue];
}

- (void) handleShowCommand:(CDVInvokedUrlCommand*)command keyPadType:(WHOLE_NUMBER_KEYPAD_TYPE)keyPadType
{
    self.wholeNumberView = [WholeNumberView new];
    [self.webView addSubview:[self.wholeNumberView createWholeNumberViewWithFrame:self.webView.frame type:keyPadType]];
    CDVPluginResult *p = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:p callbackId:_callbackId];
}

- (void) handleHideCommand:(CDVInvokedUrlCommand*)command
{
    if (self.wholeNumberView != nil)
    {
        if (self.wholeNumberView.superview != nil)
        {
            [self.wholeNumberView removeFromSuperview];
        }
        self.wholeNumberView = nil;
    }
    CDVPluginResult *p = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
    [self.commandDelegate sendPluginResult:p callbackId:_callbackId];
}

- (void)handleValueChanged:(NSString *)stringValue
{
    int nval = 0;
    @try  {
        nval = [stringValue intValue];
        _value = nval;
    } @catch (NSException *exception) {
        // for whatever reason the string to int conversion failed.
        NSLog(@"%@ ",exception.name);
        NSLog(@"Reason: %@ ",exception.reason);
        // last value will get sent again.
    }
    
    CDVPluginResult *p = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:_value];
    [self.commandDelegate sendPluginResult:p callbackId:_callbackId];
}

- (void)addToWebView:(UIView*)view
{
    // Add the view to current controller
    self.wnk = view;
    [self.webView.superview addSubview:self.wnk];
    [self.webView.superview bringSubviewToFront:self.wnk];
}

- (void)removeFromWebView
{
    if (self.wnk != nil) {
        if (self.wnk.superview != nil) {
            [self.wnk removeFromSuperview];
        }
        self.wnk = nil;
    }
}

@end
