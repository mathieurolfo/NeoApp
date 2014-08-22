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

    [self.loginButton setEnabled:NO];
    
    NEOAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSLog(@"Login pressed");
    NSLog(@"%@", delegate.sessionConfig.HTTPAdditionalHeaders);
    if (!delegate.xAuth) {
        NSLog(@"laod webviw");
        [self loadWebView];
    } else {
    
        [delegate.user pullProfileInfo]; //this attempts to use the saved header information. if it works, we go straight to the dashboard; if it doesn't, the "header invalid" notification is issued and the selector loadWebView is called.
    }
}

//called if no headers exist
-(void)loadWebView
{
    UIWebView *webView = [self configureWebView];
    self.count = self.count +1;
    NSLog(@"Webview configured for %ith time", self.count);
    NSURL *loginURL = [NSURL URLWithString:self.loginAddress];
    NSLog(@"%@", loginURL);
    NSURLRequest *request = [NSURLRequest requestWithURL:loginURL];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Starting a new web request");
        [webView loadRequest:request];
        NSLog(@"Loading request");
        [self displayActivityIndicator];
    });

}

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



#pragma mark - WebView Methods

-(UIWebView *)configureWebView
{
    NEOAppDelegate *delegate = (NEOAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //NOTE: hardcoded web view to make status bar visible
    delegate.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height)];
    
    delegate.webView.scrollView.scrollEnabled = NO;
    delegate.webView.delegate = self;
    delegate.webView.scalesPageToFit = YES;
    
    [delegate.window addSubview:delegate.webView];
    delegate.webView.hidden = YES;
    
    
    self.loginAddress = @"https://api.neoreach.com/auth/facebook";
    return delegate.webView;
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    NSURL *redirect = [request mainDocumentURL];
    NSString *redirectAddress = [redirect absoluteString];
    //mediocre fix for white landing page: the URL appears twice at the last page so if the previous one is the same, display the web view.
    self.prevRedirectAddress = self.currRedirectAddress;
    self.currRedirectAddress = redirectAddress;
    
    NSLog(@"%@", self.prevRedirectAddress);
    
    if ([redirectAddress hasPrefix:@"https://api.neoreach.com/auth/facebook/callback"]) { //terminate request early to get Auth Header
        self.redirectURL = redirect;
        NSLog(@"Get auth header");
        [self getAuthHeader];
        
        return NO;
    } else if (
            //the login address appears twice (loading quirk?)
               ([redirectAddress hasPrefix:@"https://m.facebook.com/login"] &&
               [self.currRedirectAddress isEqualToString:self.prevRedirectAddress]) ||
               
               //the user is redirected to the actual 'enter login info' page
               [redirectAddress hasPrefix:@"https://m.facebook.com/v1.0/dialog/oauth?redirect"] ||
               [redirectAddress hasPrefix:@"https://m.facebook.com/dialog/oauth"] ||
               [redirectAddress hasPrefix:@"https://www.facebook.com/dialog/oauth"]) { //
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        [self setNeedsStatusBarAppearanceUpdate];
        webView.hidden = NO;
        self.splashImage.hidden = YES;
    }
    return YES;
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

-(void)cancelWeb
{
    [self.loginIndicator stopAnimating];
    NEOAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.webView stopLoading];
    [self.loginButton setEnabled:YES];
    self.logInOutInfoLabel.text = @"Login timed out";
    NSLog(@"Login timed out");
}

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(cancelWeb) userInfo:nil repeats:NO];
}





@end
