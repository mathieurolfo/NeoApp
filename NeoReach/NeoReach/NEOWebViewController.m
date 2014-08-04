//
//  NEOWebViewController.m
//  NeoReach
//
//  Created by Mathieu Rolfo on 8/1/14.
//  Copyright (c) 2014 NeoReach. All rights reserved.
//

#import "NEOWebViewController.h"
#import "NEOAppDelegate.h"
#import "NEODashboardController.h"

@interface NEOWebViewController ()
@property (nonatomic, strong) NSURL *redirectURL;
@property (nonatomic, strong) NSString *loginAddress;
@property (nonatomic, strong) NEOAppDelegate *delegate;
@end

@implementation NEOWebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NEOAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        self.delegate = delegate;
        
        self.delegate.sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        
        self.loginAddress = @"https://api.neoreach.com/auth/facebook";
        NSURL *loginURL = [NSURL URLWithString:self.loginAddress];
        
        self.webView.scalesPageToFit = YES;
        self.title = @"Login";
        self.webView.delegate = self;
        NSURLRequest *request = [NSURLRequest requestWithURL:loginURL];
        dispatch_async(dispatch_get_main_queue(), ^ {
            [self.webView loadRequest:request];
            NSLog(@"request loaded");
            
        });
        NSLog(@"Init completed");

    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.webView.hidden = NO;
    

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
        //self.delegate.drawer.centerViewController = self;
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
