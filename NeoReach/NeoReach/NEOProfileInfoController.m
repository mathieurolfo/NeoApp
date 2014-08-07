//
//  NEOProfileInfoController.m
//  
//
//  Created by Sam Crognale on 8/6/14.
//
//

#import "NEOProfileInfoController.h"
#import "NEOProfileForm.h"
#import "NEOAppDelegate.h"
#import "NEOUser.h"

@interface NEOProfileInfoController ()
@property (nonatomic, strong) NSURLSession *session;

@end

@implementation NEOProfileInfoController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UINavigationItem *navItem = self.navigationItem;
        navItem.title = @"Profile Information";
        
        self.formController.form = [[NEOProfileForm alloc] init];
        [self populateForm];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) populateForm
{
    NEOUser *user = [(NEOAppDelegate *)[[UIApplication sharedApplication] delegate] user];
    NEOProfileForm *form = (NEOProfileForm *)self.formController.form;
    form.firstName = user.firstName;
    form.lastName = user.lastName;
    form.email = user.email;
    if ([user.gender isEqualToString:@"male"]) {
        form.gender = GenderMale;
    } else form.gender = GenderFemale;
    
    form.website = user.website;
    form.dateOfBirth = user.dateOfBirth;
}

- (void)saveProfileChanges
{
    NSData *jsonData = [self jsonProfileData];
    NSURL *URL = [NSURL URLWithString: @"https://api.neoreach.com/account/"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonData];

    
    NEOAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSURLSessionConfiguration *config = delegate.sessionConfig;
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:config delegate:nil delegateQueue:nil];
    }
    
    NSURLSessionDataTask *postDataTask = [_session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSError *jsonError;
        NSDictionary *dict =
        [NSJSONSerialization JSONObjectWithData:data
                                        options:NSJSONReadingMutableContainers
                                          error:&jsonError];
        
        NSLog(@"post response: %@",dict);
        
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshProfile" object:nil];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popToRootViewControllerAnimated:YES];
        });

    }];
    
    [postDataTask resume];
    [self displaySavingIndicator];
}

- (NSData *)jsonProfileData
{
    NEOProfileForm *form = (NEOProfileForm *)self.formController.form;
    NEOUser *user = [(NEOAppDelegate *)[[UIApplication sharedApplication] delegate] user];
    
    NSString *gender;
    if (form.gender == GenderMale) {
        gender = @"male";
    } else {
        gender = @"female";
    }

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    
    NSString *dobString = [dateFormatter stringFromDate:form.dateOfBirth];
    
    NSDictionary *dict = @{
        @"email" : form.email,
        @"name" : @{@"first":form.firstName, @"last":form.lastName},
        @"gender": gender,
        @"website": form.website,
        @"dob": dobString,
        
        // These fields are not updated in profile settings
        @"paypalEmail": user.paypalEmail,
        @"tags": user.tags,
        @"timezoneOffset": [NSNumber numberWithLong:user.timezoneOffset]
        };
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];

    return jsonData;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


-(void)displaySavingIndicator
{
    
    UIActivityIndicatorView *saveIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    saveIndicator.center = self.view.center;
    [saveIndicator startAnimating];
    [self.view addSubview:saveIndicator];
}



@end
