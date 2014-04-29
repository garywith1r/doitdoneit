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

    if (![RMStore canMakePayments]) return;
    
    NSString *productID = [self.inAppDictionary objectForKey:@"ProductId"];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [[RMStore defaultStore] addPayment:productID success:^(SKPaymentTransaction *transaction) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [self purchseSucseed];
    } failure:^(SKPaymentTransaction *transaction, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Payment Transaction Failed", @"")
                                                           message:NSLocalizedString(@"Please try again in a few moments", @"")
                                                          delegate:nil
                                                 cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                 otherButtonTitles:nil];
        [alerView show];
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
