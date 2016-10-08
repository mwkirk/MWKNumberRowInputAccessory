//
//  ViewController.m
//  NumberRowExample
//
//  Created by Mark Kirk on 10/3/16.
//  Copyright © 2016 Mark Kirk. All rights reserved.
//

#import "ViewController.h"
#import <MWKNumberRowInputAccessory/MWKNumberRowInputAccessory.h>

@interface ViewController () <UITextFieldDelegate, MWKInputAccessoryViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UISwitch *keyboardAppearanceSwitch;
@property (nonatomic, strong) id<MWKInputAccessoryView> numberRow;

@end


@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect numberRowFrame = [MWKNumberRowInputAccessoryViewFactory defaultFramePortrait];
    self.numberRow = [MWKNumberRowInputAccessoryViewFactory numberRowInputAccessoryViewWithFrame:numberRowFrame
                                                                                  inputViewStyle:UIInputViewStyleKeyboard];
    self.textField.inputAccessoryView = (UIView*)self.numberRow;
    self.numberRow.delegate = self;
    [self changeKeyboardAppearance:nil];
}


#pragma mark - MWKNumberRowInputAccessoryViewDelegate

- (void)inputAccessory:(MWKNumberRowInputAccessoryView*)aInputAccessory didGenerateValue:(id)aValue
{
    NSString *currentText = self.textField.text;
    NSString *newText = [NSString stringWithFormat:@"%@%@", currentText, aValue];
    self.textField.text = newText;
}


- (IBAction)changeKeyboardAppearance:(id)sender
{
    [self.textField resignFirstResponder];
    UIKeyboardAppearance appearance = self.keyboardAppearanceSwitch.isOn ? UIKeyboardAppearanceDark : UIKeyboardAppearanceLight;
    // You can set the keyboard appearance of the number row to match the keyboard
    self.numberRow.keyboardAppearance = appearance;
    self.textField.keyboardAppearance = appearance;
    [self.textField becomeFirstResponder];
}


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
