//
//  AppDelegate.m
//  Tasks
//
//  Created by Gonzalo Hardy on 2/4/14.
//  Copyright (c) 2014 GoNXaS. All rights reserved.
//

#import "AppDelegate.h"
#import "TaskListModel.h"
#import "UsersModel.h"
#import "RMStore.h"

#define NOT_APP_FIRST_LOAD @"has_loaded_some_time"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:NOT_APP_FIRST_LOAD]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:NOT_APP_FIRST_LOAD];
        UIApplication* sharedApp = [UIApplication sharedApplication];
        for (UILocalNotification* notification in sharedApp.scheduledLocalNotifications) {
            [sharedApp cancelLocalNotification:notification];
        }
    }
    
    if (![[UsersModel sharedInstance].logedUserData objectForKey:LOGGED_USER_REMINDERS_KEY])
        [[UsersModel sharedInstance].logedUserData setInteger:TRUE forKey:LOGGED_USER_REMINDERS_KEY];
    
    [[UsersModel sharedInstance] removeTodaysReminders];
    
    // Override point for customization after application launch.
    [[TaskListModel sharedInstance] evaluateMissedTasks];
    [[TaskListModel sharedInstance] forceRecalculateTasks];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    [UsersModel sharedInstance].parentsModeActive = NO;
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[UsersModel sharedInstance] prepareForBackground];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[TaskListModel sharedInstance] evaluateMissedTasks];
    [[TaskListModel sharedInstance] forceRecalculateTasks];
    [[UsersModel sharedInstance] removeTodaysReminders];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
