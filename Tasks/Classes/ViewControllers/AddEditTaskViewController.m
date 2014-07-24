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
#import "SVWebViewController.h"
#import "NotePopUpViewController.h"
#import "SelectRepeatTimesViewController.h"
#import "TTTAttributedLabel.h"


#import <MobileCoreServices/UTCoreTypes.h>



#define SELECT_DATE_SEGUE @"SelectDatesSegue"
#define EDIT_DETAILS_SEGUE @"EditDetailsSegue"



@interface AddEditTaskViewController () <SelectDateDelegate, TTTAttributedLabelDelegate, PopUpDelegate, SelectRepeatTimesDelegate, UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    IBOutlet UIView* newTaskDetailsView;
    IBOutlet UITextField* txtTitle;
    IBOutlet UILabel* lblRepeatTimes;
    IBOutlet UISlider* sldTaskPoints;
    IBOutlet UILabel* lblTaskPoints;
    IBOutlet UILabel* dueDate;
    IBOutlet UIButton* btnImage;
    IBOutlet TTTAttributedLabel* lblDetails;
    IBOutletCollection(UIImageView) NSArray* newTaskGoImages;
    
    IBOutlet UIView* completeTaskDetailsView;
    IBOutletCollection(UIButton) NSArray* ratingButtons;
    IBOutlet UILabel* lblNotes;
    IBOutlet UILabel* doneDate;
    IBOutlet UILabel* lblInfo;

    
    
    IBOutlet UIView* buttonsView;
    
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
    if ([segue.identifier isEqualToString:EDIT_DETAILS_SEGUE]) {
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
    
    txtTitle.text = self.task.title;
    lblDetails.delegate = self;
    lblDetails.highlightedTextColor = YELLOW_COLOR;
    
    lblRepeatTimes.text = [self.task repeatTimesDisplayText];
    sldTaskPoints.value = self.task.taskPoints;
    [self sliderHasChanged:sldTaskPoints];
    
    btnImage.layer.borderColor = YELLOW_COLOR.CGColor;
    btnImage.layer.borderWidth = 2.0;
    btnImage.layer.cornerRadius = 4;
    btnImage.layer.masksToBounds = YES;
    
    if (task.thumbImage) {
        btnImage.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [btnImage setImage:task.thumbImage forState:UIControlStateNormal];
    }
    
    if (self.task.status == TaskStatusIncomplete) {
        completeTaskDetailsView.hidden = YES;
        [txtTitle becomeFirstResponder];
    } else {
        newTaskDetailsView.userInteractionEnabled = NO;
        
        [self setRating:(int)self.task.rating];
        lblNotes.text = self.task.notes;
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM/dd/yy"];
        
        int timesDoneIt = [task.timesDoneIt[task.currentRepetition - 1] intValue];
        int timesMissedIt = [task.timesMissedIt[task.currentRepetition - 1] intValue];
        
        lblInfo.text = [NSString stringWithFormat:@"Created: %@ Done: %dx\nMissed: %dx Hit: %.1f%%",[formatter stringFromDate:task.creationDate], timesDoneIt, timesMissedIt, [task hitRate]];
        
        for (UIImageView* image in newTaskGoImages) {
            image.hidden = YES;
        }
    }
    
    dueDateTemp = self.task.dueDate;
    completitionDateTemp = self.task.completitionDate;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:DATE_FORMAT];
    
    if (self.task.dueDate) {
        dueDate.text = [formatter stringFromDate:dueDateTemp];
    }
    
    if (self.task.completitionDate) {
        doneDate.text = [formatter stringFromDate:completitionDateTemp];
    }
    
    lblDetails.text = self.task.detailsText;
    lblNotes.text = self.task.notes;
    
}

- (IBAction) sliderHasChanged :(id)sender {
    lblTaskPoints.text = [NSString stringWithFormat:@"%ld",lroundf(sldTaskPoints.value)];
}

- (IBAction) repeatTimesButtonPressed {
    SelectRepeatTimesViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectRepeatTimesViewController"];
    [vc setInitialTimes:self.task.repeatTimes andInitialTimeInterval:self.task.repeatPeriod];
    vc.delegate = self;
    
    UINavigationController* mainVC = (UINavigationController*)[[[UIApplication sharedApplication] keyWindow] rootViewController];
    [vc presentOnViewController:mainVC];
    [txtTitle resignFirstResponder];
}

- (IBAction) saveButtonPressed {
    
    if ([txtTitle.text isEqualToString:@""]) {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Plese enter a title for the task." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return;
    }
    
    self.task.title = txtTitle.text;
    
    self.task.taskPoints = lroundf(sldTaskPoints.value);
    
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

- (IBAction) cancelButtonPressed {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) changeDueDate {
    selectingDueDate = YES;
    SelectDateViewController* editController = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectDateViewController"];
    editController.delegate = self;
    editController.startDate = dueDateTemp;
    [self.navigationController pushViewController:editController animated:YES];
}

- (IBAction) changeCompletitionDate {
    selectingDueDate = NO;
    SelectDateViewController* editController = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectDateViewController"];
    editController.delegate = self;
    editController.startDate = dueDateTemp;
    [self.navigationController pushViewController:editController animated:YES];
}

- (IBAction) notesButtonPressed {
    NotePopUpViewController* noteVC = [self.storyboard instantiateViewControllerWithIdentifier:@"NotePopUpViewController"];
    noteVC.delegate = self;
    noteVC.task = task;
    [noteVC presentOnViewController:self];
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
    }
    
    return YES;
}

- (IBAction) updatePicture:(UIButton *)sender {
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        // open a dialog with two custom buttons
        UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:NSLocalizedString(@"Take Photo", nil),
                                      NSLocalizedString(@"Choose Existing Photo", nil), NSLocalizedString(@"Clear", nil), nil];
        
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

- (void) clearPicture {
    [btnImage setImage:nil forState:UIControlStateNormal];
    task.thumbImage = nil;
    task.videoUrl = nil;
    
    btnImage.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [btnImage setImage:task.thumbImage forState:UIControlStateNormal];
}

- (IBAction) textEditingEnd {}

#pragma mark - ActionSheet Delegate
//Takes the actionSheet's action when the user press "Photo"
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    _imagePickerController = [UIImagePickerController new];
    _imagePickerController.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie,kUTTypeImage, nil];
    _imagePickerController.delegate = self;
    
	if (buttonIndex == 0) { //Camara
		_imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:_imagePickerController animated:YES completion:^{}];
        
        
	} else if(buttonIndex == 1) { //Existing Photo
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            
            _imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            
            
            UIViewController *containerController = [[UIViewController alloc] init];
            containerController.preferredContentSize = CGSizeMake(768, 1000);
            
            [containerController.view addSubview:_imagePickerController.view];
            
            if (IPAD) {
                Class cls = NSClassFromString(@"UIPopoverController");
                if (cls != nil) {
                    popoverController = [[UIPopoverController alloc] initWithContentViewController:containerController];
                    
                    [popoverController presentPopoverFromRect:CGRectMake(0, 0, 250, 300) inView:self.view permittedArrowDirections:4 animated:YES];
                    
                    
                    [_imagePickerController.view setFrame:containerController.view.frame];
                }
            } else {
                [self presentViewController:_imagePickerController animated:YES completion:^{}];
            }
        }
        
        
	} else if(buttonIndex == 2) { //Clear Image
        [self clearPicture];
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
        
        
        [task addVideoFromUrl:url];
        thumbImage = task.thumbImage;
        
    } else {
        thumbImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        task.videoUrl = nil;
    }
    
    
    if (thumbImage) {
        btnImage.imageView.contentMode = UIViewContentModeScaleAspectFill;
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


#pragma mark - TTTAttributedLabelDelegate Methods
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    NSString* stringUrl = [url absoluteString];
    
    NSRange prefixRange = [stringUrl rangeOfString:@"http"
                                     options:(NSAnchoredSearch | NSCaseInsensitiveSearch)];
    
    if (prefixRange.location == NSNotFound) {
        stringUrl = [@"http://" stringByAppendingString:stringUrl];
    }
    
	SVWebViewController *webViewController = [[SVWebViewController alloc] initWithAddress:stringUrl];
    UINavigationController* mainVC = (UINavigationController*)[[[UIApplication sharedApplication] keyWindow] rootViewController];
    [mainVC pushViewController:webViewController animated:YES];
}


#pragma mark - PopUpDelegate Methods
- (void) popUpWillClose {
    [self viewWillAppear:NO];
}

#pragma mark - SelectRepeatTimesDelegate methods
- (void) selectedRepeatTimes:(NSInteger)repeatTimes perTimeInterval:(NSInteger)timeInterval {
    self.task.repeatTimes = repeatTimes;
    self.task.repeatPeriod = (int)timeInterval;
    
    lblRepeatTimes.text = [self.task repeatTimesDisplayText];
}

@end
