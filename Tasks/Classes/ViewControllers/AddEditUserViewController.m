//
//  AddEditUserViewController.m
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 4/8/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "AddEditUserViewController.h"
#import "Constants.h"
#import "UsersModel.h"
#import "EGOFileManager.h"

@interface AddEditUserViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>{
    UIImagePickerController* _imagePickerController;
    UIPopoverController* popoverController;
    
    IBOutlet UIButton* btnImage;
    IBOutlet UITextField* txtName;
    UIImage* image;
}

@end

@implementation AddEditUserViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (self.usersDictionary) {
        NSLog(@"%@",[self.usersDictionary objectForKey:LOGGED_USER_NAME_KEY]);
        txtName.text = [self.usersDictionary objectForKey:LOGGED_USER_NAME_KEY];
        NSString* imagePath = [self.usersDictionary objectForKey:LOGGED_USER_IMAGE_KEY];
        if (imagePath) {
            image = [EGOFileManager getImageFromPath:imagePath];
            [btnImage setTitle:@"" forState:UIControlStateNormal];
            btnImage.imageView.contentMode = UIViewContentModeScaleAspectFit;
            [btnImage setImage:image forState:UIControlStateNormal];
        }
        
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    NSArray *viewControllers = self.navigationController.viewControllers;
    
    if ([viewControllers indexOfObject:self] == NSNotFound) { //view is being poped.
        NSMutableDictionary* newUserDictionary = [[NSMutableDictionary alloc] initWithDictionary:self.usersDictionary];
        [newUserDictionary setObject:txtName.text forKey:LOGGED_USER_NAME_KEY];
        
        if (image) {
            NSString* imagePath = [EGOFileManager storeImage:image];
            [newUserDictionary setObject:imagePath forKey:LOGGED_USER_IMAGE_KEY];
        } else {
            NSString* imagePath = [newUserDictionary objectForKey:LOGGED_USER_IMAGE_KEY];
            if (imagePath)
                [EGOFileManager deleteContentAtPath:imagePath];
            [newUserDictionary removeObjectForKey:LOGGED_USER_IMAGE_KEY];
        }
        
        [[UsersModel sharedInstance] addUser:[NSDictionary dictionaryWithDictionary:newUserDictionary]];
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
	}
}


#pragma mark - UIImagePickerControllerDelegate
-(void) imagePickerController: (UIImagePickerController *) picker didFinishPickingMediaWithInfo: (NSDictionary *) info {
    
    UIImage* thumbImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    
    if (thumbImage) {
        [btnImage setTitle:@"" forState:UIControlStateNormal];
        btnImage.imageView.contentMode = UIViewContentModeScaleAspectFit;
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
