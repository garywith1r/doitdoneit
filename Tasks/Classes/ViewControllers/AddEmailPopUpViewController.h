//
//  AddEmailPopUpViewController.h
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 5/10/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "PopUpViewController.h"

@protocol AddEmailPopUpViewDelegate <NSObject>

@optional
- (void) doneWithEmail:(NSString*)email;

@end

@interface AddEmailPopUpViewController : PopUpViewController

@property (nonatomic, weak) NSObject <PopUpDelegate, AddEmailPopUpViewDelegate>* delegate;
@property (nonatomic, strong) NSString* email;

@end
