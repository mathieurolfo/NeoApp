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
        self.prevRedirectAddress = @"";
        self.currRedirectAddress = @"";
        
        //subscribe to notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadWebView) name:@"headerInvalid" object:nil];
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
    NSLog(@"%u", FBSession.activeSession.state);
    if (FBSession.activeSession.state == FBSessionStateOpen ||
        FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        [FBSession.activeSession closeAndClearTokenInformation];
        NSLog(@"Login closed");
    } else {
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile"] allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
            NSLog(@"session opened, token is %@", session.accessTokenData);
            
            NSString *token = [NSString stringWithFormat:@"%@", session.accessTokenData];
            [self displayActivityIndicator];
            [delegate.user pullHeadersFromToken:token];

        }];
    }
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




-(void)getAuthHeader
{
    NEOAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:self.redirectURL];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:delegate.sessionConfig delegate:nil delegateQueue:nil];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSError *jsonError;
        
        //load response into a dictionary
        NSDictionary *headerJSON =
        [NSJSONSerialization JSONObjectWithData:data
                                        options:NSJSONReadingMutableContainers
                                          error:&jsonError];
        
        NSString *xAuth = [headerJSON valueForKeyPath:@"data.X-Auth"];
        NSString *xDigest = [headerJSON valueForKeyPath:@"data.X-Digest"];
        
        delegate.sessionConfig.HTTPAdditionalHeaders = @{@"X-Auth":xAuth,
                                                         @"X-Digest":xDigest};
        
        [[NSUserDefaults standardUserDefaults] setValue:xAuth forKey:@"xAuth"];
        [[NSUserDefaults standardUserDefaults] setValue:xDigest forKey:@"xDigest"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSLog(@"Saved xAuth and xDigest in getAuthHeader: %@ %@ %@", xAuth, xDigest, delegate.sessionConfig.HTTPAdditionalHeaders);
        
        //initialization of dashboard controller must occur on the main thread after the headers are configured, or else the API server call won't return correctly
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NEODashboardController *dashboard = [[NEODashboardController alloc] init];
            delegate.rootNav = [[UINavigationController alloc] initWithRootViewController:dashboard];
            delegate.rootNav.navigationBar.translucent = NO;
            delegate.drawer.centerViewController = delegate.rootNav;
            
            NEOUser *user = [(NEOAppDelegate *)[[UIApplication sharedApplication] delegate] user];
            [user pullProfileInfo];
            


            self.splashImage.hidden = NO;
            [self.timer invalidate];
            
        });
    }];
    [dataTask resume];
    
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
