//
//  UsersModel.m
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 4/8/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "UsersModel.h"
#import "CacheFileManager.h"
#import "TabBarController.h"
#import "StatsModel.h"
#import "NSDate+Reporting.h"
#import "Constants.h"
#import "TaskDTO.h"
#import "TaskListModel.h"

#define LOGGED_USER_PATH_KEY @"UsersDataPath"

#define DEFAULT_USER @{LOGGED_USER_IMAGE_KEY:@"",LOGGED_USER_NAME_KEY:@"Default User"}

@interface UsersModel () {
    NSArray* storedUsers;
    
    NSInteger logedUserIndex;
    
    BOOL _parentsModeEnabled;
}

@end

@implementation UsersModel
@synthesize logedUser, logedUserData;
@synthesize purchasedAddsFree, purchasedMultiUser, purchasedParentsMode, purchasedWeeklyReview;
@synthesize parentsModeEnabled, parentsModeActive, parentsPinCode;

UsersModel* userModelInstance;

+ (UsersModel*) sharedInstance {
    if (userModelInstance)
        return userModelInstance;
    
    userModelInstance = [[UsersModel alloc] init];
    return userModelInstance;
}

- (id) init {
    if (self = [super init]) {
        logedUserIndex = [[[NSUserDefaults standardUserDefaults] objectForKey:@"logedUserIndex"] integerValue];
        
        logedUser = [[self getUsers] objectAtIndex:logedUserIndex];
        NSData* data = [CacheFileManager getDataFromPath:[logedUser objectForKey:LOGGED_USER_PATH_KEY]];
        if (data) {
            logedUserData = [NSMutableDictionary dictionaryWithDictionary:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
        } else {
            logedUserData = [[NSMutableDictionary alloc] init];
        }
        
        
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        purchasedParentsMode = [userDefaults boolForKey:@"purchasedParentsMode"];
        purchasedMultiUser = [userDefaults boolForKey:@"purchasedMultiUser"];
        purchasedAddsFree = [userDefaults boolForKey:@"purchasedAddsFree"];
        purchasedWeeklyReview = [userDefaults boolForKey:@"purchasedWeeklyReview"];
        
        parentsModeEnabled = [userDefaults boolForKey:@"parentsModeEnabled"];
        parentsPinCode = [userDefaults objectForKey:@"parentsPinCode"];
        
#warning Testing
        purchasedParentsMode = purchasedMultiUser = purchasedAddsFree = purchasedWeeklyReview = YES;

    }
    
    return self;
}

- (NSArray*) getUsers {
    if (storedUsers)
        return storedUsers;
    
    storedUsers = [[NSUserDefaults standardUserDefaults] objectForKey:@"storedUsersArray"];
    if (!storedUsers)
        [self addUser:DEFAULT_USER];
    return storedUsers;
}



- (void) addUser:(NSDictionary*)userData {
    
    NSString* path = [userData objectForKey:LOGGED_USER_PATH_KEY];
    NSMutableDictionary* newUserDictionary = [NSMutableDictionary dictionaryWithDictionary:userData];
    
    NSMutableArray* tempArray = [NSMutableArray arrayWithArray:storedUsers];
    
    if (!path || [path isEqualToString:@""]) {
        path = [CacheFileManager getAvailablePath];
        [newUserDictionary setObject:path forKey:LOGGED_USER_PATH_KEY];
        //add default values
        NSDictionary* newUserDataDictionary = [self defaultUserData];
        NSData * encodedData = [NSKeyedArchiver archivedDataWithRootObject:newUserDataDictionary];
        [CacheFileManager storeData:encodedData onPath:path];
        
        [tempArray addObject:newUserDictionary];
        
    } else {
        int x = 0;
        for (;x < storedUsers.count; x++) {
            NSDictionary* userDictionary = storedUsers[x];
            if ([[userDictionary objectForKey:LOGGED_USER_PATH_KEY] isEqualToString:path]) {
                [tempArray replaceObjectAtIndex:x withObject:[NSDictionary dictionaryWithDictionary:newUserDictionary]];
                break;
            }
        }
    }
    
        
    
    
    
    storedUsers = [NSArray arrayWithArray:tempArray];
    [self saveUsersArray];
    logedUser = storedUsers[logedUserIndex];
}

- (NSDictionary*) defaultUserData {
    NSMutableDictionary* defaultData = [[NSMutableDictionary alloc] init];
    [defaultData setInteger:DEFAULT_GOAL_POINTS forKey:LOGGED_USER_GOAL_KEY];
    [defaultData setObject:DEFAULT_GOAL_TEXT forKey:LOGGED_USER_GOAL_DESCRIPTION_KEY];
    
    return [NSDictionary dictionaryWithDictionary:defaultData];
}

- (void) deleteUserAtIndex:(NSInteger)index {
    
    NSDictionary* userToDelete = [storedUsers objectAtIndex:index];
    NSMutableDictionary* selectedUserData = logedUserData;
    
    NSData* data = [CacheFileManager getDataFromPath:[userToDelete objectForKey:LOGGED_USER_PATH_KEY]];
    logedUserData = [NSMutableDictionary dictionaryWithDictionary:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
    
    
    //First we delete all tasks from the user
    [[TaskListModel sharedInstance] loadFullData];
    [[TaskListModel sharedInstance] forceRecalculateTasks];
    [[TaskListModel sharedInstance] deleteAllTasks];
    
    BOOL hasToRest = index < logedUserIndex;
    
    //If it's deleting current user, we need to switch to another.
    if (index == logedUserIndex) {
        
        if (storedUsers.count == 1) {
            [self addUser:DEFAULT_USER];
            [self changeToUserAtIndex:1];
            hasToRest = YES;
        } else if (index == 0) {
            [self changeToUserAtIndex:1];
            hasToRest = YES;
        } else {
            [self changeToUserAtIndex:index - 1];
        }
        
        
        //Need to remove the notifications added for the deleting user when we change the user.
        
        NSArray* userNotifications = [selectedUserData objectForKey:@"LocalNotifications"];
        
        UIApplication* sharedApp = [UIApplication sharedApplication];
        
        for (UILocalNotification* notification in userNotifications) {
            [sharedApp cancelLocalNotification:notification];
        }
    } else {
        logedUserData = selectedUserData;
    }
    
    logedUserIndex -= hasToRest;
    [[TaskListModel sharedInstance] loadFullData];
    [[TaskListModel sharedInstance] forceRecalculateTasks];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:logedUserIndex] forKey:@"logedUserIndex"];
    
    //Finaly we delete User's data, and it's entrance in storedUsers.
    [CacheFileManager deleteContentAtPath:[userToDelete objectForKey:LOGGED_USER_PATH_KEY]];
    NSMutableArray* tempArray = [NSMutableArray arrayWithArray:storedUsers];
    [tempArray removeObjectAtIndex:index];
    storedUsers = [NSArray arrayWithArray:tempArray];
    [self saveUsersArray];
}

- (void) saveUsersArray {
    [[NSUserDefaults standardUserDefaults] setObject:storedUsers forKey:@"storedUsersArray"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) saveCurrentUserData {
    NSData * encodedData = [NSKeyedArchiver archivedDataWithRootObject:logedUserData];
    [CacheFileManager storeData:encodedData onPath:[logedUser objectForKey:LOGGED_USER_PATH_KEY]];
}

- (void) changeToUserAtIndex:(NSInteger)index {
    
    logedUserIndex = index;
    logedUser = [[self getUsers] objectAtIndex:logedUserIndex];
    NSData* data = [CacheFileManager getDataFromPath:[logedUser objectForKey:LOGGED_USER_PATH_KEY]];
    if (data) {
        logedUserData = [NSMutableDictionary dictionaryWithDictionary:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
    } else {
        logedUserData = [[NSMutableDictionary alloc] init];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:logedUserIndex] forKey:@"logedUserIndex"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[TaskListModel sharedInstance] loadFullData];
    [[TaskListModel sharedInstance] evaluateMissedTasks];
    [[TaskListModel sharedInstance] forceRecalculateTasks];
    
    [[StatsModel sharedInstance] loadData];
    [[StatsModel sharedInstance] recalculateVolatileStats];
    [[UsersModel sharedInstance] removeTodaysReminders];
    
}

- (BOOL) currentUserCanCreateTasks {
    return self.parentsModeActive || !self.parentsModeEnabled;
}

- (void) setParentsPinCode:(NSString *)_parentsPinCode {
    parentsPinCode = _parentsPinCode;
    [[NSUserDefaults standardUserDefaults] setObject:parentsPinCode forKey:@"parentsPinCode"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) removeAdsUpgradePurchased {
    purchasedAddsFree = YES;
    TabBarController* tabBar = (TabBarController*)[(UINavigationController*)[[[UIApplication sharedApplication] keyWindow] rootViewController] viewControllers][0];
    [tabBar removeAdds];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"purchasedAddsFree"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) weeklyReviewUpgradePurchased {
    purchasedWeeklyReview = YES;
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"purchasedWeeklyReview"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) multiuserUpgradePurchased {
    purchasedMultiUser = YES;
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"purchasedMultiUser"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) familyUpgradePurchased {
    purchasedParentsMode = YES;
    parentsModeEnabled = YES;
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"purchasedParentsMode"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"parentsModeEnabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) setParentsModeEnabled:(BOOL)parentsModeOn {
    parentsModeEnabled = parentsModeOn;
    [[NSUserDefaults standardUserDefaults] setBool:parentsModeOn forKey:@"parentsModeEnabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL) parentsModeEnabled {
    return parentsModeEnabled;
}

- (void) addRemindersForMainTask {
    if ([self.logedUserData objectForKey:LOGGED_USER_REMINDERS_KEY]) {
        TaskDTO* firstTask = [[self.logedUserData objectForKey:@""] objectAtIndex:0];
        if (firstTask) {
            UILocalNotification *localNotif = [[UILocalNotification alloc] init];
            if (localNotif == nil)
                return;
            
            NSString* alertBody = @"Hey ";
            
            if (purchasedMultiUser)
                alertBody = [alertBody stringByAppendingString:[self.logedUser objectForKey:LOGGED_USER_NAME_KEY]];
            else
                alertBody = [alertBody stringByAppendingString:@"there"];
            
            TaskDTO* firstTask = [[self.logedUserData objectForKey:@""] objectAtIndex:0];
            
            alertBody = [alertBody stringByAppendingString:[NSString stringWithFormat:@". Time to do %@",firstTask.title]];
            
            
            localNotif.fireDate = [[NSDate midnightTomorrow] dateByAddingTimeInterval:FIRST_ALARM_TIME];
            localNotif.repeatInterval = kCFCalendarUnitDay;
            localNotif.timeZone = [NSTimeZone defaultTimeZone];
            localNotif.soundName = UILocalNotificationDefaultSoundName;
            localNotif.alertBody = alertBody;
            localNotif.applicationIconBadgeNumber = 0;
            
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
            
            UILocalNotification* localNotif2 = [[UILocalNotification alloc] init];
            
            alertBody = [alertBody stringByAppendingString:[NSString stringWithFormat:@". Time to do %@",firstTask]];
            
            
            localNotif2.fireDate = [[NSDate midnightTomorrow] dateByAddingTimeInterval:SECOND_ALARM_TIME];
            localNotif2.repeatInterval = kCFCalendarUnitDay;
            localNotif2.timeZone = [NSTimeZone defaultTimeZone];
            localNotif2.soundName = UILocalNotificationDefaultSoundName;
            localNotif2.alertBody = alertBody;
            localNotif2.applicationIconBadgeNumber = 0;
            
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotif2];
            
            [self.logedUserData setObject:@[localNotif, localNotif2] forKey:@"LocalNotifications"];
//            [self saveCurrentUserData];
        }
    }
}

- (void) removeTodaysReminders {
    NSArray* userNotifications = [self.logedUserData objectForKey:@"LocalNotifications"];
    
    UIApplication* sharedApp = [UIApplication sharedApplication];
    
    for (UILocalNotification* notification in userNotifications) {
        [sharedApp cancelLocalNotification:notification];
    }
}

- (void) prepareForBackground {
    [UsersModel sharedInstance].parentsModeActive = NO;
    [[UsersModel sharedInstance] addRemindersForMainTask];
    [[UsersModel sharedInstance] saveCurrentUserData];
    [[UsersModel sharedInstance].logedUserData setObject:[NSDate date] forKey:LOGGED_USER_LAST_LOGGIN];
}
@end
