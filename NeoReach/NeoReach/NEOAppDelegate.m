//
//  NEOAppDelegate.m
//  NeoReach
//
//  Created by Sam Crognale on 7/10/14.
//  Copyright (c) 2014 NeoReach. All rights reserved.
//

#import "NEOAppDelegate.h"
#import "NEOLoginController.h"
#import "NEOSideMenuController.h"
#import <MMDrawerController/MMDrawerController.h>
#import <MMDrawerController/MMDrawerVisualState.h> //for sidebar animations

@interface NEOAppDelegate ()

@end

@implementation NEOAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    NEOLoginController *loginController = [[NEOLoginController alloc] init];
    self.login = loginController;

    
    NEOSideMenuController *sideMenu = [[NEOSideMenuController alloc] init];
    
    self.drawer = [[MMDrawerController alloc] initWithCenterViewController:loginController
                                                                 leftDrawerViewController:sideMenu];
    
    [self.drawer setDrawerVisualStateBlock:[MMDrawerVisualState parallaxVisualStateBlockWithParallaxFactor:4.0]];

    [self.drawer setShowsShadow:NO];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.drawer;
    [self.window makeKeyAndVisible];
    
    return YES;
}



- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)enableDrawerAccess
{
    self.drawer.openDrawerGestureModeMask = MMOpenDrawerGestureModeBezelPanningCenterView |
    MMOpenDrawerGestureModePanningNavigationBar;
    
    self.drawer.closeDrawerGestureModeMask = MMCloseDrawerGestureModeTapCenterView |
    MMCloseDrawerGestureModePanningDrawerView |
    MMCloseDrawerGestureModePanningCenterView |
    MMCloseDrawerGestureModeTapNavigationBar |
    MMCloseDrawerGestureModePanningNavigationBar;
    

    
}

-(void)disableDrawerAccess
{
    
    self.drawer.openDrawerGestureModeMask = 0;
    self.drawer.closeDrawerGestureModeMask = 0;
    
}


@end
