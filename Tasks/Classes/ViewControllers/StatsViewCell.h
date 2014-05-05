//
//  StatsTableViewCell.h
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 5/5/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StatsViewCell : UIViewController
@property (nonatomic, weak) IBOutlet UILabel* awardLabel;
@property (nonatomic, weak) IBOutlet UILabel* awardDate;
@property (nonatomic, weak) IBOutlet UILabel* titleLabel;
@property (nonatomic, weak) IBOutlet UILabel* tasksLabel;
@property (nonatomic, weak) IBOutlet UILabel* pointsLabel;
@property (nonatomic, weak) IBOutlet UILabel* hitRateLabel;

@property (nonatomic, weak) IBOutlet UIImageView* image;

@end
