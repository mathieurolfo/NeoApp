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
    
    
    [self getTokensForAPI];
    
    NSLog(@"pressed login button");
    
    NEOWebViewController *webView = [[NEOWebViewController alloc] init];
    delegate.webView = webView;
    delegate.window.rootViewController = delegate.webView;
    
}

/* this method will currently initialize the session and get the basic NeoReach account information. This information will be put into a dictionary that is a property of the app delegate for now, until we set up dedicated model classes.
 */
-(void)getTokensForAPI
{
    
    //THIS CODE DEALS WITH FACEBOOK AUTHENTICATION IN ORDER TO GET XAUTH AND XDIGEST
    NEOAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    delegate.sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    
   
    
    self.loginAddress = @"https://api.neoreach.com/auth/facebook";
    NSURL *loginURL = [NSURL URLWithString:self.loginAddress];
    UIWebView *webView = [[UIWebView alloc] init];
    webView.scalesPageToFit = YES;
    //[self.view addSubview: webView];
    self.view = webView;
    webView.delegate = self;
    NSURLRequest *request = [NSURLRequest requestWithURL:loginURL];
    [webView loadRequest:request];
   
}


-(void)webViewDidFinishLoad:(UIWebView *)webView
{


}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *redirect = [request mainDocumentURL];
    NSString *redirectAddress = [redirect absoluteString];
    
    if ([redirectAddress hasPrefix:@"https://api.neoreach.com/auth/facebook/callback"]) {
        self.redirectURL = redirect;
        [self getAuthHeader];
        return NO;
    }
    return YES;
}

-(void)getAuthHeader
{
        //NSURL *redirectURL = webView.request.URL;
    
    //NSLog(@"redirect url %@", redirectURL);
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
        if (!delegate.rootNav) {
            NEODashboardController *dashboard = [[NEODashboardController alloc] init];
            delegate.rootNav = [[UINavigationController alloc] initWithRootViewController:dashboard];
            
            NSLog(@"initialized dashboard");
            delegate.drawer.centerViewController = delegate.rootNav;
            /*dispatch_async(dispatch_get_main_queue(), ^{
                //[dashboard.tableView reloadData];
            }); */
        }

            }];
    [dataTask resume];

    
    
}
















@end
