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

@interface InAppPurchasesTableViewController () {
    NSArray* inAppPurchasesDictionary;
    int selectedItem;
}

@end

@implementation InAppPurchasesTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
     inAppPurchasesDictionary = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"InAppPurchases" ofType:@"plist"]];
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

@end
