//
//  UsersModel.h
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 4/8/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSMutableDictionary+NumbersStoring.h"

#define LOGGED_USER_IMAGE_KEY @"loggedUserImage"
#define LOGGED_USER_NAME_KEY @"loggedUserName"

@interface UsersModel : NSObject

+ (UsersModel*) sharedInstance;

- (NSArray*) getUsers;

- (void) addUser:(NSDictionary*)userData;
- (void) saveUsersArray;
- (void) saveCurrentUserData;

- (void) changeToUserAtIndex:(NSInteger)index;

- (BOOL) currentUserCanCreateTasks;

@property (nonatomic, readonly) NSDictionary* logedUser;
@property (nonatomic, readonly) NSMutableDictionary* logedUserData;


@property (readonly) BOOL purchasedParentsMode;
@property (readonly) BOOL purchasedAddsFree;
@property (readonly) BOOL purchasedMultiUser;
@property (readonly) BOOL purchasedWeeklyReview;

@property BOOL parentsModeEnabled;
@property (nonatomic, strong) NSString* parentsPinCode;

@end
