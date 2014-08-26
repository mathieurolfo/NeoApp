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

#pragma mark - Table View Protocol Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_tags count] + 1; // plus one for save button
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *) indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    if (indexPath.row < [_tags count]) {
        cell.textLabel.text = _tags[indexPath.row];
    } else { // Save button
        UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        saveButton.frame = CGRectMake(0, 0, screenRect.size.width, 40.0);
        [saveButton setTitle:@"Save" forState:UIControlStateNormal];
        [saveButton addTarget:self
                       action:@selector(updateUserTags:)
         forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:saveButton];
    }
    

    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If the table view is asking us to commit a delete command...
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_tags removeObjectAtIndex:indexPath.row];
        
        // Also remove that row from the table view with an animation
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    
}

#pragma mark Tag Management Methods

- (IBAction)addTag:(id)sender
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Add a Tag" message:nil delegate:self cancelButtonTitle:@"Add" otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
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



#pragma mark - Default Initialization Methods
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UINavigationItem *navItem = self.navigationItem;
        navItem.title = @"Tags";
        
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTag:)];
        navItem.rightBarButtonItem = addButton;
        
        NEOUser *user = [(NEOAppDelegate *)[[UIApplication sharedApplication] delegate] user];
        _tags = [[NSMutableArray alloc] initWithArray:user.tags];
        
        
    }
    return self;
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

    
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
        [_tableView reloadData];
    }
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

@end
