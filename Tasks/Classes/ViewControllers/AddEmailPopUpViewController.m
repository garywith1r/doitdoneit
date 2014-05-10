//
//  AddEmailPopUpViewController.m
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 5/10/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "AddEmailPopUpViewController.h"
#import "NSString+Utilities.h"

@interface AddEmailPopUpViewController () {
    IBOutlet UITextField* addEmailText;
}

@end

@implementation AddEmailPopUpViewController
@synthesize delegate, email;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.email) {
        addEmailText.text = self.email;
    }
    
    [addEmailText becomeFirstResponder];
}

- (IBAction) doneButtonPressed {
    if ([addEmailText.text isEqualToString:@""] || ![addEmailText.text isValidEmailFormat]) {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Please enter a valid email address" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(doneWithEmail:)]) {
        [self.delegate doneWithEmail:addEmailText.text];
    }
    [super doneButtonPressed];
}
@end
