//
//  EditDetailsViewController.h
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 3/27/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EditDetailsDelegate <NSObject>
@optional
- (void) hasSavedText:(NSAttributedString*) detailsText;

@end

@interface EditDetailsViewController : UIViewController

@property (nonatomic, weak) NSObject <EditDetailsDelegate>* delegate;
@property (nonatomic, strong) NSMutableAttributedString* textWithLinks;

@end
