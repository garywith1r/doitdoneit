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

@interface SetGoalViewController () <UITextFieldDelegate, UITextViewDelegate> {
    IBOutlet UITextField* goalTextField;
    IBOutlet UITextView* goalDescriptionTextView;
    IBOutlet UILabel* goalDescriptionPlaceholderLabel;
    IBOutlet UIView* goalDescriptionBorderView;
}

@end

@implementation SetGoalViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSInteger goal = [[UsersModel sharedInstance].logedUserData integerForKey:LOGGED_USER_GOAL_KEY];
    if (goal)
        goalTextField.text = [NSString stringWithFormat:@" %lld",(long long)goal];
    
    NSString* goalDescription = [[UsersModel sharedInstance].logedUserData objectForKey:LOGGED_USER_GOAL_DESCRIPTION_KEY];
    if (goalDescription && ![@"" isEqualToString:goalDescription]) {
        goalDescriptionTextView.text = goalDescription;
        goalDescriptionPlaceholderLabel.hidden = YES;
    } else {
        goalDescriptionPlaceholderLabel.hidden = NO;
    }
    
    goalTextField.layer.masksToBounds = YES;
    goalTextField.layer.borderColor = YELLOW_COLOR.CGColor;
    goalTextField.layer.borderWidth = 1.0f;
    
    goalDescriptionBorderView.layer.masksToBounds = YES;
    goalDescriptionBorderView.layer.borderColor = YELLOW_COLOR.CGColor;
    goalDescriptionBorderView.layer.borderWidth = 1.0f;
    
    [goalTextField becomeFirstResponder];
    
}


- (IBAction) doneButtonPressed {
    [[UsersModel sharedInstance].logedUserData setInteger:[goalTextField.text integerValue] forKey:LOGGED_USER_GOAL_KEY];
    [[UsersModel sharedInstance].logedUserData setObject:goalDescriptionTextView.text forKey:LOGGED_USER_GOAL_DESCRIPTION_KEY];
//    [[UsersModel sharedInstance] saveCurrentUserData];
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

#pragma mark - UITextViewDelegate Methods

- (void)textViewDidBeginEditing:(UITextView *)textView {
    goalDescriptionPlaceholderLabel.hidden = YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    goalDescriptionPlaceholderLabel.hidden = ![@"" isEqualToString:textView.text];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString* newText = [textView.text stringByReplacingCharactersInRange:range withString:text];
    return newText.length <= TASK_TITLE_MAX_CHARACTERS;
}


@end
