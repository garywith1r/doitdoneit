//
//  InAppPurchasesTableViewController.m
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 4/25/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "InAppPurchasesTableViewController.h"
#import "inAppPurchaseTableViewCell.h"
#import "InAppPurhcaseViewController.h"
#import <StoreKit/StoreKit.h>
#import "RMStore.h"

@interface InAppPurchasesTableViewController () <SKProductsRequestDelegate> {
    NSArray* inAppPurchasesDictionaries;
    NSInteger selectedItem;
    SKProductsRequest *request;
}

@end

@implementation InAppPurchasesTableViewController

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
    inAppPurchaseTableViewCell* cell = (inAppPurchaseTableViewCell*) [tableView dequeueReusableCellWithIdentifier:@"inAppCell"];
    
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
    
    [[RMStore defaultStore] requestProducts:[NSSet setWithArray:products] success:^(NSArray *products, NSArray *invalidProductIdentifiers) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    } failure:^(NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Products Request Failed", @"")
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                  otherButtonTitles:nil];
        [alertView show];
    }];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse: (SKProductsResponse *)response {
    NSArray *myProduct = response.products;
    NSArray *invalid = response.invalidProductIdentifiers;
    // populate UI
    NSLog(@"product: %@",myProduct);
    NSLog(@"invalid product: %@",invalid);
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"%@",error);
}

@end
