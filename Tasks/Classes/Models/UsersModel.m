//
//  UsersModel.m
//  DoItDoneIt
//
//  Created by Gonzalo Hardy on 4/8/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "UsersModel.h"
#import "EGOFileManager.h"
#import "TabBarController.h"

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
        [self changeToUserAtIndex:logedUserIndex];
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        purchasedParentsMode = [userDefaults boolForKey:@"purchasedParentsMode"];
        purchasedMultiUser = [userDefaults boolForKey:@"purchasedMultiUser"];
        purchasedAddsFree = [userDefaults boolForKey:@"purchasedAddsFree"];
        purchasedWeeklyReview = [userDefaults boolForKey:@"purchasedWeeklyReview"];
        
        parentsModeEnabled = [userDefaults boolForKey:@"parentsModeEnabled"];
        parentsPinCode = [userDefaults objectForKey:@"parentsPinCode"];
        
#warning test mode
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
    NSMutableDictionary* userDictionary = [NSMutableDictionary dictionaryWithDictionary:userData];
    
    NSDictionary* oldUserData = nil;
    
    if (!path || [path isEqualToString:@""]) {
        path = [EGOFileManager getAvailablePath];
        [userDictionary setObject:path forKey:LOGGED_USER_PATH_KEY];
        
    } else {
        for (NSDictionary* userDictionary in storedUsers) {
            if ([[userDictionary objectForKey:LOGGED_USER_PATH_KEY] isEqualToString:path]) {
                oldUserData = userDictionary;
                break;
            }
        }
    }
    
        
    NSMutableArray* tempArray = [NSMutableArray arrayWithArray:storedUsers];
    [tempArray removeObject:oldUserData];
    [tempArray addObject:[NSDictionary dictionaryWithDictionary:userDictionary]];
    
    storedUsers = [NSArray arrayWithArray:tempArray];
    [self saveUsersArray];
    logedUser = storedUsers[logedUserIndex];
}

- (void) saveUsersArray {
    [[NSUserDefaults standardUserDefaults] setObject:storedUsers forKey:@"storedUsersArray"];
}

- (void) saveCurrentUserData {
    NSData * encodedData = [NSKeyedArchiver archivedDataWithRootObject:logedUserData];
    [EGOFileManager storeData:encodedData onPath:[logedUser objectForKey:LOGGED_USER_PATH_KEY]];
}

- (void) changeToUserAtIndex:(NSInteger)index {
    // we won't save currents user data cause each single change is stored when performed.
    
    logedUser = [[self getUsers] objectAtIndex:index];
    NSData* data = [EGOFileManager getDataFromPath:[logedUser objectForKey:LOGGED_USER_PATH_KEY]];
    if (data) {
        logedUserData = [NSMutableDictionary dictionaryWithDictionary:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
    } else {
        logedUserData = [[NSMutableDictionary alloc] init];
    }
    logedUserIndex = index;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:logedUserIndex] forKey:@"logedUserIndex"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL) currentUserCanCreateTasks {
//    return self.parentsModeEnabled || !self.parentsModeEnabled;
#warning test
    return YES;
}

- (void) setParentsPinCode:(NSString *)_parentsPinCode {
    parentsPinCode = _parentsPinCode;
    [[NSUserDefaults standardUserDefaults] setObject:parentsPinCode forKey:@"parentsPinCode"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) removeAdsUpgradePurchased {
    purchasedAddsFree = YES;
    TabBarController* tabBar = (TabBarController*)[[[UIApplication sharedApplication] keyWindow] rootViewController];
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


@end
