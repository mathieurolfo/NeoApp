//
//  NEOAppDelegate.m
//  NeoReach
//
//  Created by Sam Crognale on 7/10/14.
//  Copyright (c) 2014 NeoReach. All rights reserved.
//

#import "NEOAppDelegate.h"
#import "NEOLoginViewController.h"
#import <FacebookSDK/FacebookSDK.h>

@interface NEOAppDelegate ()

@end

@implementation NEOAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    NEOLoginViewController *loginViewController = [[NEOLoginViewController alloc] init];
    self.window.rootViewController = loginViewController;
    
    //self.window.backgroundColor = [UIColor yellowColor];
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile"] allowLoginUI:NO completionHandler:
            ^(FBSession *session, FBSessionState state, NSError *error) {
            [self sessionStateChanged:session state:state error:error];
        }];
    }
    
    [self.window makeKeyAndVisible];
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
                NSLog(@"%@", user);
                [self userLoggedIn:session user:(FBGraphObject *)user];
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
            [self showMessage:alertText withTitle:alertTitle];
        } else {
            
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                NSLog(@"User cancelled login");
                
                // Handle session closures that happen outside of the app
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
                [self showMessage:alertText withTitle:alertTitle];
                
                // Here we will handle all other errors with a generic error message.
                // We recommend you check our Handling Errors guide for more information
                // https://developers.facebook.com/docs/ios/errors/
            } else {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                
                // Show the user an error message
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                [self showMessage:alertText withTitle:alertTitle];
            }
        }
        // Clear this token
        [FBSession.activeSession closeAndClearTokenInformation];
        // Show the user the logged-out UI
        //[self userLoggedOut];
    }
}

- (void)showMessage:(NSString *)text withTitle:(NSString *)alertTitle
{
    
}

- (void)userLoggedIn:(FBSession *)session user:(FBGraphObject *)user
{
    NSLog(@"userLoggedIn");
    if (session.state == FBSessionStateOpen) {
        ((NEOLoginViewController *)(self.window.rootViewController)).profilePictureView.profileID = [user objectForKey:@"id"];
        ((NEOLoginViewController *)(self.window.rootViewController)).nameLabel.text = [user objectForKey:@"name"];
        ((NEOLoginViewController *)(self.window.rootViewController)).statusLabel.text = @"Currently logged in";
        //session
    }
}

         
- (void)userLoggedOut:(FBSession *)session
{
    //((NEOLoginViewController *)(self.window.rootViewController)).profilePictureView.profileID =
    FBAccessTokenData *tokenData = session.accessTokenData;
    NSLog(@"%@", tokenData);
    //session.accessTokenData.appID;
    //NSString *userID = tokenData.userID;
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
    [FBAppCall handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


/* For facebook login. */
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    // Call FBAppCall's handleOpenURL:sourceApplication to handle Facebook app responses
    BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    
    // App-specific url handling here if needed
    
    return wasHandled;
}


@end
