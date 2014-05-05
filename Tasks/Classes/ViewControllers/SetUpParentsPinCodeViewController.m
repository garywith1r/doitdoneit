//
//  ParentsPinCodeViewController.m
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 4/16/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "SetUpParentsPinCodeViewController.h"
#import "UsersModel.h"
#import "Constants.h"

@interface SetUpParentsPinCodeViewController () <UITextFieldDelegate> {
    IBOutlet UILabel* canChangeOnSettingsLabel;
    IBOutlet UITextField* oldPinCodeText;
    IBOutlet UILabel* oldPinCodeErrorLabel;
    IBOutlet UIImageView* oldPinErrorImage;
    
    IBOutlet UITextField* newPinCodeText;
    IBOutlet UITextField* retryNewPinCodeText;
    IBOutlet UILabel* newPinCodeErrorLabel;
    IBOutlet UIImageView* newPinErrorImage;
    
    IBOutlet UIButton* smallDoneBtn;
    IBOutlet UIButton* cancelBtn;
    IBOutlet UIButton* bigDoneBtn;
}

@end

@implementation SetUpParentsPinCodeViewController

- (void) viewWillAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([UsersModel sharedInstance].parentsPinCode) {
        [oldPinCodeText becomeFirstResponder];
        oldPinCodeText.hidden = smallDoneBtn.hidden = cancelBtn.hidden = NO;
        canChangeOnSettingsLabel.hidden = bigDoneBtn.hidden = YES;
    } else {
        [newPinCodeText becomeFirstResponder];
        oldPinCodeText.hidden = smallDoneBtn.hidden = cancelBtn.hidden = YES;
        canChangeOnSettingsLabel.hidden = bigDoneBtn.hidden = NO;
    }
    
    
    oldPinCodeText.layer.masksToBounds = YES;
    oldPinCodeText.layer.borderColor = YELLOW_COLOR.CGColor;
    oldPinCodeText.layer.borderWidth = 1.0f;
    
    newPinCodeText.layer.masksToBounds = YES;
    newPinCodeText.layer.borderColor = YELLOW_COLOR.CGColor;
    newPinCodeText.layer.borderWidth = 1.0f;
    
    retryNewPinCodeText.layer.masksToBounds = YES;
    retryNewPinCodeText.layer.borderColor = YELLOW_COLOR.CGColor;
    retryNewPinCodeText.layer.borderWidth = 1.0f;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return [textField.text stringByReplacingCharactersInRange:range withString:string].length <= PARENTS_CODE_DIGITS;
}

- (IBAction) done:(id)sender {
    NSString* oldPin = [UsersModel sharedInstance].parentsPinCode;
    if (oldPin) {
        if (![oldPinCodeText.text isEqualToString:oldPin]) {
            oldPinErrorImage.hidden = oldPinCodeErrorLabel.hidden = NO;
            return;
        } else {
            oldPinErrorImage.hidden = oldPinCodeErrorLabel.hidden = YES;
        }
    }
    
    if ([@"" isEqualToString:newPinCodeText.text] || ![newPinCodeText.text isEqualToString:retryNewPinCodeText.text]) {
        newPinErrorImage.hidden = newPinCodeErrorLabel.hidden = NO;
        return;
    } else {
        newPinErrorImage.hidden = newPinCodeErrorLabel.hidden = YES;
    }
    
    [UsersModel sharedInstance].parentsPinCode = newPinCodeText.text;
    [self cancel:nil];
}

- (IBAction) cancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


@end
