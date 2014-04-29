//
//  UserCellViewController.h
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 4/29/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "PopUpViewController.h"

@interface UserCellViewController : PopUpViewController

@property (nonatomic, weak) IBOutlet UIImageView* avatarImage;
@property (nonatomic, weak) IBOutlet UIImageView* disclosureImage;
@property (nonatomic, weak) IBOutlet UILabel* nameLabel;
@property (nonatomic, weak) IBOutlet UILabel* statsLabel;

@end
