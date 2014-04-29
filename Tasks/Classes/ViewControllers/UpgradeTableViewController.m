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

@interface UpgradeTableViewController () <SKProductsRequestDelegate> {
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

@end
