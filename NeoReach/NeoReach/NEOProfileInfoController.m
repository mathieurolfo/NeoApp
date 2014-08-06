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
    
    NSLog(@"%@ %@", user.gender, user.dateOfBirth);
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



@end
