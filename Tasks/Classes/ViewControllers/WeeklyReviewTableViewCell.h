//
//  WeeklyReviewTableViewCell.h
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 5/10/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WeeklyReviewTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel* taskTitle;
@property (nonatomic, weak) IBOutlet UILabel* taskStars;
@property (nonatomic, weak) IBOutlet UILabel* taskNote;
@end
