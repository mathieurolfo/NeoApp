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
//3#import <Quartzcore/Quartzcore.h>

@interface NEOLoginController ()

@property (nonatomic, strong) NSURL *redirectURL;
@property (nonatomic, strong) NSString *prevRedirectAddress;
@property (nonatomic, strong) NSString *currRedirectAddress;
@property (nonatomic, strong) NSString *loginAddress;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation NEOLoginController

#pragma mark Initialization and View Methods


-(id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        
    }
    self.sessionConfig = [decoder decodeObjectForKey:@"sessionConfig"];
    
    NSLog(@"unarchived sessionConfig");
    return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.sessionConfig forKey:@"sessionConfig"];
}

-(NSString *)configArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories firstObject];
    return [documentDirectory stringByAppendingPathComponent:@"config.archive"];
}

-(BOOL)saveChanges
{
    NSString *path = [self configArchivePath];
    NSLog(@"%@", path);
    return [NSKeyedArchiver archiveRootObject:self.sessionConfig toFile:path];
}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.prevRedirectAddress = @"";
        self.currRedirectAddress = @"";
        
        //subscribe to notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadWebview) name:@"headerInvalid" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createDashboard) name:@"profilePulled" object:nil];
        NSLog(@"login nib initialized");
        NSString *path = [self configArchivePath];
        _sessionConfig = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        if (!_sessionConfig) {
            //_sessionConfig = [[NSMutableArray alloc] init];
            NSLog(@"No session configuration saved");
        } else {
            
        }
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
   
    //three cases
    //case 1: no headers
    if (!self.sessionConfig) {
        NSLog(@"No session config");
        [self loadWebview];
    } else {
        //cases 2 and 3
        NSLog(@"%@", self.sessionConfig.HTTPAdditionalHeaders);
        [delegate.user pullProfileInfo];
        NSLog(@"Request to pull initiated");
    }
}

//called if no headers exist
-(void)loadWebview
{
    UIWebView *webView = [self configureWebView];
    NSLog(@"Webview configured");
    NSURL *loginURL = [NSURL URLWithString:self.loginAddress];
    NSURLRequest *request = [NSURLRequest requestWithURL:loginURL];
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        [webView loadRequest:request];
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
    
    //if none unarchived, initialize
    if (!self.sessionConfig) {
        self.sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSLog(@"Created a session configuration");
    }
    
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
        [self getAuthHeader];
        return NO;
    } else if (
            //the login address appears twice (loading quirk?)
               ([redirectAddress hasPrefix:@"https://m.facebook.com/login"] &&
               [self.currRedirectAddress isEqualToString:self.prevRedirectAddress]) ||
               
               //the user is redirected to the actual 'enter login info' page
               [redirectAddress hasPrefix:@"https://m.facebook.com/v1.0/dialog/oauth?redirect"]) { //display login screen
        webView.hidden = NO;
        self.splashImage.hidden = YES;
    }
    
    return YES;
}

-(void)getAuthHeader
{
    NEOAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:self.redirectURL];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:self.sessionConfig delegate:nil delegateQueue:nil];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSError *jsonError;
        
        //load response into a dictionary
        NSDictionary *headerJSON =
        [NSJSONSerialization JSONObjectWithData:data
                                        options:NSJSONReadingMutableContainers
                                          error:&jsonError];
        
        NSString *xAuth = [headerJSON valueForKeyPath:@"data.X-Auth"];
        NSString *xDigest = [headerJSON valueForKeyPath:@"data.X-Digest"];
        
        self.sessionConfig.HTTPAdditionalHeaders = @{@"X-Auth":xAuth,
                                                         @"X-Digest":xDigest};
        
        NSLog(@"%@", self.sessionConfig);
        
        //initialization of dashboard controller must occur on the main thread after the headers are configured, or else the API server call won't return correctly
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NEODashboardController *dashboard = [[NEODashboardController alloc] init];
            delegate.rootNav = [[UINavigationController alloc] initWithRootViewController:dashboard];
            delegate.drawer.centerViewController = delegate.rootNav;
            delegate.rootNav.navigationBar.translucent = NO;
            
            NEOUser *user = [(NEOAppDelegate *)[[UIApplication sharedApplication] delegate] user];
            [user pullProfileInfo];
            
            //delegate.rootNav.navigationBar.barTintColor = [UIColor colorWithRed:0.465639 green:0.763392 blue:1 alpha:1];
            //delegate.rootNav.navigationBar.barTintColor = self.tableHeader.contentView.backgroundColor;

            
            //[[UINavigationBar appearance] setBackgroundColor:[UIColor colorWithRed:0.465639 green:0.763392 blue:1 alpha:1]];

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
}

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(cancelWeb) userInfo:nil repeats:NO];
}





@end
