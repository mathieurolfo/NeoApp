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
#import <FacebookSDK/FacebookSDK.h>

@interface NEOAppDelegate ()

@end

@implementation NEOAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [FBLoginView class];
    
    NEOLoginController *loginController = [[NEOLoginController alloc] init];
    self.login = loginController;

    NEOSideMenuController *sideMenu = [[NEOSideMenuController alloc] init];
    
    self.drawer = [[MMDrawerController alloc] initWithCenterViewController:loginController
                                                                 leftDrawerViewController:sideMenu];
    
    [self.drawer setDrawerVisualStateBlock:[MMDrawerVisualState parallaxVisualStateBlockWithParallaxFactor:4.0]];

    [self.drawer setShouldStretchDrawer:NO];
    [self.drawer setShowsShadow:NO];
    self.drawer.maximumLeftDrawerWidth = [UIScreen mainScreen].bounds.size.width * 2.0 / 3;
    
    self.user = [[NEOUser alloc] init];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.drawer;
    [self.window makeKeyAndVisible];
    
    
    //hides navigation bar separating line
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    [[UINavigationBar appearance] setBackgroundColor:[UIColor whiteColor]];
    
    NSLog(@"loading stuff");
    
    
    
    //set up session configuration for app
    self.xAuth = [[NSUserDefaults standardUserDefaults] objectForKey:@"xAuth"];
    self.xDigest = [[NSUserDefaults standardUserDefaults] objectForKey:@"xDigest"];
    self.sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    if (self.xAuth && self.xDigest) {
        self.sessionConfig.HTTPAdditionalHeaders = @{@"X-Auth":self.xAuth,
                                                     @"X-Digest":self.xDigest};
        NSLog(@"They exist");
    }
    
    NSLog(@"Loaded header in app delegate: %@", self.sessionConfig.HTTPAdditionalHeaders);
    
    return YES;
}

-(void)sessionStateChanged:(FBSession *)session state:(FBSessionState)state error:(NSError *)error
{
    if (!error && state == FBSessionStateOpen) {
        NSLog(@"Session opened");
        // [self userLoggedIn:session user];
        
        //THIS IS THE COMMAND TO GET THE USER INFORMATION
        [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id<FBGraphUser> user, NSError *error) {
            if (!error) {
                NSLog(@"%@", user.name);
                //[self userLoggedIn:session user:(FBGraphObject *)user];
            }
        }];
        return;
    }
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed) {
        NSLog(@"Session closed");
        //[self userLoggedOut];
    }
    if (error) {
        NSLog(@"Error");
        NSString *alertText;
        NSString *alertTitle;
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
            alertTitle = @"Something went wrong";
            alertText = [FBErrorUtility userMessageForError:error];
            //[self showMessage:alertText withTitle:alertTitle];
            NSLog(@"%@", alertText);
        } else {
            
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                NSLog(@"User cancelled login");
                
                // Handle session closures that happen outside of the app
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
                //[self showMessage:alertText withTitle:alertTitle];
                NSLog(@"%@", alertText);
                
                // Here we will handle all other errors with a generic error message.
                // We recommend you check our Handling Errors guide for more information
                // https://developers.facebook.com/docs/ios/errors/
            } else {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                
                // Show the user an error message
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                //[self showMessage:alertText withTitle:alertTitle];
                NSLog(@"%@", alertText);
            }
        }
        // Clear this token
        [FBSession.activeSession closeAndClearTokenInformation];
        // Show the user the logged-out UI
        //[self userLoggedOut];
    }
}



-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    return wasHandled;
}



- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{

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
