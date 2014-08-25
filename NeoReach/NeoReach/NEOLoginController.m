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

@interface NEOLoginController ()

@property (nonatomic, strong) NSURL *redirectURL;
@property (nonatomic, strong) NSString *prevRedirectAddress;
@property (nonatomic, strong) NSString *currRedirectAddress;
@property (nonatomic, strong) NSString *loginAddress;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic) int count;
@end

@implementation NEOLoginController

#pragma mark Initialization and View Methods



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        //subscribe to notifications
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadWebView) name:@"headerInvalid" object:nil];
        
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

- (IBAction)logInPressed:(id)sender {
    NEOAppDelegate *delegate = [[UIApplication sharedApplication] delegate];

    self.timer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(cancelRequest) userInfo:nil repeats:NO];

    [FBSession openActiveSessionWithReadPermissions:@[@"public_profile"] allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
        NSLog(@"session opened, token is %@", session.accessTokenData);
        
        NSString *token = [NSString stringWithFormat:@"%@", session.accessTokenData];
        [self displayActivityIndicator];
        [delegate.user pullHeadersFromToken:token];

    }];

    [self.loginButton setEnabled:NO];
}

//called if no headers exist

-(void)createDashboard
{
    NEOAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NEODashboardController *dashboard = [[NEODashboardController alloc] init];
    delegate.rootNav = [[UINavigationController alloc] initWithRootViewController:dashboard];
    delegate.drawer.centerViewController = delegate.rootNav;
}

-(void)displayActivityIndicator
{

    UIActivityIndicatorView *loginIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    loginIndicator.center = self.view.center;
    [loginIndicator startAnimating];
    self.loginIndicator = loginIndicator;
    [self.view insertSubview:loginIndicator aboveSubview:self.splashImage];
}


-(void)cancelRequest
{
    [self.loginIndicator stopAnimating];
    NEOAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.webView stopLoading];
    [self.loginButton setEnabled:YES];
    self.logInOutInfoLabel.text = @"Login timed out";
    NSLog(@"Login timed out");
}




@end
