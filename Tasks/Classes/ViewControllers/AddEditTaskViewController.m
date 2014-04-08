//
//  TaskViewController.m
//  Tasks
//
//  Created by Gonzalo Hardy on 2/4/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "AddEditTaskViewController.h"
#import "SelectDateViewController.h"
#import "TaskListModel.h"
#import "DeviceDetector.h"
#import "Constants.h"
#import "StatsModel.h"
#import "EditDetailsViewController.h"
#import "DAAttributedLabel.h"
#import "SVWebViewController.h"


#import <MobileCoreServices/UTCoreTypes.h>
#import <MediaPlayer/MediaPlayer.h>



#define SELECT_DATE_SEGUE @"SelectDatesSegue"
#define EDIT_DETAILS_SEGUE @"EditDetailsSegue"



@interface AddEditTaskViewController () <SelectDateDelegate, DAAttributedLabelDelegate, UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    IBOutlet UIView* newTaskDetailsView;
    IBOutlet UITextField* txtTitle;
    IBOutlet UITextField* txtRepeatTimes;
    IBOutlet UILabel* lblTitle;
    IBOutlet UILabel* lblRepeatTimes;
    IBOutlet UISegmentedControl* sgmRepeatInterval;
    IBOutlet UISlider* sldTaskPoints;
    IBOutlet UILabel* lblTaskPoints;
    IBOutlet UILabel* dueDate;
    IBOutlet UIButton* btnImage;
    IBOutlet DAAttributedLabel* lblDetails;
    
    IBOutlet UIView* completeTaskDetailsView;
    IBOutletCollection(UIButton) NSArray* ratingButtons;
    IBOutlet UITextField* txtNotes;
    IBOutlet UILabel* doneDate;
    IBOutlet UILabel* lblInfo;
    
    IBOutlet NSLayoutConstraint* scrollViewHeightConstrait;
    IBOutlet NSLayoutConstraint* contentViewHeightConstrait;
    
    BOOL selectingDueDate;
    BOOL keyboardIsUp;
    
    NSDate* dueDateTemp;
    NSDate* completitionDateTemp;
    NSInteger ratingTemp;
    
    UIPopoverController* popoverController;
    UIImagePickerController *_imagePickerController;
}
@end

@implementation AddEditTaskViewController
@synthesize task;

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:SELECT_DATE_SEGUE]) {
        SelectDateViewController* editController = (SelectDateViewController*) [segue destinationViewController];
        editController.delegate = self;
        if (selectingDueDate)
            editController.startDate = dueDateTemp;
        else
            editController.startDate = completitionDateTemp;
    } else if ([segue.identifier isEqualToString:EDIT_DETAILS_SEGUE]) {
        EditDetailsViewController* editController = (EditDetailsViewController*) [segue destinationViewController];
        editController.dto = task;
    }
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    if (!self.task) {
        self.task = [[TaskDTO alloc] init];
        self.isNewTask = YES;
    }
    
    lblTitle.text = txtTitle.text = self.task.title;
    lblDetails.delegate = self;
    
    lblRepeatTimes.text = txtRepeatTimes.text = [NSString stringWithFormat:@"%d",(int)self.task.repeatTimes];
    sgmRepeatInterval.selectedSegmentIndex = self.task.repeatPeriod;
    sldTaskPoints.value = self.task.taskPoints;
    [self sliderHasChanged:sldTaskPoints];
    
    if (task.thumbImage) {
        [btnImage setTitle:@"" forState:UIControlStateNormal];
        btnImage.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [btnImage setImage:task.thumbImage forState:UIControlStateNormal];
    }
    
    if (self.task.status == TaskStatusIncomplete) {
        completeTaskDetailsView.hidden = YES;
        contentViewHeightConstrait.constant = contentViewHeightConstrait.constant - completeTaskDetailsView.frame.size.height;
    } else {
        newTaskDetailsView.userInteractionEnabled = NO;
        
        txtTitle.hidden = txtRepeatTimes.hidden = YES;
        lblTitle.hidden = lblRepeatTimes.hidden = NO;
        
        [self setRating:(int)self.task.rating];
        txtNotes.text = self.task.notes;
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM/dd/yy"];
        
        int timesDoneIt = [task.timesDoneIt[task.currentRepetition - 1] intValue];
        int timesMissedIt = [task.timesMissedIt[task.currentRepetition - 1] intValue];
        
        lblInfo.text = [NSString stringWithFormat:@"Created: %@ Done: %dx\nMissed: %dx Hit: %.1f%%",[formatter stringFromDate:task.creationDate], timesDoneIt, timesMissedIt, [task hitRate]];
    }
    
    dueDateTemp = self.task.dueDate;
    completitionDateTemp = self.task.completitionDate;
    
    scrollViewHeightConstrait.constant = self.view.frame.size.height;
    
    if (SYSTEM_VERSION_LESS_THAN(@"7.0"))
        scrollViewHeightConstrait.constant -= (self.tabBarController.tabBar.frame.size.height + self.navigationController.navigationBar.frame.size.height);
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	// Do any additional setup after loading the view.
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:DATE_FORMAT];
    
    if (self.task.dueDate) {
        dueDate.text = [formatter stringFromDate:dueDateTemp];
    }
    
    if (self.task.completitionDate) {
        doneDate.text = [formatter stringFromDate:completitionDateTemp];
    }
    
    lblDetails.text = self.task.detailsText;
    
}

- (IBAction) sliderHasChanged :(id)sender {
    lblTaskPoints.text = [NSString stringWithFormat:@"%ld",lroundf(sldTaskPoints.value)];
}

- (IBAction) saveButtonPressed {
    
    if ([txtTitle.text isEqualToString:@""]) {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Plese enter a title for the task." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return;
    }
    
    if ([txtRepeatTimes.text intValue] == 0) {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Plese provide a valid amount of repetitions" delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return;
    }
    
    self.task.title = txtTitle.text;
    self.task.repeatTimes = [txtRepeatTimes.text intValue];
    
    self.task.repeatPeriod = (int)sgmRepeatInterval.selectedSegmentIndex;
    self.task.taskPoints = lroundf(sldTaskPoints.value);
    
    self.task.notes = txtNotes.text;
    
    self.task.dueDate = dueDateTemp;
    self.task.completitionDate = completitionDateTemp;
    self.task.rating = ratingTemp;
    
    if (self.isNewTask) {
        [[TaskListModel sharedInstance] addTask:self.task];
    } else {
        [[TaskListModel sharedInstance] forceRecalculateTasks];
        if (self.task.status == TaskStatusComplete)
            [[StatsModel sharedInstance] recalculateVolatileStats];
        [[TaskListModel sharedInstance] storeData];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (IBAction) changeDueDate {
    selectingDueDate = YES;
    [self performSegueWithIdentifier:SELECT_DATE_SEGUE sender: self];
}

- (IBAction) changeCompletitionDate {
    selectingDueDate = NO;
    [self performSegueWithIdentifier:SELECT_DATE_SEGUE sender: self];
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


#pragma mark - SelectDateDelegate Methods
- (void) didSelectDate:(NSDate *)date {
    if (selectingDueDate)
        dueDateTemp = date;
    else
        completitionDateTemp = date;
}

#pragma mark - UITextField Methods 

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString* newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (textField == txtTitle) {
        return newText.length <= TASK_TITLE_MAX_CHARACTERS;
    } else if (textField == txtNotes) {
        return newText.length <= TASK_NOTE_MAX_CHARACTERS;
    }
    
    return YES;
}

- (IBAction) textEditingBegun {
    if (!keyboardIsUp) {
        [UIView beginAnimations:Nil context:nil];
        [UIView setAnimationDuration:0.3];
        scrollViewHeightConstrait.constant = scrollViewHeightConstrait.constant - KEYBOARD_SIZE;
        [UIView commitAnimations];
        keyboardIsUp = YES;
    }
}


- (IBAction) textEditingEnd {
    if (keyboardIsUp) {
        [UIView beginAnimations:Nil context:nil];
        [UIView setAnimationDuration:0.3];
        scrollViewHeightConstrait.constant = scrollViewHeightConstrait.constant + KEYBOARD_SIZE;
        [UIView commitAnimations];
        keyboardIsUp = NO;
    }
}

- (IBAction) updatePicture:(UIButton *)sender {
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        // open a dialog with two custom buttons
        UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:NSLocalizedString(@"Take Photo", nil),
                                      NSLocalizedString(@"Choose Existing Photo", nil), nil];
        
        actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
        
        if (IPAD)
            [actionSheet showInView:self.view];
        else
            [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
        
    } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        [self actionSheet:nil clickedButtonAtIndex:1];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:NSLocalizedString(@"Your device doesn't have camera", nil)
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (IBAction) clearPicture {
    [btnImage setImage:nil forState:UIControlStateNormal];
    task.thumbImage = nil;
    task.videoUrl = nil;
    
    [btnImage setTitle:@"Import" forState:UIControlStateNormal];
}

#pragma mark - ActionSheet Delegate
//Takes the actionSheet's action when the user press "Photo"
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    _imagePickerController = [UIImagePickerController new];
    _imagePickerController.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie,kUTTypeImage, nil];
    _imagePickerController.delegate = self;
    
	if (buttonIndex == 0){ //Camara
		_imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:_imagePickerController animated:YES completion:^{}];
	} else if(buttonIndex == 1){ //Existing Photo
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            
            _imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            
            
            UIViewController *containerController = [[UIViewController alloc] init];
            containerController.contentSizeForViewInPopover = CGSizeMake(768, 1000);
            
            [containerController.view addSubview:_imagePickerController.view];
            
            if (IPAD) {
                Class cls = NSClassFromString(@"UIPopoverController");
                if (cls != nil) {
                    popoverController = [[UIPopoverController alloc] initWithContentViewController:containerController];
                    
                    [popoverController presentPopoverFromRect:CGRectMake(0, 0, 250, 300) inView:self.view permittedArrowDirections:4 animated:YES];
                    
                    
                    [_imagePickerController.view setFrame:containerController.view.frame];
                }
            } else
                [self presentViewController:_imagePickerController animated:YES completion:^{}];
        }
	}
}


#pragma mark - UIImagePickerControllerDelegate
-(void) imagePickerController: (UIImagePickerController *) picker didFinishPickingMediaWithInfo: (NSDictionary *) info {
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    
    UIImage* thumbImage;
    
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeMovie, 0)
        == kCFCompareEqualTo)
    {
        

        NSURL* url = [info objectForKey:UIImagePickerControllerMediaURL];
        
        
        //get thumbnail image
        MPMoviePlayerController *theMovie = [[MPMoviePlayerController alloc] initWithContentURL:url];
        theMovie.view.frame = self.view.bounds;
        theMovie.controlStyle = MPMovieControlStyleNone;
        theMovie.shouldAutoplay=NO;
        thumbImage = [theMovie thumbnailImageAtTime:0 timeOption:MPMovieTimeOptionExact];
        
        
        //save video to app's directory.
        NSData *videoData = [NSData dataWithContentsOfURL:url];
        [[NSFileManager defaultManager] createFileAtPath:[task forceVideoUrl] contents:videoData attributes:nil];
        
    } else {
        thumbImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        task.videoUrl = nil;
    }
    
    
    if (thumbImage) {
        [btnImage setTitle:@"" forState:UIControlStateNormal];
        btnImage.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [btnImage setImage:thumbImage forState:UIControlStateNormal];
        
        task.thumbImage = thumbImage;
    }
    
    
    //close picker and popover;
    [self imagePickerControllerDidCancel:picker];
    
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    if (popoverController) {
        [popoverController dismissPopoverAnimated:YES];
        popoverController = nil;
    } else {
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}


#pragma mark - DAAttributedLabelDelegate Methods
- (void) label:(DAAttributedLabel *)label didSelectLink:(NSInteger)linkNum
{
    NSString* url = task.detailsLinksArray[linkNum];
    
    NSRange prefixRange = [url rangeOfString:@"http"
                                     options:(NSAnchoredSearch | NSCaseInsensitiveSearch)];
    
    if (prefixRange.location == NSNotFound) {
        url = [@"http://" stringByAppendingString:url];
    }
    
	SVWebViewController *webViewController = [[SVWebViewController alloc] initWithAddress:url];
    [self.navigationController pushViewController:webViewController animated:YES];
}


@end
