//
//  NEOLoginController.m
//  NeoReach
//
//  Created by Sam Crognale on 7/21/14.
//  Copyright (c) 2014 NeoReach. All rights reserved.
//

#import "NEOLoginController.h"
#import "NEODashboardController.h"
#import "NEOAppDelegate.h"
#import "NEOWebViewController.h"
#import <FacebookSDK/FacebookSDK.h>


static int defaultTimeout = 7;



@interface NEOLoginController ()
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation NEOLoginController

#pragma mark Initialization and View Methods


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        //subscribe to notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadToken) name:@"headerInvalid" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createDashboard) name:@"profileUpdated" object:nil];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.logInOutInfoLabel.text = @"";
    // Do any additional setup after loading the view from its nib.
    self.splashImage.image = [UIImage imageNamed:@"splash.png"];
    [self.neoReachLabel setFont:[UIFont fontWithName:@"Lato-Black" size:42.0]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    [self setNeedsStatusBarAppearanceUpdate];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Logging In Methods

/*
 Workflow for login is:
    Check for existence of header
    If there is a header, try pulling profile info
        [now inside delegate.user]
        [If you can pull the profile information, call endRequest and createDashboard]
        [If you can't, call loadToken which is what happens if there is no header]
    If there is no header, get the facebook session token using loadToken which then tries pullHeadersFromToken
        [now inside delegate.user]
        [If you get the x-header, call pullProfileInfo again]
            [If successful, calls endRequest and createDashboard]
            [If not, calls headerInvalid] BUT will always return successful because the server will create a new account if one does not exist for that header.
        [If you can't, return an error message and cancel request]
 
 */
- (IBAction)logInPressed:(id)sender {
    NEOAppDelegate *delegate = [[UIApplication sharedApplication] delegate];

    self.timer = [NSTimer scheduledTimerWithTimeInterval:defaultTimeout target:self selector:@selector(endUnsuccessfulRequest) userInfo:nil repeats:NO];
    
    [self displayActivityIndicator];
    [self.loginButton setEnabled:NO];
    if (delegate.xAuth.length > 1) {
        NSLog(@"there is a config when initializing: %@", delegate.sessionConfig.HTTPAdditionalHeaders);
        [delegate.user pullProfileInfo];
    } else {
        [self loadToken];
    }
    
}


-(void)loadToken {
    NEOAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [FBSession openActiveSessionWithReadPermissions:@[@"public_profile"] allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
        NSLog(@"session opened, token is %@", session.accessTokenData);
        NSString *token = [NSString stringWithFormat:@"%@", session.accessTokenData];
        [delegate.user pullHeadersFromToken:token];
    }];
}

//called if no headers exist

-(void)createDashboard
{
    NEOAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NEODashboardController *dashboard = [[NEODashboardController alloc] init];
    delegate.rootNav = [[UINavigationController alloc] initWithRootViewController:dashboard];
    delegate.drawer.centerViewController = delegate.rootNav;
    NSLog(@"ending successful request from createDashboard");
    if (self.loginIndicator.isAnimating) {
        [self endSuccessfulRequest];
    }
}

-(void)displayActivityIndicator
{

    UIActivityIndicatorView *loginIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    loginIndicator.center = self.view.center;
    [loginIndicator startAnimating];
    self.loginIndicator = loginIndicator;
    [self.view insertSubview:loginIndicator aboveSubview:self.splashImage];
}


-(void)endUnsuccessfulRequest
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loginIndicator stopAnimating];
        [self.loginButton setEnabled:YES];
    });
    //other version has alert view pop up
    NSLog(@"unsuccessful request ended");
}

-(void)endSuccessfulRequest
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loginIndicator stopAnimating];
        [self.loginButton setEnabled:YES];
    });
    
    [self.timer invalidate];
}



@end
