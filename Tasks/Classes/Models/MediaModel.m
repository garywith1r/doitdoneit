//
//  MediaModel.m
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 2/27/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "MediaModel.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>

@interface MediaModel () {
//    SLComposeViewController *mySLComposerSheet;
}
@end

@implementation MediaModel

+ (void) postMessageToFacebook:(NSString*)message {
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) //check if Facebook Account is linked
    {
        SLComposeViewController* mySLComposerSheet = [[SLComposeViewController alloc] init]; //initiate the Social Controller
        mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook]; //Tell him with what social plattform to use it, e.g. facebook or twitter
        [mySLComposerSheet setInitialText:[NSString stringWithFormat:message,mySLComposerSheet.serviceType]]; //the message you want to post
//        [mySLComposerSheet addImage:yourimage]; //an image you could post
        //for more instance methodes, go here:https://developer.apple.com/library/ios/#documentation/NetworkingInternet/Reference/SLComposeViewController_Class/Reference/Reference.html#//apple_ref/doc/uid/TP40012205
        
        [[(UIWindow*)[UIApplication sharedApplication].delegate window].rootViewController presentViewController:mySLComposerSheet animated:YES completion:nil];
    
        
        [mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
            NSString *output;
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    output = @"Action Cancelled";
                    
                    break;
                case SLComposeViewControllerResultDone: {
                    output = @"Post Successfull";
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook" message:output delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alert show];
                    break;
                }
                default:
                    break;
            } //check if everything worked properly. Give out a message on the state.
            
        }];
    } else {
        
    }
}

+ (void)postMessageToTwitter:(NSString*)message {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController* mySLComposerSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        [mySLComposerSheet setInitialText:message];
        [[(UIWindow*)[UIApplication sharedApplication].delegate window].rootViewController presentViewController:mySLComposerSheet animated:YES completion:nil];
    
    
    [mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
        NSString *output;
        switch (result) {
            case SLComposeViewControllerResultCancelled:
                output = @"Action Cancelled";
                break;
            case SLComposeViewControllerResultDone: {
                output = @"Post Successfull";
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter" message:output delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                break;
            }
            default:
                break;
        } //check if everything worked properly. Give out a message on the state.
        
    }];
    } else {
        
    }
}

@end
