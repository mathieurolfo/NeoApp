//
//  NEOTagsController.m
//  
//
//  Created by Mathieu Rolfo on 7/28/14.
//
//

#import "NEOTagsController.h"
#import "NEOAppDelegate.h"
#import <CRToast/CRToast.h>


@interface NEOTagsController ()
@property (strong, nonatomic) NSMutableArray *tags;


@end

@implementation NEOTagsController


/* Save button code
 
 UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
 CGRect screenRect = [[UIScreen mainScreen] bounds];
 saveButton.frame = CGRectMake(0, 0, screenRect.size.width, 40.0);
 [saveButton setTitle:@"Save" forState:UIControlStateNormal];
 [saveButton addTarget:self
 action:@selector(updateUserTags:)
 forControlEvents:UIControlEventTouchUpInside];

*/


#pragma mark - Default Initialization Methods

-(void) loadView
{
        
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark Tag Display Methods

- (IBAction)addTag:(id)sender
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Add a Tag" message:nil delegate:self cancelButtonTitle:@"Add" otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

    [_tags addObject:[[alertView textFieldAtIndex:0] text]];

    
    NSString *newTag = [[[alertView textFieldAtIndex:0] text] lowercaseString];
    
    if ([newTag isEqualToString:@""]) {
        NSDictionary *toastOptions = @{
                                       kCRToastTextKey : @"Tag cannot be blank.",
                                       kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
                                       kCRToastBackgroundColorKey : [UIColor orangeColor],
                                       kCRToastAnimationInTypeKey : @(CRToastAnimationTypeLinear),
                                       kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeLinear),
                                       kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionTop),
                                       kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionTop)
                                       };
        [CRToastManager showNotificationWithOptions:toastOptions
                                    completionBlock:^{
                                    }];
        
    } else if ([self tagIsDuplicate:newTag]) {
        NSDictionary *toastOptions = @{
                                       kCRToastTextKey : [NSString stringWithFormat:
                                                          @"\"%@\" is already a tag.",newTag],
                                       kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
                                       kCRToastBackgroundColorKey : [UIColor orangeColor],
                                       kCRToastAnimationInTypeKey : @(CRToastAnimationTypeLinear),
                                       kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeLinear),
                                       kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionTop),
                                       kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionTop)
                                       };
        [CRToastManager showNotificationWithOptions:toastOptions
                                    completionBlock:^{
                                    }];

    } else {
        [_tags addObject:newTag];
        //[_tableView reloadData];
    }
}

-(BOOL)tagIsDuplicate:(NSString *)tag
{
    for (int i = 0; i < [_tags count]; i++) {
        if ([tag isEqualToString:_tags[i]]) {
            return YES;
        }
    }
    return NO;
}

-(IBAction)updateUserTags:(id) sender
{


    if ([_tags count] == 0) {
        NSDictionary *toastOptions = @{
                                  kCRToastTextKey : @"Please enter at least one tag.",
                                  kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
                                  kCRToastBackgroundColorKey : [UIColor orangeColor],
                                  kCRToastAnimationInTypeKey : @(CRToastAnimationTypeLinear),
                                  kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeLinear),
                                  kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionTop),
                                  kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionTop)
                                  };
        [CRToastManager showNotificationWithOptions:toastOptions
                                    completionBlock:^{
                                    }];

        
    } else {
    NEOUser *user = [(NEOAppDelegate *)[[UIApplication sharedApplication] delegate] user];
    NSDictionary *dict = @{
                           @"tags": _tags
                           };
    
    [user postProfileInfoWithDictionary:dict];
    [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
}



@end
