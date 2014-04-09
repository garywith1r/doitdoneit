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

@property (nonatomic, readonly) NSDictionary* logedUser;

@end
