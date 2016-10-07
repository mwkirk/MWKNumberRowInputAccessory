//
//  ViewController.swift
//  NumberRowExampleSwift
//
//  Created by Mark Kirk on 10/7/16.
//  Copyright © 2016 Mark Kirk. All rights reserved.
//

import UIKit
import MWKNumberRowInputAccessory

class ViewController: UIViewController, MWKInputAccessoryViewDelegate
{
    @IBOutlet weak private var textField: UITextField!
    @IBOutlet weak var keyboardAppearanceSwitch: UISwitch!

    let numberRow: MWKInputAccessoryView = {
        let frame = MWKNumberRowInputAccessoryViewFactory.defaultFramePortrait()
        return MWKNumberRowInputAccessoryViewFactory.numberRowInputAccessoryView(withFrame: frame, inputViewStyle:UIInputViewStyle.keyboard)
    } ()
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.textField.inputAccessoryView = (self.numberRow as! UIView)
        self.numberRow.delegate = self
        self.changeKeyboardAppearance(nil)
    }
    
    
    // MARK: MWKNumberRowInputAccessoryViewDelegate
    func inputAccessory(_ aInputAccessory: UIView, didGenerateValue aValue: Any)
    {
        guard let value = aValue as? String else {
            return;
        }
        
        let currentText: String = self.textField.text!
        let newText: String = String(format: "%@%@", currentText, value)
        self.textField.text = newText
    }

    
    @IBAction func changeKeyboardAppearance(_ sender: AnyObject?)
    {
        self.textField.resignFirstResponder()
        let appearance = self.keyboardAppearanceSwitch.isOn ? UIKeyboardAppearance.dark : UIKeyboardAppearance.light
        // You can set the keyboard appearance of the number row to match the keyboard
        self.numberRow.keyboardAppearance = appearance
        self.textField.keyboardAppearance = appearance
        self.textField.becomeFirstResponder()
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
}

