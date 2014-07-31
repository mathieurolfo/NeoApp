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
    
    //access NeoReach API; load information first
    //[self performSelectorOnMainThread:@selector(callNeoReachAPI:) withObject:delegate waitUntilDone:YES];
    [self callNeoReachAPI:delegate];
    
    NSLog(@"after main thread %@", delegate.userProfileDictionary);
    
    if (!delegate.rootNav) {
        NEODashboardController *dashboard = [[NEODashboardController alloc] init];
        delegate.rootNav = [[UINavigationController alloc] initWithRootViewController:dashboard];
        
    }
    delegate.drawer.centerViewController = delegate.rootNav;
    dispatch_async(dispatch_get_main_queue(), ^{
        [((NEODashboardController *)delegate.rootNav.presentedViewController).tableView reloadData];
    });
}

/* this method will currently initialize the session and get the basic NeoReach account information. This information will be put into a dictionary that is a property of the app delegate for now, until we set up dedicated model classes.
 */
-(void)callNeoReachAPI:(NEOAppDelegate *)delegate
{
    //initialize session configuration: could be done in controller init but keeping code together for now
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    
    //THIS CODE DEALS WITH FACEBOOK AUTHENTICATION IN ORDER TO GET XAUTH AND XDIGEST
    
    
    
    
    
    
    //THE BELOW CODE DEALS WITH GET REQUEST AFTER SUCCESSFULLY RECEIVING XAUTH AND XDIGEST
    
    //configuring the header for the session to conform to NeoReach API protocol
    NSString *testXAuth = @"53d6b32fbedda4bd15649f59";
    NSString *testXDigest = @"BbgtaMoTDepnHFahq3YVGZ3Kjmjda96q";
    config.HTTPAdditionalHeaders = @{@"X-Auth":testXAuth,
                                     @"X-Digest":testXDigest};
    
    //should there be a delegate for this?
    _session = [NSURLSession sessionWithConfiguration:config delegate:nil delegateQueue:nil];
    
    //creating URL for the actual request
    //NSString *requestString = @"https://api.neoreach.com/account";
    NSString *requestString = @"https://api.neoreach.com/campaigns?skip=0&limit=10";
    NSURL *url = [NSURL URLWithString:requestString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            NSError *jsonError;
            
            //load response into a dictionary
            NSDictionary *profileJSON =
            [NSJSONSerialization JSONObjectWithData:data
                                            options:NSJSONReadingMutableContainers
                                              error:&jsonError];
            delegate.userProfileDictionary = [[NSMutableDictionary alloc] initWithDictionary:profileJSON copyItems:YES];
            
            NSLog(@"%@", delegate.userProfileDictionary);
            //NSLog(@"%@", [profileJSON valueForKeyPath:@"data.Profile.name"]);
        }];
        [dataTask resume];
        
        
    });
   
}
    

@end
