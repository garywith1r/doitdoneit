//
//  SettingsTabBarController.m
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 4/25/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "SettingsTabBarController.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "Constants.h"

@interface SettingsTabBarController () <MFMailComposeViewControllerDelegate>

@end

@implementation SettingsTabBarController


- (IBAction) sendFeedbadck {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        [controller setSubject:FEEDBACK_EMAIL_SUBJECT];
        [controller setMessageBody:FEEDBACK_EMAIL_BODY isHTML:NO];
        [controller setToRecipients:@[FEEDBACK_EMAIL_RECIPIENT]];
        [self presentViewController:controller animated:YES completion:nil];
    } else {
        // Handle the error
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    if (result == MFMailComposeResultSent) {
        
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
