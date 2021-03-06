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
#import <CRToast/CRToast.h>

@interface NEOProfileInfoController ()
@property (nonatomic, strong) NSURLSession *session;

@end

@implementation NEOProfileInfoController

#pragma mark Default Initialization Methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        
        self.formController.form = [[NEOProfileForm alloc] init];
        [self populateForm];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(profilePosted) name:@"profileUpdated" object:nil];
    
    UINavigationItem *navItem = self.navigationItem;
    navItem.title = @"Profile Information";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(saveProfileChanges)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Form Editing Methods

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

#pragma mark Form Saving Methods

- (void)saveProfileChanges
{
    if ([self allFieldsAreValid]) {
        NSLog(@"saving changes because fields are valid");
        [self displaySavingIndicator];
        NEOUser *user = [(NEOAppDelegate *)[[UIApplication sharedApplication] delegate] user];
        [user postProfileInfoWithDictionary:[self dictionaryFromForm]];
    }
    
}


-(void)displaySavingIndicator
{
    
    UIActivityIndicatorView *saveIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    saveIndicator.center = self.view.center;
    [saveIndicator startAnimating];
    [self.view addSubview:saveIndicator];
}

#pragma mark Form Validation Methods

-(BOOL)allFieldsAreValid
{
    NEOProfileForm *form = (NEOProfileForm *)self.formController.form;
    
    NSMutableDictionary *toastOptions = [[NSMutableDictionary alloc]
                                         initWithDictionary:@{
                                                          kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
                                                          kCRToastBackgroundColorKey : [UIColor orangeColor],
                                                          kCRToastAnimationInTypeKey : @(CRToastAnimationTypeLinear),
                                                          kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeLinear),
                                                          kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionTop),
                                                          kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionTop)
                                                          }];
    
    
    
    if ([form.firstName isEqualToString:@""]) {
        toastOptions[@"kCRToastTextKey"] = @"First name cannot be blank.";
        [CRToastManager showNotificationWithOptions:toastOptions
                                    completionBlock:^{
                                    }];
        return NO;
    }
    
    if ([form.lastName isEqualToString:@""]) {
        toastOptions[@"kCRToastTextKey"] = @"Last name cannot be blank.";
        [CRToastManager showNotificationWithOptions:toastOptions
                                    completionBlock:^{
                                    }];
        return NO;
    }
    
    if (![self NSStringIsValidEmail:form.email]) {
        toastOptions[@"kCRToastTextKey"] = @"Invalid email address.";
        [CRToastManager showNotificationWithOptions:toastOptions
                                    completionBlock:^{
                                    }];
        return NO;
    }
    
    if (!([form.paypalEmail isEqualToString:@""] || [self NSStringIsValidEmail:form.paypalEmail])) {
        toastOptions[@"kCRToastTextKey"] = @"Invalid PayPal email address.";
        [CRToastManager showNotificationWithOptions:toastOptions
                                    completionBlock:^{
                                    }];
        return NO;
    }
    
    return YES;
}


-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}


#pragma mark Helper Methods

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


@end
