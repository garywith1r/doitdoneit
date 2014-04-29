//
//  NewUserPopUP.m
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 4/28/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "NewUserPopUP.h"
#import "EGOFileManager.h"
#import "UsersModel.h"
#import "Constants.h"

@interface NewUserPopUP () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    UIImagePickerController* _imagePickerController;
    UIPopoverController* popoverController;
    
    IBOutlet UIButton* btnImage;
    IBOutlet UITextField* txtName;
    IBOutlet UISwitch* parentUserSwitch;
    IBOutlet UILabel* parentUserLabel;
    UIImage* image;
}

@end

@implementation NewUserPopUP
@synthesize usersDictionary;

- (void)viewDidLoad {
    [super viewDidLoad];
    btnImage.layer.cornerRadius = 37;
    btnImage.layer.masksToBounds = YES;
    
    [txtName becomeFirstResponder];
    
    if (self.usersDictionary) {
        NSLog(@"%@",[self.usersDictionary objectForKey:LOGGED_USER_NAME_KEY]);
        txtName.text = [self.usersDictionary objectForKey:LOGGED_USER_NAME_KEY];
        NSString* imagePath = [self.usersDictionary objectForKey:LOGGED_USER_IMAGE_KEY];
        btnImage.imageView.contentMode = UIViewContentModeScaleAspectFill;
        
        if (imagePath) {
            image = [EGOFileManager getImageFromPath:imagePath];
            [btnImage setTitle:@"" forState:UIControlStateNormal];
            [btnImage setImage:image forState:UIControlStateNormal];
        } else {
            [btnImage setImage:DEFAULT_USER_IMAGE forState:UIControlStateNormal];
        }
        
    }
    
    parentUserLabel.hidden = parentUserSwitch.hidden = [UsersModel sharedInstance].purchasedParentsMode;
}

- (IBAction) doneButtonPressed {
    NSMutableDictionary* newUserDictionary = [[NSMutableDictionary alloc] initWithDictionary:self.usersDictionary];
    [newUserDictionary setObject:txtName.text forKey:LOGGED_USER_NAME_KEY];
    
    
    NSString* imagePath = [newUserDictionary objectForKey:LOGGED_USER_IMAGE_KEY];
    if (imagePath && ![@"" isEqualToString:imagePath])
        [EGOFileManager deleteContentAtPath:imagePath];
    [newUserDictionary removeObjectForKey:LOGGED_USER_IMAGE_KEY];
    
    if (image) {
        NSString* imagePath = [EGOFileManager storeImage:image];
        [newUserDictionary setObject:imagePath forKey:LOGGED_USER_IMAGE_KEY];
    }
    
    [[UsersModel sharedInstance] addUser:[NSDictionary dictionaryWithDictionary:newUserDictionary]];
    
    [super doneButtonPressed];
}


- (IBAction) closeButtonPressed {
    [super closeButtonPressed];
    [txtName resignFirstResponder];
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

#pragma mark - ActionSheet Delegate
//Takes the actionSheet's action when the user press "Photo"
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    _imagePickerController = [UIImagePickerController new];
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
	} else if(buttonIndex == 2) { //Clear Image
        [self clearPicture];
    }
}

- (void) clearPicture {
    [btnImage setImage:nil forState:UIControlStateNormal];
    [btnImage setImage:DEFAULT_USER_IMAGE forState:UIControlStateNormal];
}

#pragma mark - UIImagePickerControllerDelegate
-(void) imagePickerController: (UIImagePickerController *) picker didFinishPickingMediaWithInfo: (NSDictionary *) info {
    
    UIImage* thumbImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    
    if (thumbImage) {
        [btnImage setTitle:@"" forState:UIControlStateNormal];
        [btnImage setImage:thumbImage forState:UIControlStateNormal];
        image = thumbImage;
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



@end
