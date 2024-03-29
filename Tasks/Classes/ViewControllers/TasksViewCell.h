//
//  TasksViewCell.h
//  Tasks
//
//  Created by Gonzalo Hardy on 2/4/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"

//150 is the space the other controllers in the cell use
#define CELL_ITEMS_HEIGHT 157

@interface TasksViewCell : UIViewController

@property (nonatomic, strong) IBOutlet UILabel* lblTitle;
@property (nonatomic, strong) IBOutlet UILabel* lblStats;
@property (nonatomic, strong) IBOutlet UILabel* lblDueDate;
@property (nonatomic, strong) IBOutlet UILabel* lblRepeatTimes;
@property (nonatomic, strong) IBOutlet UILabel* lblNote;
@property (nonatomic, strong) IBOutlet UIButton* doneButton;
@property (nonatomic, strong) IBOutlet UIButton* thumbImageButton;
@property (nonatomic, strong) IBOutlet UIButton* expandCollapseButton;
@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray* stars;
@property (nonatomic, strong) IBOutlet TTTAttributedLabel* lblDescription;
@property (nonatomic, strong) IBOutlet UIScrollView* descriptionScrollView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint* lblDescriptionHeightConstrait;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint* lblDescriptionScrollViewHeightConstrait;
@property (nonatomic, strong) IBOutlet UIImageView* statsImage;


@property (nonatomic) BOOL todayCell;

@end
