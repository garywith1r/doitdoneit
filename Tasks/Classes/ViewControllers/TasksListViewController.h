//
//  ViewController.h
//  Tasks
//
//  Created by Gonzalo Hardy on 2/4/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import <UIKit/UIKit.h>

#define NORMAL_ROW_HEIGHT 60.0
#define EXPANDED_ROW_HEIGHT 313.0


@interface TasksListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    NSArray* contentDataArray;
    IBOutlet UITableView* table;
    
    int tagToDeleteIndex;
    int selectedRow;
}

- (void) deleteTaskOnMarkedPosition;
- (NSAttributedString*) stringWithBoldPart:(NSString*)boldPart andNormalPart:(NSString*)normalPart;

@end
