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
    
    
    [self getTokensForAPI];
    
    NSLog(@"pressed login button");
    
    if (!delegate.rootNav) {
        NEODashboardController *dashboard = [[NEODashboardController alloc] init];
        delegate.rootNav = [[UINavigationController alloc] initWithRootViewController:dashboard];
        
    }
    delegate.drawer.centerViewController = delegate.rootNav;
    
    
}

/* this method will currently initialize the session and get the basic NeoReach account information. This information will be put into a dictionary that is a property of the app delegate for now, until we set up dedicated model classes.
 */
-(void)getTokensForAPI
{
    //initialize session configuration: could be done in controller init but keeping code together for now
   
    
    
    //THIS CODE DEALS WITH FACEBOOK AUTHENTICATION IN ORDER TO GET XAUTH AND XDIGEST
    NEOAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    delegate.sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    //NeoReach API protocol
    NSString *testXAuth = @"53a8b82105de5ab91cc11df9";
    NSString *testXDigest = @"RInB5Qz0jUweQsL3gTkbMCEXFF8AhQmj";

    delegate.sessionConfig.HTTPAdditionalHeaders = @{@"X-Auth":testXAuth,
                                     @"X-Digest":testXDigest};
    
    
    
    
    
    //THE BELOW CODE DEALS WITH GET REQUEST AFTER SUCCESSFULLY RECEIVING XAUTH AND XDIGEST
    
    //configuring the header for the session to conform to
    
   
}
    

@end
