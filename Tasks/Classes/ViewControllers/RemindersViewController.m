//
//  RemindersViewController.m
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 4/30/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "RemindersViewController.h"
#import "UsersModel.h"
#import "Constants.h"

@interface RemindersViewController () {
    IBOutlet UISwitch* remindersSwitch;
    IBOutlet UIView* remindersTextBox;
}



@end

@implementation RemindersViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    remindersSwitch.on = [[UsersModel sharedInstance].logedUserData integerForKey:LOGGED_USER_REMINDERS_KEY];
    
    remindersTextBox.layer.borderColor = YELLOW_COLOR.CGColor;
    remindersTextBox.layer.borderWidth = 1.0;
}


- (IBAction) switchValueChanged {
    [[UsersModel sharedInstance].logedUserData setInteger:remindersSwitch.on forKey:LOGGED_USER_REMINDERS_KEY];
}

@end
