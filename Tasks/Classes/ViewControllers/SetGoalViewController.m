//
//  SetGoalViewController.m
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 4/29/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "SetGoalViewController.h"
#import "UsersModel.h"
#import "Constants.h"

@interface SetGoalViewController () <UITextFieldDelegate> {
    IBOutlet UITextField* goalTextField;
}

@end

@implementation SetGoalViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSInteger goal = [[UsersModel sharedInstance].logedUserData integerForKey:LOGGED_USER_GOAL_KEY];
    if (goal)
        goalTextField.text = [NSString stringWithFormat:@"%lld",(long long)goal];
    
    goalTextField.layer.masksToBounds = YES;
    goalTextField.layer.borderColor = YELLOW_COLOR.CGColor;
    goalTextField.layer.borderWidth = 1.0f;
    
    [goalTextField becomeFirstResponder];
    
}


- (IBAction) doneButtonPressed {
    [[UsersModel sharedInstance].logedUserData setInteger:[goalTextField.text integerValue] forKey:LOGGED_USER_GOAL_KEY];
    [[UsersModel sharedInstance] saveCurrentUserData];
    [self cancelButtonPressed];
}

- (IBAction) cancelButtonPressed {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextFieldDelegate Methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([@"" isEqualToString:textField.text]) {
        textField.text = [@" " stringByAppendingString:string];
        return NO;
    }
        
    return YES;
}

@end
