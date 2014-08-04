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
@property (nonatomic, strong) NSString *loginAddress;

@end

@implementation NEOLoginController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
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

- (IBAction)logInPressed:(id)sender {
    NEOAppDelegate *delegate = (NEOAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSLog(@"pressed login button");
    
    //NEOWebViewController *webView = [[NEOWebViewController alloc] init];
    //delegate.webView = webView;
    //delegate.drawer.centerViewController = delegate.webView;

    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    webView.delegate = self;
    webView.scalesPageToFit = YES;
    
    [delegate.window addSubview:webView];
    webView.hidden = YES;
    
    delegate.sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.loginAddress = @"https://api.neoreach.com/auth/facebook";
    NSURL *loginURL = [NSURL URLWithString:self.loginAddress];

    
    NSURLRequest *request = [NSURLRequest requestWithURL:loginURL];
    dispatch_async(dispatch_get_main_queue(), ^ {
        [webView loadRequest:request];
        NSLog(@"request loaded");
    });
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *redirect = [request mainDocumentURL];
    NSString *redirectAddress = [redirect absoluteString];
    NSLog(@"Current URL: %@", redirectAddress);
    if ([redirectAddress hasPrefix:@"https://api.neoreach.com/auth/facebook/callback"]) {
        self.redirectURL = redirect;
        [self getAuthHeader];
        return NO;
    } else if ([redirectAddress hasPrefix:@"https://m.facebook.com/login"]) {
        webView.hidden = NO;
        webView.layer.zPosition = MAXFLOAT;
        NSLog(@"Login screen loaded");
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
        NSLog(@"%@", headerJSON);
        NSString *xAuth = [headerJSON valueForKeyPath:@"data.X-Auth"];
        NSString *xDigest = [headerJSON valueForKeyPath:@"data.X-Digest"];
        NSLog(@"%@ %@", xAuth, xDigest);
        
        delegate.sessionConfig.HTTPAdditionalHeaders = @{@"X-Auth":xAuth,
                                                         @"X-Digest":xDigest};
        
        //initialization of dashboard controller must occur on the main thread after the headers are configured, or else the API server call won't return correctly
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!delegate.rootNav) {
                NEODashboardController *dashboard = [[NEODashboardController alloc] init];
                delegate.rootNav = [[UINavigationController alloc] initWithRootViewController:dashboard];
                delegate.drawer.centerViewController = delegate.rootNav;
            }
        });
    }];
    [dataTask resume];
    
}










@end
