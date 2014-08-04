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
    
    NEOWebViewController *webView = [[NEOWebViewController alloc] init];
    delegate.webView = webView;
    delegate.drawer.centerViewController = delegate.webView;
    
}



-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    //initialize session configuration: could be done in controller init but keeping code together for now
   
    
    
    //THIS CODE DEALS WITH FACEBOOK AUTHENTICATION IN ORDER TO GET XAUTH AND XDIGEST
    NEOAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    delegate.sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
}

















@end
