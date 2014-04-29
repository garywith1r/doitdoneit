//
//  SetParentsPinViewController.m
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 4/16/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "EnterParentsPinViewController.h"
#import "UsersModel.h"
#import "Constants.h"

@interface EnterParentsPinViewController () <UITextFieldDelegate>  {
    IBOutlet UITextField* pincode;
    IBOutlet UILabel* errorPincode;
}

@end

@implementation EnterParentsPinViewController


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString* text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (text.length == PARENTS_CODE_DIGITS) {
        if ([text isEqualToString:[UsersModel sharedInstance].parentsPinCode]) {
            [self.navigationController popViewControllerAnimated:YES];
            [UsersModel sharedInstance].parentsModeEnabled = YES;
            errorPincode.hidden = YES;
        } else {
            textField.text = @"";
            errorPincode.hidden = NO;
            return NO;
        }
    }
    return YES;
}

- (IBAction) cancel {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [pincode becomeFirstResponder];
    pincode.layer.masksToBounds = YES;
    pincode.layer.borderColor = YELLOW_COLOR.CGColor;
    pincode.layer.borderWidth = 1.0f;
}



@end
