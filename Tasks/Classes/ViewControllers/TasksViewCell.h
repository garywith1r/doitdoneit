//
//  TasksViewCell.h
//  Tasks
//
//  Created by Gonzalo Hardy on 2/4/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TasksViewCell : UIViewController

@property (nonatomic, strong) IBOutlet UILabel* lblTitle;
@property (nonatomic, strong) IBOutlet UILabel* dueDate;
@property (nonatomic, strong) IBOutlet UIButton* doneButton;

@property (nonatomic) BOOL todayCell;

@end
