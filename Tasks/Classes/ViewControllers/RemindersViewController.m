//
//  RemindersViewController.m
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 4/30/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "RemindersViewController.h"
#import "UsersModel.h"

@interface RemindersViewController () {
    IBOutlet UISwitch* remindersSwitch;
}



@end

@implementation RemindersViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    remindersSwitch.on = [[UsersModel sharedInstance].logedUserData integerForKey:LOGGED_USER_REMINDERS_KEY];
}


- (IBAction) switchValueChanged {
    [[UsersModel sharedInstance].logedUserData setInteger:remindersSwitch.on forKey:LOGGED_USER_REMINDERS_KEY];
}

@end
