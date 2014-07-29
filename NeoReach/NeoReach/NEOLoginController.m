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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logInPressed:(id)sender {
    NEOAppDelegate *delegate = (NEOAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //access NeoReach API
    [self callNeoReachAPI];
    
    if (!delegate.rootNav) {
        NEODashboardController *dashboard = [[NEODashboardController alloc] init];
        delegate.rootNav = [[UINavigationController alloc] initWithRootViewController:dashboard];
    }
    
    delegate.drawer.centerViewController = delegate.rootNav;
    
}

/* this method will currently initialize the session and get the basic NeoReach account information. This information will be put into a dictionary that is a property of the app delegate for now, until we set up dedicated model classes.
 */
-(void)callNeoReachAPI
{
    //initialize session configuration: could be done in controller init but keeping code together for now
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    _session = [NSURLSession sessionWithConfiguration:config delegate:nil delegateQueue:nil];
    
    //configuring the header for the session to conform to NeoReach API protocol
    NSString *testXAuth = @"53c841122a2e5e485704f085";
    NSString *testXDigest = @"UW0ZMNigEhTxGWrm17oMZWLY91NES7rH";
    config.HTTPAdditionalHeaders = @{@"X-Auth": testXAuth,
                                     @"X-Digest": testXDigest};
    
    //creating URL for the actual request
    NSString *requestString = @"https://api.neoreach.com/account";
    NSURL *url = [NSURL URLWithString:requestString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@", json);
    }];
    [dataTask resume];
}


@end
