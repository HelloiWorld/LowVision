//
//  AppDelegate.m
//  LowVision
//
//  Created by Sen Zeng on 14/12/12.
//  Copyright (c) 2014年 naturalsoft. All rights reserved.
//

#import "AppDelegate.h"
#import "naMainData.h"
#import "naAudioPlayer.h"
#import "MFSideMenuContainerViewController.h"
#import "UserGuideViewController.h"
#import "TitleListController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    
    //判断是不是第一次启动应用
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"])
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLaunch"];
        
        NSLog(@"第一次启动");
        
        //如果是第一次启动的话,使用UserGuideViewController (用户引导页面) 作为根视图
        
        UserGuideViewController *userGuideViewController = (UserGuideViewController*)self.window.rootViewController;
        userGuideViewController=[storyboard instantiateViewControllerWithIdentifier:@"UserGuideViewController"];
    }
    else{
        NSLog(@"已经不是第一次启动了");
        
        //如果不是第一次启动的话,使用TitleListController作为根视图
        
        MFSideMenuContainerViewController *container=[[MFSideMenuContainerViewController alloc]init];
        TitleListController *titleListController=[storyboard instantiateViewControllerWithIdentifier:@"TitleListController"];
        UIViewController *leftSideMenuViewController = [storyboard instantiateViewControllerWithIdentifier:@"leftSideMenuViewController"];
        [container setLeftMenuViewController:leftSideMenuViewController];
        [container setCenterViewController:titleListController];
        
        self.window.rootViewController=container;
        [titleListController hideLoadingView];
        
    }
    
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.

    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [[naDataProcessing shareInstance]saveData];
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
