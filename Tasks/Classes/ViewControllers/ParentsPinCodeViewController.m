//
//  ParentsPinCodeViewController.m
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 4/16/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "ParentsPinCodeViewController.h"
#import "UsersModel.h"

@interface ParentsPinCodeViewController () <UITextFieldDelegate> {
    IBOutlet UITextField* pinCodeText;
}

@end

@implementation ParentsPinCodeViewController

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [pinCodeText becomeFirstResponder];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString* text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (text.length == 4) {
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



@end
