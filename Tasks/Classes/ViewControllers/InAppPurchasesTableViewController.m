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

@interface InAppPurchasesTableViewController () <SKProductsRequestDelegate> {
    NSArray* inAppPurchasesDictionary;
    int selectedItem;
    SKProductsRequest *request;
}

@end

@implementation InAppPurchasesTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
     inAppPurchasesDictionary = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"InAppPurchases" ofType:@"plist"]];
    [self requestProductData];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PurchaseItemSegue"]) {
        InAppPurhcaseViewController* vc = (InAppPurhcaseViewController*)segue.destinationViewController;
        vc.inAppDictionary = [inAppPurchasesDictionary objectAtIndex:selectedItem];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [inAppPurchasesDictionary count];
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    inAppPurchaseTableViewCell* cell = (inAppPurchaseTableViewCell*) [tableView dequeueReusableCellWithIdentifier:@"inAppCell"];
    
    NSDictionary* inAppDictionary = inAppPurchasesDictionary[indexPath.row];
    
    cell.titleLabel.text = [inAppDictionary objectForKey:@"Name"];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectedItem = indexPath.row;
    [self performSegueWithIdentifier:@"PurchaseItemSegue" sender:nil];
}



- (void) requestProductData {
    request= [[SKProductsRequest alloc] initWithProductIdentifiers: [NSSet setWithObjects: @"com.is2c.doitdoneit.multiuser",@"multisuer",nil]];
    request.delegate = self;
    [request start];
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
