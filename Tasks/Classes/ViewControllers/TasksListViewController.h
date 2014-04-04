//
//  ViewController.h
//  Tasks
//
//  Created by Gonzalo Hardy on 2/4/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DAAttributedLabel.h"


#define NORMAL_ROW_HEIGHT 60.0
#define EXPANDED_ROW_HEIGHT 168.0

#define THUMBNAIL_FRAME CGRectMake (7,5,0,0)



@interface TasksListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, DAAttributedLabelDelegate> {
    NSArray* contentDataArray;
    IBOutlet UITableView* table;
    
    int tagToDeleteIndex;
    NSInteger selectedRow;
}

@property (nonatomic, weak) UINavigationController* navController;

- (void) deleteTaskOnMarkedPosition;
- (NSAttributedString*) stringWithBoldPart:(NSString*)boldPart andNormalPart:(NSString*)normalPart;



- (void) thumbnailTapped:(UIButton*)sender;
- (void) hideSelectedRow:(UIButton*)sender;

- (void) showTaskAtRow:(NSInteger)row;



@end
