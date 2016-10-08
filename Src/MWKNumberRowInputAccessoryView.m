//
//  MWKNumberRowInputAccessoryView.m
//
//  Created by Mark Kirk on 2/26/14.
//  Copyright (c) 2014-2016 Mark Kirk. All rights reserved.
//

// @TODO:
// - Fix bottom key shadows on iOS 7
// - Would alpha on keys help color shift in dark keyboard?
// - Landscape? Maybe not worth it.


#import "MWKNumberRowInputAccessoryView.h"
#import "UIScreen+MWKNumberRow.h"

static const int kKeyCount = 10;
static NSString* kDefaultKeyStrokeValues[] = { @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"0" };


// iOS 7/8 and iPhone 6
static NSString* const kRetinaHD47 = @"_RetinaHD47";
static const CGRect kKeyBounds_RetinaHD47 = { 0.0f, 0.0f, 32.0f, 42.0f };
static const CGFloat kPressFontSize_RetinaHD47 = 40.0f;
// iOS 7/8 and iPhone 6 Plus
static NSString* const kRetinaHD55 = @"_RetinaHD55";
static const CGRect kKeyBounds_RetinaHD55 = { 0.0f, 0.0f, 36.0f, 45.0f };
static const CGFloat kPressFontSize_RetinaHD55 = 38.0f;
// iOS 7, Retina35, Retina4
static const CGRect kKeyBounds = { 0.0f, 0.0f, 26.0f, 39.0f };
static NSString* const kLightKey = @"LightKey";
static NSString* const kLightLeftKeyPress = @"LightLeftKeyPress";
static NSString* const kLightMiddleKeyPress = @"LightMiddleKeyPress";
static NSString* const kLightRightKeyPress = @"LightRightKeyPress";
static NSString* const kDarkKey = @"DarkKey";
static NSString* const kDarkLeftKeyPress = @"DarkLeftKeyPress";
static NSString* const kDarkMiddleKeyPress = @"DarkMiddleKeyPress";
static NSString* const kDarkRightKeyPress = @"DarkRightKeyPress";
// These are only used for iOS 8.2 and below where we don't yet have [UIFont systemFontOfSize:weight:]
static NSString* const kNormalFontName = @"HelveticaNeue";
static NSString* const kPressFontName = @"HelveticaNeue-Light";
// The font weight constants are externs
#define NORMAL_FONT_WEIGHT UIFontWeightRegular
#define PRESS_FONT_WEIGHT UIFontWeightLight
static const CGFloat kNormalFontSize = 22.0f;
static const CGFloat kPressFontSize = 40.0f;
// Legacy iOS 6 support
static NSString* const kiOS6Key = @"iOS6Key";
static NSString* const kiOS6LeftKeyPress = @"iOS6LeftKeyPress";
static NSString* const kiOS6MiddleKeyPress = @"iOS6MiddleKeyPress";
static NSString* const kiOS6RightKeyPress = @"iOS6RightKeyPress";
static NSString* const kiOS6NormalFontName = @"Helvetica-Bold";
static NSString* const kiOS6PressFontName = @"Helvetica-Bold";
static const CGFloat kiOS6NormalFontSize = 22.0f;
static const CGFloat kiOS6PressFontSize = 44.0f;

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define RGBA_256(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)/255.0]
#define ODB_NR_KEY(a) [NSString stringWithFormat:@"%@%@", a, _imageSuffix]
#define DICTATION_BG_COLOR RGBA_256(162, 168, 176, 255)


// ---------------------------------------------------------------------------------------
// Factory
// ---------------------------------------------------------------------------------------

@implementation MWKNumberRowInputAccessoryViewFactory

+ (id)numberRowInputAccessoryViewWithFrame:(CGRect)aFrame inputViewStyle:(UIInputViewStyle)aInputViewStyle
{
    id inputAccessoryView = nil;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        inputAccessoryView = [[MWKNumberRowInputAccessoryView alloc] initWithFrame:aFrame inputViewStyle:aInputViewStyle];
    }
    else {
        inputAccessoryView = [[MWKNumberRowInputAccessoryView_iOS6 alloc] initWithFrame:aFrame];
    }
    
    return inputAccessoryView;
}


+ (CGRect)defaultFramePortrait
{
    UIScreen *screen = [UIScreen mainScreen];
    CGRect defaultFrame;
    
    if ([screen isRetinaHD47]) {
        defaultFrame = CGRectMake(0.0f, 0.0f, 375.0f, 51.0f);
    }
    else if ([screen isRetinaHD55]) {
        defaultFrame = CGRectMake(0.0f, 0.0f, 414.0f, 56.0f);
    }
    else {
        defaultFrame = CGRectMake(0.0f, 0.0f, 320.0f, 48.0f);
    }
    
    return defaultFrame;
}

@end



// ---------------------------------------------------------------------------------------
// Internal View
// ---------------------------------------------------------------------------------------

@interface MWKNumberRowInputAccessoryInternalView : UIView <UIInputViewAudioFeedback>

@property (nonatomic, weak) id<MWKInputAccessoryViewDelegate> delegate;
@property (nonatomic, strong) NSArray *keys;
@property (nonatomic, assign) CGRect keyBounds;
@property (nonatomic, assign) CGFloat keyCenterX;
@property (nonatomic, assign) CGFloat keyCenterXDelta;
@property (nonatomic, assign) CGFloat leftKeyNormalHorzOffset;
@property (nonatomic, assign) CGFloat rightKeyNormalHorzOffset;
@property (nonatomic, assign) CGFloat leftKeyPressHorzOffset;
@property (nonatomic, assign) CGFloat rightKeyPressHorzOffset;
@property (nonatomic, assign) CGFloat keyNormalVertOffset;
@property (nonatomic, assign) CGFloat keyPressVertOffset;
@property (nonatomic, assign) CGFloat keyPressHorzShift;
@property (nonatomic, assign) NSLayoutAttribute leftKeyHorzLayoutAttr;
@property (nonatomic, assign) NSLayoutAttribute rightKeyHorzLayoutAttr;
@property (nonatomic, assign) UIEdgeInsets leftKeyNormalTitleEdgeInsets;
@property (nonatomic, assign) UIEdgeInsets keyNormalTitleEdgeInsets;
@property (nonatomic, assign) UIEdgeInsets rightKeyNormalTitleEdgeInsets;
@property (nonatomic, assign) UIEdgeInsets leftKeyPressTitleEdgeInsets;
@property (nonatomic, assign) UIEdgeInsets keyPressTitleEdgeInsets;
@property (nonatomic, assign) UIEdgeInsets rightKeyPressTitleEdgeInsets;
@property (nonatomic, assign) CGFloat keyNormalShadowOpacity;
@property (nonatomic, assign) CGFloat keyPressShadowOpacity;
@property (nonatomic, assign) CGFloat keyNormalShadowRadius;
@property (nonatomic, assign) CGFloat keyPressShadowRadius;
@property (nonatomic, assign) CGSize keyNormalShadowOffset;
@property (nonatomic, assign) CGSize keyPressShadowOffset;
@property (nonatomic, strong) UIFont *normalFont;
@property (nonatomic, strong) UIFont *pressFont;
@property (nonatomic, strong) UIColor *fontColor;
@property (nonatomic, strong) UIImage *normalKey;
@property (nonatomic, strong) UIImage *normalKeyEdge; // iPhone 6 Plus
@property (nonatomic, strong) UIImage *normalKeyMiddle;  // iPhone 6 Plus
@property (nonatomic, strong) UIImage *leftKeyPress;
@property (nonatomic, strong) UIImage *middleKeyPress;
@property (nonatomic, strong) UIImage *rightKeyPress;
@property (nonatomic, strong) UIColor *dictationBackgroundColor;

- (void)configureKeyDefaultTitlesAndValues;
- (void)configureKeyAppearance;
- (void)setStrokeValue:(id)aValue forKey:(UIButton*)aKey;
- (id)strokeValueForKey:(UIButton*)aKey;
- (void)showKeys;
- (void)hidekeys;

@end

@interface MWKNumberRowInputAccessoryInternalView ()

@property (nonatomic, strong) NSMutableDictionary *keyToStrokeValue;
@property (nonatomic, strong) NSMutableArray *horzConstraints;
@property (nonatomic, strong) NSMutableArray *vertConstraints;
@property (nonatomic, strong) NSLayoutConstraint *leftKeyHorzConstraint;
@property (nonatomic, strong) NSLayoutConstraint *leftKeyVertConstraint;
@property (nonatomic, strong) NSLayoutConstraint *rightKeyHorzConstraint;
@property (nonatomic, strong) NSLayoutConstraint *rightKeyVertConstraint;
@property (nonatomic, assign) int downKeyIdx;
@property (nonatomic, strong) UIColor *originalBackgroundColor;

@end


@implementation MWKNumberRowInputAccessoryInternalView

+ (BOOL)requiresConstraintBasedLayout
{
    return YES;
}


- (instancetype)initWithFrame:(CGRect)aFrame
{
    if (!(self = [super initWithFrame:aFrame])) return nil;
    [self commonInit];
    return self;
}


- (void)awakeFromNib
{
    [super awakeFromNib];
    [self commonInit];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


// Common code called whether instantiated in code or NIB
- (void)commonInit
{
    [self configureKeyPositioningDefaults];
    
    NSMutableArray *keys = [[NSMutableArray alloc] initWithCapacity:kKeyCount];
    
    for (int i = 0; i < kKeyCount; ++i) {
        UIButton *key = [[UIButton alloc] initWithFrame:self.keyBounds];
        keys[i] = key;
        key.userInteractionEnabled = NO;
        [self addSubview:key];
    }
    
    self.leftKeyHorzLayoutAttr = NSLayoutAttributeLeft;
    self.rightKeyHorzLayoutAttr = NSLayoutAttributeRight;
    self.dictationBackgroundColor = DICTATION_BG_COLOR;
    self.originalBackgroundColor = nil;
    self.keys = [NSArray arrayWithArray:keys];
    self.keyToStrokeValue = [NSMutableDictionary dictionaryWithCapacity:kKeyCount];
    self.horzConstraints = [NSMutableArray arrayWithCapacity:kKeyCount];
    self.vertConstraints = [NSMutableArray arrayWithCapacity:kKeyCount];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self
           selector:@selector(handleTextInputModeChange:)
               name:UITextInputCurrentInputModeDidChangeNotification
             object:nil];
}


- (void)handleTextInputModeChange:(NSNotification*)aNote
{
    // Replaces [currentInputMode] which was deprecated in iOS 7
    BOOL dictationActive = [self.textInputMode.primaryLanguage isEqualToString:@"dictation"];
    (dictationActive) ? [self hidekeys] : [self showKeys];
}


- (void)showKeys
{
    for (UIButton *key in self.keys) {
        key.hidden = NO;
    }
    
    if (self.dictationBackgroundColor) {
        self.backgroundColor = self.originalBackgroundColor;
    }
}


- (void)hidekeys
{
    for (UIButton *key in self.keys) {
        key.hidden = YES;
    }
    
    if (self.dictationBackgroundColor) {
        self.backgroundColor = self.dictationBackgroundColor;
    }
}


- (void)configureKeyDefaultTitlesAndValues
{
    for (int i = 0; i < kKeyCount; ++i) {
        UIButton *key = self.keys[i];
        NSString *title = kDefaultKeyStrokeValues[i];
        NSString *value = kDefaultKeyStrokeValues[i];
        
        if (i == 0) {
            key.titleEdgeInsets = self.leftKeyNormalTitleEdgeInsets;
        }
        else if (i == kKeyCount - 1) {
            key.titleEdgeInsets = self.rightKeyNormalTitleEdgeInsets;
        }
        else {
            key.titleEdgeInsets = self.keyNormalTitleEdgeInsets;
        }
        
        [key setTitle:title forState:UIControlStateNormal];
        [key setTitle:title forState:UIControlStateHighlighted];
        
        [self setStrokeValue:value forKey:key];
    }
}


- (void)configureKeyAppearance
{
    UIScreen *screen = [UIScreen mainScreen];
    
    for (UIButton *key in self.keys) {
        key.titleLabel.font = self.normalFont;
        [key setTitleColor:self.fontColor forState:UIControlStateNormal];
        [key setBackgroundImage:self.normalKey forState:UIControlStateNormal];
        
        if (key == [self.keys firstObject]) { // 1
            if ([screen isRetinaHD55]) {
                [key setBackgroundImage:self.normalKeyEdge forState:UIControlStateNormal];
            }
            
            [key setBackgroundImage:self.leftKeyPress forState:UIControlStateHighlighted];
        }
        else if (key == [self.keys lastObject]) { // 0
            if ([screen isRetinaHD55]) {
                [key setBackgroundImage:self.normalKeyEdge forState:UIControlStateNormal];
            }
            
            [key setBackgroundImage:self.rightKeyPress forState:UIControlStateHighlighted];
        }
        else { // 2-9
            if ([screen isRetinaHD55]) {
                [key setBackgroundImage:self.normalKeyMiddle forState:UIControlStateNormal];
            }
            
            [key setBackgroundImage:self.middleKeyPress forState:UIControlStateHighlighted];
        }
        
        if (self.keyNormalShadowOpacity != 0.0f) {
            [self setNormalShadowForKey:key];
        }
    }
}


// Matching the standard keyboard's number row is always a compromise. Positioning seems to
// vary slightly between OS releases, device vs simulator, time of day, and the weather.
- (void)configureKeyPositioningDefaults
{
    UIScreen *screen = [UIScreen mainScreen];
    
    // Defaults
    if ([screen isRetinaHD47]) {
        self.keyBounds = kKeyBounds_RetinaHD47;
        self.keyNormalVertOffset = -1.0f;
        self.keyPressVertOffset = -1.0f;
        
        self.leftKeyNormalHorzOffset = self.rightKeyNormalHorzOffset = 3.0f;
        self.leftKeyPressHorzOffset = -1.5f;
        self.rightKeyPressHorzOffset = -1.5f;
        
        self.keyPressHorzShift = -0.5f;
        self.keyCenterX = 56.0f;
        self.keyCenterXDelta = 37.5f;
        
        self.leftKeyNormalTitleEdgeInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
        self.keyNormalTitleEdgeInsets = UIEdgeInsetsMake(0.0f, 0.5f, 0.0f, -0.5f);
        self.rightKeyNormalTitleEdgeInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, -0.0f);
        
        self.leftKeyPressTitleEdgeInsets = UIEdgeInsetsMake(3.5f, -5.0f, -3.5f, 5.0f);
        self.keyPressTitleEdgeInsets = UIEdgeInsetsMake(3.5f, 1.0f, -3.5f, -1.0f);
        self.rightKeyPressTitleEdgeInsets = UIEdgeInsetsMake(3.5f, 3.0f, -3.5f, -3.0f);
    }
    else if ([screen isRetinaHD55]) {
        self.keyBounds = kKeyBounds_RetinaHD55;
        self.keyNormalVertOffset = -3.0f;
        self.keyPressVertOffset = -3.0f;
        
        self.leftKeyNormalHorzOffset = self.rightKeyNormalHorzOffset = 4.0f;
        self.leftKeyPressHorzOffset = self.rightKeyPressHorzOffset = -1.0f;//3.34f;//3.67f; dark
        
        self.keyPressHorzShift = -0.34f;
        self.keyCenterX = 63.34f;
        self.keyCenterXDelta = 41.0f;
        
        self.leftKeyNormalTitleEdgeInsets = UIEdgeInsetsMake(-0.67f, 0.0f, 0.67f, -0.0f);
        self.keyNormalTitleEdgeInsets = UIEdgeInsetsMake(-0.67f, 0.34f, 0.67f, -0.34f);
        self.rightKeyNormalTitleEdgeInsets = UIEdgeInsetsMake(-0.67f, 0.0f, 0.67f, -0.0f);
        
        self.leftKeyPressTitleEdgeInsets = UIEdgeInsetsMake(4.34f, -1.34f, -4.34f, 1.34f);
        self.keyPressTitleEdgeInsets = UIEdgeInsetsMake(4.34f, 1.0f, -4.34f, -1.0f);
        self.rightKeyPressTitleEdgeInsets = UIEdgeInsetsMake(4.34f, 1.34f, -4.34f, -1.34f);
    }
    else { // Retina35, Retina4
        self.keyBounds = kKeyBounds;
        self.keyNormalVertOffset = -3.0f;
        self.keyPressVertOffset = -2.5f;
        
        self.leftKeyNormalHorzOffset = self.rightKeyNormalHorzOffset = 3.0f;
        self.leftKeyPressHorzOffset =  -1.0f; // 2.0f no shadow
        self.rightKeyPressHorzOffset = -1.0f;
        
        self.keyCenterX = 48.0f;
        self.keyCenterXDelta = 32.0f;
        
        self.keyNormalTitleEdgeInsets = UIEdgeInsetsMake(0.0f, 0.5f, 0.0f, -0.5f);
        self.leftKeyNormalTitleEdgeInsets = self.keyNormalTitleEdgeInsets;
        self.rightKeyNormalTitleEdgeInsets = self.leftKeyNormalTitleEdgeInsets;

        self.keyPressTitleEdgeInsets = UIEdgeInsetsMake(4.0f, 1.0f, -4.0f, -1.0f);
        self.leftKeyPressTitleEdgeInsets = UIEdgeInsetsMake(4.0f, -5.5f, -4.0f, 5.5f);
        self.rightKeyPressTitleEdgeInsets = UIEdgeInsetsMake(4.0f, 3.5f, -4.0f, -3.5f);
    }
}

- (void)setNormalShadowForKey:(UIButton*)aKey
{
    CALayer *layer = aKey.layer;
    layer.shadowOpacity = self.keyNormalShadowOpacity;
    layer.shadowRadius = self.keyNormalShadowRadius;
    layer.shadowOffset = self.keyNormalShadowOffset;
}


- (void)setPressShadowForKey:(UIButton*)aKey
{
    CALayer *layer = aKey.layer;
    layer.shadowOpacity = self.keyPressShadowOpacity;
    layer.shadowRadius = self.keyPressShadowRadius;
    layer.shadowOffset = self.keyPressShadowOffset;
}


- (void)setStrokeValue:(id)aValue forKey:(UIButton*)aKey
{
    self.keyToStrokeValue[[NSValue valueWithPointer:(__bridge const void*)aKey]] = aValue;
}


- (id)strokeValueForKey:(UIButton*)aKey
{
    return self.keyToStrokeValue[[NSValue valueWithPointer:(__bridge const void*)aKey]];
}


- (CGSize)intrinsicContentSize
{
    CGSize size = [[UIScreen mainScreen] applicationFrame].size;
    return CGSizeMake(size.width, UIViewNoIntrinsicMetric);
}


- (void)updateConstraints
{
    NSUInteger cnt = self.keys.count;
    CGFloat keyCenterX = self.keyCenterX;
    const CGFloat keyCenterXDelta = self.keyCenterXDelta;
    
    for (int i = 0; i < cnt; ++i) {
        UIButton *key = self.keys[i];
        UIView *superview = self;
        key.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *h, *v;
        NSLayoutAttribute horzAttr1, horzAttr2;
        CGFloat horzConstant;
        
        if (i == 0) {
            horzAttr1 = self.leftKeyHorzLayoutAttr;
            horzAttr2 = NSLayoutAttributeLeft;
            horzConstant = self.leftKeyNormalHorzOffset;
        }
        else if (i == cnt - 1) {
            horzAttr1 = self.rightKeyHorzLayoutAttr;
            horzAttr2 = NSLayoutAttributeRight;
            horzConstant = -1.0f * self.rightKeyNormalHorzOffset;
        }
        else {
            horzAttr1 = NSLayoutAttributeCenterX;
            horzAttr2 = NSLayoutAttributeLeft;
            horzConstant = keyCenterX;
            keyCenterX += keyCenterXDelta;
        }
        
        h = [NSLayoutConstraint constraintWithItem:key
                                         attribute:horzAttr1
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:superview
                                         attribute:horzAttr2
                                        multiplier:1.0
                                          constant:horzConstant];
        
        v = [NSLayoutConstraint constraintWithItem:key
                                         attribute:NSLayoutAttributeBottom
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:superview
                                         attribute:NSLayoutAttributeBottom
                                        multiplier:1.0
                                          constant:self.keyNormalVertOffset];
        
        [self.horzConstraints addObject:h];
        [self.vertConstraints addObject:v];
    }
    
    NSMutableArray *constraints = [NSMutableArray arrayWithArray:self.horzConstraints];
    [constraints addObjectsFromArray:self.vertConstraints];
    [self addConstraints:constraints];
    
    [super updateConstraints];
}


- (void)keyPressIndex:(int)aIndex withClick:(BOOL)aShouldClick
{
    UIButton *key = self.keys[aIndex];
    [self bringSubviewToFront:key];
    key.highlighted = YES;
    key.titleLabel.font = self.pressFont;
    key.titleEdgeInsets = self.keyPressTitleEdgeInsets;
    key.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    
    if (aShouldClick) [[UIDevice currentDevice] playInputClick];
    
    if (aIndex == 0) {
        if (!UIEdgeInsetsEqualToEdgeInsets(self.leftKeyPressTitleEdgeInsets, UIEdgeInsetsZero)) {
            key.titleEdgeInsets = self.leftKeyPressTitleEdgeInsets;
        }
        
        ((NSLayoutConstraint*)self.horzConstraints[aIndex]).constant = self.leftKeyPressHorzOffset;
    }
    else if (aIndex == self.keys.count - 1) {
        if (!UIEdgeInsetsEqualToEdgeInsets(self.rightKeyPressTitleEdgeInsets, UIEdgeInsetsZero)) {
            key.titleEdgeInsets = self.rightKeyPressTitleEdgeInsets;
        }

        ((NSLayoutConstraint*)self.horzConstraints[aIndex]).constant = -1.0f * self.rightKeyPressHorzOffset;
    }
    else {
        ((NSLayoutConstraint*)self.horzConstraints[aIndex]).constant -= self.keyPressHorzShift;
    }
    
    ((NSLayoutConstraint*)self.vertConstraints[aIndex]).constant = self.keyPressVertOffset;
    
    [self layoutIfNeeded];
    [self setPressShadowForKey:key];
}


- (void)keyReleaseIndex:(int)aIndex withStroke:(BOOL)aShouldStroke
{
    UIButton *key = self.keys[aIndex];
    key.highlighted = NO;
    key.titleLabel.font = self.normalFont;
    key.titleEdgeInsets = self.keyNormalTitleEdgeInsets;
    key.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self setNormalShadowForKey:key];
    
    if (aShouldStroke &&
        self.delegate &&
        [self.delegate respondsToSelector:@selector(inputAccessory:didGenerateValue:)]) {
        id keyValue = [self strokeValueForKey:key];
        [self.delegate inputAccessory:self didGenerateValue:keyValue];
    }
    
    
    if (aIndex == 0) {
        ((NSLayoutConstraint*)self.horzConstraints[aIndex]).constant = self.leftKeyNormalHorzOffset;
    }
    else if (aIndex == self.keys.count - 1) {
        ((NSLayoutConstraint*)self.horzConstraints[aIndex]).constant = -1.0f * self.rightKeyNormalHorzOffset;
    }
    else {
        ((NSLayoutConstraint*)self.horzConstraints[aIndex]).constant += self.keyPressHorzShift;
    }
    
    ((NSLayoutConstraint*)self.vertConstraints[aIndex]).constant = self.keyNormalVertOffset;
    [self layoutIfNeeded];
}


- (void)touchesBegan:(NSSet*)aTouches withEvent:(UIEvent*)aEvent
{
    CGPoint p = [[aTouches anyObject] locationInView:self];
    
    for (int i = 0; i < kKeyCount; ++i) {
        UIButton *key = self.keys[i];

        // Use a larger hit area
        CGRect hitRect = CGRectInset(key.frame, -3.0f, -3.0f);
        
        if (CGRectContainsPoint(hitRect, p)) {
            self.downKeyIdx = i;
            [self keyPressIndex:i withClick:YES];
            break;
        }
    }
}


- (void)touchesMoved:(NSSet*)aTouches withEvent:(UIEvent*)aEvent
{
    CGPoint p = [[aTouches anyObject] locationInView:self];
    UIButton *downKey = nil;
    if (self.downKeyIdx >= 0) downKey = self.keys[self.downKeyIdx];
    
    if (downKey && !CGRectContainsPoint(downKey.frame, p)) {
        [self keyReleaseIndex:self.downKeyIdx withStroke:NO];
        self.downKeyIdx = -1;
    }
    
    if (!downKey) {
        for (int i = 0; i < kKeyCount; ++i) {
            UIButton *key = self.keys[i];

            // Use a larger hit area
            CGRect hitRect = CGRectInset(key.frame, -3.0f, -3.0f);
            
            if (CGRectContainsPoint(hitRect, p)) {
                self.downKeyIdx = i;
                [self keyPressIndex:i withClick:NO];
                break;
            }
        }
    }
}


- (void)touchesEnded:(NSSet*)aTouches withEvent:(UIEvent*)aEvent
{
    if (self.downKeyIdx >= 0) {
        [self keyReleaseIndex:self.downKeyIdx withStroke:YES];
        self.downKeyIdx = -1;
    }
}


- (void)touchesCancelled:(NSSet*)aTouches withEvent:(UIEvent*)aEvent
{
    [self touchesCancelled:aTouches withEvent:aEvent];
}

#pragma UIInputViewAudioFeedback conformance

- (BOOL)enableInputClicksWhenVisible
{
    return YES;
}

@end


// ---------------------------------------------------------------------------------------
// iOS 7+
// ---------------------------------------------------------------------------------------

@interface MWKNumberRowInputAccessoryView ()
@property (nonatomic, strong) MWKNumberRowInputAccessoryInternalView *internalView;
@property (nonatomic, strong) NSString *imageSuffix;
@property (nonatomic, strong) NSBundle *bundle;
@end

@implementation MWKNumberRowInputAccessoryView
{
    UIKeyboardAppearance _keyboardAppearance;
}


- (instancetype)initWithFrame:(CGRect)aFrame inputViewStyle:(UIInputViewStyle)aInputViewStyle
{
    if (!(self = [super initWithFrame:aFrame inputViewStyle:aInputViewStyle])) return nil;

    self.bundle = [NSBundle bundleForClass:[self class]];
    self.internalView = [[MWKNumberRowInputAccessoryInternalView alloc] initWithFrame:aFrame];
    [self configureInternalView];
    
    if (self.internalView) {
        [self addSubview:self.internalView];
    }
    else {
        return nil;
    }

    return self;
}


- (void)configureInternalView
{
    UIScreen *screen = [UIScreen mainScreen];
    self.imageSuffix = @"";
        
    if ([screen isRetinaHD47]) {
        self.imageSuffix = kRetinaHD47;
    }
    else if ([screen isRetinaHD55]) {
        self.imageSuffix = kRetinaHD55;
    }

    MWKNumberRowInputAccessoryInternalView *internal = self.internalView;
    [self setKeyboardAppearance:UIKeyboardAppearanceDefault];
    [internal configureKeyDefaultTitlesAndValues];
}


- (void)setKeyboardAppearance:(UIKeyboardAppearance)aKeyboardAppearance
{
    UIScreen *screen = [UIScreen mainScreen];
    _keyboardAppearance = aKeyboardAppearance;
    MWKNumberRowInputAccessoryInternalView *internal = self.internalView;
    NSBundle *bundle = self.bundle;
    
    // Font weights show up in iOS 8.2
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.2")) {
        internal.normalFont = [UIFont systemFontOfSize:kNormalFontSize weight:NORMAL_FONT_WEIGHT];

        if ([screen isRetinaHD47]) {
            internal.pressFont = [UIFont systemFontOfSize:kPressFontSize_RetinaHD47 weight:PRESS_FONT_WEIGHT];
        }
        else if ([screen isRetinaHD55]) {
            internal.pressFont = [UIFont systemFontOfSize:kPressFontSize_RetinaHD55 weight:PRESS_FONT_WEIGHT];
        }
        else {
            internal.pressFont = [UIFont systemFontOfSize:kPressFontSize weight:PRESS_FONT_WEIGHT];
        }
    }
    else {
        internal.normalFont = [UIFont fontWithName:kNormalFontName size:kNormalFontSize];
        
        if ([screen isRetinaHD47]) {
            internal.pressFont = [UIFont fontWithName:kPressFontName size:kPressFontSize_RetinaHD47];
        }
        else if ([screen isRetinaHD55]) {
            internal.pressFont = [UIFont fontWithName:kPressFontName size:kPressFontSize_RetinaHD55];
        }
        else {
            internal.pressFont = [UIFont fontWithName:kPressFontName size:kPressFontSize];
        }
    }
    
    switch (aKeyboardAppearance) {
        case UIKeyboardAppearanceDefault:
        case UIKeyboardAppearanceLight:
            internal.fontColor = [UIColor darkTextColor];
            internal.normalKey = [UIImage imageNamed:ODB_NR_KEY(kLightKey) inBundle:bundle compatibleWithTraitCollection:nil];
            internal.leftKeyPress = [UIImage imageNamed:ODB_NR_KEY(kLightLeftKeyPress) inBundle:bundle compatibleWithTraitCollection:nil];
            internal.middleKeyPress = [UIImage imageNamed:ODB_NR_KEY(kLightMiddleKeyPress) inBundle:bundle compatibleWithTraitCollection:nil];
            internal.rightKeyPress = [UIImage imageNamed:ODB_NR_KEY(kLightRightKeyPress) inBundle:bundle compatibleWithTraitCollection:nil];
            // iPhone 6 Plus "1" key is wider than "2", etc.!
            if ([screen isRetinaHD55]) {
                internal.normalKeyEdge = [UIImage imageNamed:@"LightKeyEdge_RetinaHD55" inBundle:bundle compatibleWithTraitCollection:nil];
                internal.normalKeyMiddle = [UIImage imageNamed:@"LightKeyMiddle_RetinaHD55" inBundle:bundle compatibleWithTraitCollection:nil];
            }
            break;
        case UIKeyboardAppearanceDark:
        default:
            internal.fontColor = [UIColor whiteColor];
            internal.normalKey = [UIImage imageNamed:ODB_NR_KEY(kDarkKey) inBundle:bundle compatibleWithTraitCollection:nil];
            internal.leftKeyPress = [UIImage imageNamed:ODB_NR_KEY(kDarkLeftKeyPress) inBundle:bundle compatibleWithTraitCollection:nil];
            internal.middleKeyPress = [UIImage imageNamed:ODB_NR_KEY(kDarkMiddleKeyPress) inBundle:bundle compatibleWithTraitCollection:nil];
            internal.rightKeyPress = [UIImage imageNamed:ODB_NR_KEY(kDarkRightKeyPress) inBundle:bundle compatibleWithTraitCollection:nil];
            
            if ([screen isRetinaHD55]) {
                internal.normalKeyEdge = [UIImage imageNamed:@"DarkKeyEdge_RetinaHD55" inBundle:bundle compatibleWithTraitCollection:nil];
                internal.normalKeyMiddle = [UIImage imageNamed:@"DarkKeyMiddle_RetinaHD55" inBundle:bundle compatibleWithTraitCollection:nil];
            }
            break;
    }
    
    [self.internalView configureKeyAppearance];
}


- (UIKeyboardAppearance)keyboardAppearance
{
    return _keyboardAppearance;
}


- (void)setDelegate:(id<MWKInputAccessoryViewDelegate>)aDelegate
{
    self.internalView.delegate = aDelegate;
}


- (id<MWKInputAccessoryViewDelegate>)delegate
{
    return self.internalView.delegate;
}


- (void)showKeys
{
    [self.internalView showKeys];
}


- (void)hideKeys
{
    [self.internalView hidekeys];
}


- (BOOL)enableInputClicksWhenVisible
{
    return YES;
}

@end


// ---------------------------------------------------------------------------------------
// iOS 6
// ---------------------------------------------------------------------------------------

@interface MWKNumberRowInputAccessoryView_iOS6 ()

@property (nonatomic, strong) MWKNumberRowInputAccessoryInternalView *internalView;
@property (nonatomic, strong) NSBundle *bundle;

@end


@implementation MWKNumberRowInputAccessoryView_iOS6
{
    UIKeyboardAppearance _keyboardAppearance;
}


- (instancetype)initWithFrame:(CGRect)aFrame
{
    // Pad height of frame
    aFrame.size.height += 3.0f;
    
    if (!(self = [super initWithFrame:aFrame])) return nil;

    self.bundle = [NSBundle bundleForClass:[self class]];
    self.internalView = [[MWKNumberRowInputAccessoryInternalView alloc] initWithFrame:aFrame];
    [self configureInternalView];

    if (self.internalView) {
        [self addSubview:self.internalView];
    }
    else {
        return nil;
    }
    
    return self;
}


- (void)configureInternalView
{
    MWKNumberRowInputAccessoryInternalView *internal = self.internalView;

    internal.keyNormalVertOffset = -5.0f;
    internal.keyPressVertOffset = -2.0f;
    internal.leftKeyHorzLayoutAttr = NSLayoutAttributeCenterX;
    internal.rightKeyHorzLayoutAttr = NSLayoutAttributeCenterX;
    internal.leftKeyNormalHorzOffset = internal.rightKeyNormalHorzOffset = 16.0f;
    internal.leftKeyPressHorzOffset = internal.rightKeyPressHorzOffset = 26.0f;
    internal.keyNormalTitleEdgeInsets = UIEdgeInsetsMake(0.f, 1.f, 0.f, -1.f);
    internal.keyPressTitleEdgeInsets = UIEdgeInsetsMake(4.0f, 1.0f, -4.0f, -1.0f);
    internal.rightKeyPressTitleEdgeInsets = UIEdgeInsetsMake(2.0f, 2.0f, -2.0f, -2.0f);
    internal.leftKeyPressTitleEdgeInsets = UIEdgeInsetsMake(2.0f, 0.0f, -2.0f, 0.0f);
    internal.dictationBackgroundColor = DICTATION_BG_COLOR;
    internal.keyNormalShadowOpacity = 1.0f;
    internal.keyNormalShadowRadius = 1.0f;
    internal.keyNormalShadowOffset = CGSizeMake(0.0f, 1.5f);
    internal.keyPressShadowOpacity = 0.6f;
    internal.keyPressShadowRadius = 4.0f;
    internal.keyPressShadowOffset = CGSizeMake(0.0f, 2.0f);
    
    [self setKeyboardAppearance:UIKeyboardAppearanceDefault];
    [internal configureKeyDefaultTitlesAndValues];
    
    for (UIButton *key in internal.keys) {
        [key setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
        key.titleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    }
}


- (void)setKeyboardAppearance:(UIKeyboardAppearance)aKeyboardAppearance
{
    _keyboardAppearance = aKeyboardAppearance;
    MWKNumberRowInputAccessoryInternalView *internal = self.internalView;
    NSBundle *bundle = self.bundle;
    
    internal.normalFont = [UIFont fontWithName:kiOS6NormalFontName size:kiOS6NormalFontSize];
    internal.pressFont = [UIFont fontWithName:kiOS6PressFontName size:kiOS6PressFontSize];
   
    switch (aKeyboardAppearance) {
        case UIKeyboardAppearanceDefault:
        default:
            internal.backgroundColor = [UIColor colorWithRed:144/255.0f green:152/255.0f blue:162/255.0f alpha:1.0f];
            internal.originalBackgroundColor = internal.backgroundColor;
            internal.fontColor = [UIColor darkTextColor];
            internal.normalKey = [UIImage imageNamed:kiOS6Key inBundle:bundle compatibleWithTraitCollection:nil];
            internal.leftKeyPress = [UIImage imageNamed:kiOS6LeftKeyPress inBundle:bundle compatibleWithTraitCollection:nil];
            internal.middleKeyPress = [UIImage imageNamed:kiOS6MiddleKeyPress inBundle:bundle compatibleWithTraitCollection:nil];
            internal.rightKeyPress = [UIImage imageNamed:kiOS6RightKeyPress inBundle:bundle compatibleWithTraitCollection:nil];
            break;
    }
    
    [self.internalView configureKeyAppearance];
}


- (UIKeyboardAppearance)keyboardAppearance
{
    return _keyboardAppearance;
}


- (void)setDelegate:(id<MWKInputAccessoryViewDelegate>)aDelegate
{
    self.internalView.delegate = aDelegate;
}


- (id<MWKInputAccessoryViewDelegate>)delegate
{
    return self.internalView.delegate;
}


- (void)showKeys
{
    [self.internalView showKeys];
}


- (void)hideKeys
{
    [self.internalView hidekeys];
}


- (BOOL)enableInputClicksWhenVisible
{
    return YES;
}

@end

