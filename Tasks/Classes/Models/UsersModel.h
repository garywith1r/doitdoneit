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

//this keys are for loggedUserData dictionary.
#define LOGGED_USER_GOAL_KEY @"loggedUserGoal"
#define LOGGED_USER_GOAL_DESCRIPTION_KEY @"loggedUserGoalDescription"
#define LOGGED_USER_REMINDERS_KEY @"loggedUserReminder"
#define LOGGED_USER_PRIVATE_KEY @"loggedUserHasPrivatedAccount"
#define LOGGED_USER_LAST_LOGGIN @"loggedUserLastLoggin"
#define LOGGED_USER_RECIPIENTS_LIST @"loggedUserWeeklyRecipients"

#define TASKS_ARRAY_KEY @"tasksList"
#define COMPLETED_TASKS_ARRAY_KEY @"completedTasksList"
#define MISSED_TASKS_ARRAY_KEY  @"missedTasksList"

@interface UsersModel : NSObject

+ (UsersModel*) sharedInstance;

- (NSArray*) getUsers;

- (void) addUser:(NSDictionary*)userData;
- (void) deleteUserAtIndex:(NSInteger)index;
- (void) saveUsersArray;
- (void) saveCurrentUserData;

- (void) changeToUserAtIndex:(NSInteger)index;

- (BOOL) currentUserCanCreateTasks;


- (void) removeAdsUpgradePurchased;
- (void) weeklyReviewUpgradePurchased;
- (void) multiuserUpgradePurchased;
- (void) familyUpgradePurchased;

- (void) addRemindersForMainTask;
- (void) removeTodaysReminders;

- (void) prepareForBackground;

@property (nonatomic, readonly) NSDictionary* logedUser;
@property (nonatomic, readonly) NSMutableDictionary* logedUserData;


@property (readonly) BOOL purchasedParentsMode;
@property (readonly) BOOL purchasedAddsFree;
@property (readonly) BOOL purchasedMultiUser;
@property (readonly) BOOL purchasedWeeklyReview;

@property BOOL parentsModeActive; //this option enables the current user to create / delete tasks.
@property BOOL parentsModeEnabled; //this option enables/disables the whole feature.
@property (nonatomic, strong) NSString* parentsPinCode;

@end
