//
//  NEOAppDelegate.h
//  NeoReach
//
//  Created by Sam Crognale on 7/10/14.
//  Copyright (c) 2014 NeoReach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface NEOAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

-(void)sessionStateChanged:(FBSession *)session state:(FBSessionState)state error:(NSError *)error;
@end
