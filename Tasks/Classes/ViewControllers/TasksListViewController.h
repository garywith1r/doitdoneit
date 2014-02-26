//
//  ViewController.h
//  Tasks
//
//  Created by Gonzalo Hardy on 2/4/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TasksListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    NSArray* contentDataArray;
    IBOutlet UITableView* table;
}


- (NSAttributedString*) stringWithBoldPart:(NSString*)boldPart andNormalPart:(NSString*)normalPart;

@end
