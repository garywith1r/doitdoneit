//
//  ZoomImageViewController.h
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 3/26/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ZoomImageDelegate <NSObject>

@optional
- (void) didEnterFullScreen;
- (void) didExitFullScreen;

@end

@interface ZoomImageViewController : UIViewController

@property (nonatomic, weak) NSObject <ZoomImageDelegate>* delegate;

+ (ZoomImageViewController*) expandImage:(UIImage*)image fromFrame:(CGRect)frame delegate:(NSObject <ZoomImageDelegate>*)delegate;


- (void) expandImage:(UIImage*)image fromFrame:(CGRect)frame animated:(BOOL)animated;
- (void) contractImageToOriginalFrameAnimated:(BOOL)animated;

@end
