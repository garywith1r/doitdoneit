//
//  AddEditUserViewController.h
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 4/8/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddEditUserDelegate <NSObject>

@optional
- (void) updatedUsersDictionary:(NSDictionary*)usersDictionary;

@end

@interface AddEditUserViewController : UIViewController

@property (nonatomic, assign) NSDictionary* usersDictionary;
@property (nonatomic, weak) NSObject <AddEditUserDelegate>* delegate;

@end
