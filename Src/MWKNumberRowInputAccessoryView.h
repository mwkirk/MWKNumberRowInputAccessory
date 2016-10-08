//
//  MWKNumberRowInputAccessoryView.h
//
//  Created by Mark Kirk on 2/26/14.
//  Copyright (c) 2014-2016 Mark Kirk. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifdef NS_ASSUME_NONNULL_BEGIN
NS_ASSUME_NONNULL_BEGIN
#endif

@protocol MWKInputAccessoryViewDelegate <NSObject>
@required
- (void)inputAccessory:(UIView*)aInputAccessory didGenerateValue:(id)aValue;
@end

@protocol MWKInputAccessoryView <NSObject>
@optional
- (instancetype)initWithFrame:(CGRect)aFrame inputViewStyle:(UIInputViewStyle)aInputViewStyle;
- (instancetype)initWithFrame:(CGRect)aFrame;
@required
@property (nonatomic, weak, nullable) id<MWKInputAccessoryViewDelegate> delegate;
@property (nonatomic, assign) UIKeyboardAppearance keyboardAppearance;
- (void)showKeys;
- (void)hideKeys;
@end


@interface MWKNumberRowInputAccessoryViewFactory : NSObject
+ (id<MWKInputAccessoryView>)numberRowInputAccessoryViewWithFrame:(CGRect)aFrame
                                                   inputViewStyle:(UIInputViewStyle)aInputViewStyle;
+ (CGRect)defaultFramePortrait;
@end

#ifdef NS_ASSUME_NONNULL_END
NS_ASSUME_NONNULL_END
#endif


// iOS 7+
@interface MWKNumberRowInputAccessoryView : UIInputView <MWKInputAccessoryView, UIInputViewAudioFeedback>
@end


// iOS 6
@interface MWKNumberRowInputAccessoryView_iOS6 : UIView <MWKInputAccessoryView, UIInputViewAudioFeedback>
@end
