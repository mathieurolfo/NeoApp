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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(profilePosted) name:@"profilePosted" object:nil];
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
    form.website = user.website;
    form.paypalEmail = user.paypalEmail;

    if ([user.gender isEqualToString:@"male"]) {
        form.gender = GenderMale;
    } else form.gender = GenderFemale;
    
    if (user.dateOfBirth == nil) {
        form.dateOfBirth = [NSDate date];
    } else {
        form.dateOfBirth = user.dateOfBirth;
    }
}


- (void)saveProfileChanges
{
    [self displaySavingIndicator];
    NEOUser *user = [(NEOAppDelegate *)[[UIApplication sharedApplication] delegate] user];
    [user postProfileInfoWithDictionary:[self dictionaryFromForm]];
}

-(void) profilePosted
{
    [self.navigationController popToRootViewControllerAnimated:YES];
   
}

- (NSDictionary *)dictionaryFromForm
{
    NEOProfileForm *form = (NEOProfileForm *)self.formController.form;
    
    NSString *gender;
    if (form.gender == GenderMale) {
        gender = @"male";
    } else {
        gender = @"female";
    }

    
    NSDictionary *dict = @{
        @"email" : form.email,
        @"firstName" : form.firstName,
        @"lastName" : form.lastName,
        @"gender": gender,
        @"website": form.website,
        @"dateOfBirth": form.dateOfBirth,
        @"paypalEmail" : form.paypalEmail
        };
         
    
    return dict;
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
