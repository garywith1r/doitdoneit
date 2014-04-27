//
//  SetParentsPinViewController.m
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 4/16/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "SetParentsPinViewController.h"
#import "UsersModel.h"
#import "Constants.h"

@interface SetParentsPinViewController () <UITextFieldDelegate>  {
    IBOutlet UITextField* pincode;
}

@end

@implementation SetParentsPinViewController


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString* text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (text.length == PARENTS_CODE_DIGITS) {
        if ([text isEqualToString:[UsersModel sharedInstance].parentsPinCode]) {
            [self.navigationController popViewControllerAnimated:YES];
            [UsersModel sharedInstance].parentsModeEnabled = YES;
        } else {
            textField.text = @"";
            return NO;
        }
    }
    return YES;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [pincode becomeFirstResponder];
}



@end
