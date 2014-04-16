//
//  SetParentsPinViewController.m
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 4/16/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "SetParentsPinViewController.h"
#import "UsersModel.h"

@interface SetParentsPinViewController () <UITextFieldDelegate>  {
    IBOutlet UITextField* pincode;
}

@end

@implementation SetParentsPinViewController

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [pincode becomeFirstResponder];
}

- (IBAction) savePincode {
    [UsersModel sharedInstance].parentsPinCode = pincode.text;
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return [textField.text stringByReplacingCharactersInRange:range withString:string].length <= PINCODE_CHARACTERS;
}

@end
