//
//  InAppPurchasesTableViewController.m
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 4/25/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "UpgradeTableViewController.h"
#import "UpgradeTableViewCell.h"
#import "InAppPurhcaseViewController.h"
#import <StoreKit/StoreKit.h>
#import "RMStore.h"
#import "UsersModel.h"

@interface UpgradeTableViewController () <TransactionRestoreDelegate, UITableViewDataSource, UITableViewDelegate> {
    NSArray* inAppPurchasesDictionaries;
    NSInteger selectedItem;
    SKProductsRequest *request;
}

@end

@implementation UpgradeTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
     inAppPurchasesDictionaries = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"InAppPurchases" ofType:@"plist"]];
    [self requestProductData];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PurchaseItemSegue"]) {
        InAppPurhcaseViewController* vc = (InAppPurhcaseViewController*)segue.destinationViewController;
        vc.inAppDictionary = [inAppPurchasesDictionaries objectAtIndex:selectedItem];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [inAppPurchasesDictionaries count];
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UpgradeTableViewCell* cell = (UpgradeTableViewCell*) [tableView dequeueReusableCellWithIdentifier:@"inAppCell"];
    
    NSDictionary* inAppDictionary = inAppPurchasesDictionaries[indexPath.row];
    
    cell.titleLabel.text = [inAppDictionary objectForKey:@"Name"];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectedItem = indexPath.row;
    [self performSegueWithIdentifier:@"PurchaseItemSegue" sender:nil];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void) requestProductData {
    NSMutableArray* products = [NSMutableArray arrayWithCapacity:inAppPurchasesDictionaries.count];
    
    for (NSDictionary* userDict in inAppPurchasesDictionaries) {
        [products addObject:[userDict objectForKey:@"ProductId"]];
    }
    
    //Without this I can't make the purchases at next screen work.
    [[RMStore defaultStore] requestProducts:[NSSet setWithArray:products] success:^(NSArray *products, NSArray *invalidProductIdentifiers) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    } failure:^(NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
}



- (IBAction) restorePurchases {
    [RMStore defaultStore].transactionRestoreDelegate = self;
    [[RMStore defaultStore] restoreTransactions];
}

#pragma mark - TransactionRestoreDelegate Methods
- (void) didRestoreTransaction:(SKPaymentTransaction *)transaction {
    NSString* productId = transaction.originalTransaction.payment.productIdentifier;
    for (NSDictionary* inAppDic in inAppPurchasesDictionaries) {
        if ([productId isEqualToString:[inAppDic objectForKey:@"ProductId"]]) {
            NSInteger code = [[inAppDic objectForKey:@"Code"] integerValue];
            
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
    }
}

@end
