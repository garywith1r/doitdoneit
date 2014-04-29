//
//  InAppPurhcaseViewController.m
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 4/25/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "InAppPurhcaseViewController.h"
#import "RMStore.h"
#import "UsersModel.h"


@interface InAppPurhcaseViewController () {
    IBOutlet UILabel* lblTitle;
    IBOutlet UILabel* lblDescription;
}

@end

@implementation InAppPurhcaseViewController
@synthesize inAppDictionary;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    lblTitle.text = [self.inAppDictionary objectForKey:@"Name"];
    lblDescription.text = [self.inAppDictionary objectForKey:@"Description"];
}


- (IBAction) purchaseButtonPressed {

    [[RMStore defaultStore] addPayment:[self.inAppDictionary objectForKey:@"ProductId"] success:^(SKPaymentTransaction *transaction) {
        NSLog(@"Purchased!");
        [self purchseSucseed];
    } failure:^(SKPaymentTransaction *transaction, NSError *error) {
        NSLog(@"Something went wrong");
    }];
}

- (IBAction) cancelButtonPressed {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void) purchseSucseed {
    NSInteger code = [[self.inAppDictionary objectForKey:@"Code"] integerValue];
    
    switch (code) {
        case 0: //Pro
        case 1: { //Family
            [[UsersModel sharedInstance] familyUpgradePurchased];
            [self performSegueWithIdentifier:@"SetUpParentsPincode" sender:nil];
        }
        case 2: //Multiuser
            [[UsersModel sharedInstance] multiuserUpgradePurchased];
        case 3: //Weekly Review
            [[UsersModel sharedInstance] weeklyReviewUpgradePurchased];
        case 4: //Remove Ads
            [[UsersModel sharedInstance] removeAdsUpgradePurchased];
    }
}



@end
