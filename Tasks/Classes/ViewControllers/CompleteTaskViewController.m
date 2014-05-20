//
//  CompleteTaskViewController.m
//  self.tasks
//
//  Created by Gonzalo Hardy on 2/4/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "CompleteTaskViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SVWebViewController.h"
#import "MediaModel.h"
#import "TaskListModel.h"
#import "Constants.h"
#import "DeviceDetector.h"
#import "NotePopUpViewController.h"
#import "UsersModel.h"

#define SAHRE_TEXT [NSString stringWithFormat:@"#doitdoneit Done it. %@. %@",self.task.title, self.task.notes?self.task.notes:@""]

@interface CompleteTaskViewController () <PopUpDelegate>{
    IBOutlet UILabel* lblTitle;
    IBOutlet UILabel* lblStats;
    IBOutlet UILabel* lblDueDate;
    IBOutlet UILabel* lblRepeatTimes;
    IBOutlet UILabel* lblNotes;
    IBOutlet UIButton* thumbImageButton;
    IBOutlet UIView* socialView;
    IBOutlet UIImageView* imgStats;
    
    
    IBOutletCollection(UIButton) NSArray* ratingButtons;

    
    IBOutlet UIView* contentView;
    
    CGFloat scrollViewBottomSpaceConstantOriginalValue;
    
    
    NSInteger ratingTemp;
    BOOL textIsUp;
}

@end

@implementation CompleteTaskViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    
    lblTitle.text = self.task.title;
    
    thumbImageButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    if (self.task.thumbImagePath && ![@"" isEqualToString: self.task.thumbImagePath])
        [thumbImageButton setImage:self.task.thumbImage forState:UIControlStateNormal];
    else
        [thumbImageButton setImage:DEFAULT_TASK_IMAGE forState:UIControlStateNormal];
    thumbImageButton.layer.borderColor = YELLOW_COLOR.CGColor;
    thumbImageButton.layer.borderWidth = 2.0;
    thumbImageButton.layer.cornerRadius = 4;
    thumbImageButton.layer.masksToBounds = YES;
    
    imgStats.image = [self.task getHitRateImage];
    
    if (self.task.repeatTimes != 1) {
        lblRepeatTimes.text = [NSString stringWithFormat:@"%d of %d", (int)self.task.currentRepetition, (int)self.task.repeatTimes];
    } else {
        lblRepeatTimes.text = @"";
    }
    
    
    int remainingDays = ceil([self.task.dueDate timeIntervalSinceDate:[NSDate date]] /60.0 /60.0 /24.0);
    
    if (remainingDays == 1)
        lblDueDate.text = @"1 day left";
    else
        lblDueDate.text = [NSString stringWithFormat:@"%d days left",remainingDays];
    
    int timesDoneIt = [self.task.timesDoneIt[self.task.currentRepetition - 1] intValue];
    int timesMissedIt = [self.task.timesMissedIt[self.task.currentRepetition - 1] intValue];
    
    lblStats.text = [NSString stringWithFormat:@"Points:%ld done:%dx missed:%dx Hit: %.1f%%", (long)self.task.taskPoints, timesDoneIt, timesMissedIt, self.task.hitRate];
    
    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    socialView.hidden = [[UsersModel sharedInstance].logedUserData integerForKey:LOGGED_USER_PRIVATE_KEY];
    lblNotes.text = self.task.notes;
}


- (IBAction) ratingButtonPressed:(UIButton*) sender {
    [self setRating:(int)sender.tag];
}

- (void) setRating:(int)rating {
    int x = 0;
    for (; x < rating; x++) {
        [[ratingButtons objectAtIndex:x] setSelected:YES];
    }
    
    for (; x < ratingButtons.count; x++) {
        [[ratingButtons objectAtIndex:x] setSelected:NO];
    }
    
    ratingTemp = rating;
}

- (IBAction) skipTask {
    [[TaskListModel sharedInstance] missTask:self.task];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) completeTask {
    self.task.rating = ratingTemp;
    [[TaskListModel sharedInstance] completeTask:self.task];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) cancel {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) shareOnFacebook {
    [MediaModel postMessageToFacebook:SAHRE_TEXT];
}

- (IBAction) shareOnTwitter {
    [MediaModel postMessageToTwitter:SAHRE_TEXT];
}

- (IBAction) notesButtonPressed {
    NotePopUpViewController* noteVC = [self.storyboard instantiateViewControllerWithIdentifier:@"NotePopUpViewController"];
    noteVC.delegate = self;
    noteVC.task = self.task;
    [noteVC presentOnViewController:self];
}

#pragma mark - UITextField Methods
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString* newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    return newText.length <= TASK_NOTE_MAX_CHARACTERS;
}

#pragma mark - PopUpDelegate Methods
- (void) popUpWillClose {
    [self viewWillAppear:NO];
}
@end
