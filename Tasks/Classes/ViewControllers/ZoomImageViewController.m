//
//  ZoomImageViewController.m
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 3/26/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "ZoomImageViewController.h"

@interface ZoomImageViewController () {
    IBOutlet UIImageView* imageView;
    IBOutlet UIButton* doneButton;
    CGRect originalFrame;
}

@end

@implementation ZoomImageViewController
@synthesize delegate;

+ (ZoomImageViewController*) expandImage:(UIImage*)image fromFrame:(CGRect)frame delegate:(NSObject <ZoomImageDelegate>*)delegate {
    NSString * storyboardName = @"Main_iPhone";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    
    ZoomImageViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"ZoomImageViewController"];
    vc.delegate = delegate;
    vc.view.clipsToBounds = YES;
    
    UIWindow* mainWindow = [[UIApplication sharedApplication] keyWindow];
    [mainWindow addSubview:vc.view];
    
    [vc expandImage:image fromFrame:frame animated:NO];
    
    return vc;
}

- (IBAction) doneButtonPressed {
    [self contractImageToOriginalFrameAnimated:YES];
}


- (void) expandImage:(UIImage*)image fromFrame:(CGRect)frame animated:(BOOL)animated {
    self.view.frame = frame;
    originalFrame = frame;
    imageView.image = image;
    
    if (animated) {
        [UIView beginAnimations:NULL context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(expandAnimationDidStop)];
        self.view.frame = [[UIApplication sharedApplication] keyWindow].frame;
        doneButton.alpha = 1;
        [UIView commitAnimations];
        
    } else {
        self.view.frame = [[UIApplication sharedApplication] keyWindow].frame;
        doneButton.alpha = 1;
    }
}

- (void) contractImageToOriginalFrameAnimated:(BOOL)animated {
    
    if (animated) {
        [UIView beginAnimations:NULL context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(contractAnimationDidStop)];
        self.view.frame = originalFrame;
        doneButton.alpha = 0;
        [UIView commitAnimations];
        
    } else {
        self.view.frame = originalFrame;
        doneButton.alpha = 0;
    }
}

- (void) expandAnimationDidStop {
    if ([self.delegate respondsToSelector:@selector(didEnterFullScreen)])
        [self.delegate didEnterFullScreen];
}

- (void) contractAnimationDidStop {
    if ([self.delegate respondsToSelector:@selector(didExitFullScreen)])
        [self.delegate didExitFullScreen];
}



@end
