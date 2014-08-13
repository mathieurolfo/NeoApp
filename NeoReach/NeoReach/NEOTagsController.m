//
//  NEOTagsController.m
//  
//
//  Created by Mathieu Rolfo on 7/28/14.
//
//

#import "NEOTagsController.h"
#import "NEOAppDelegate.h"

@interface NEOTagsController ()
@property (strong, nonatomic) NSMutableArray *tags;
@end

@implementation NEOTagsController

#pragma mark - Table View Protocol Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_tags count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *) indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.textLabel.text = _tags[indexPath.row];

    return cell;
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

- (IBAction)addTag:(id)sender
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Add a Tag" message:nil delegate:self cancelButtonTitle:@"Add" otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"Entered: %@",[[alertView textFieldAtIndex:0] text]);
    [_tags addObject:[[alertView textFieldAtIndex:0] text]];
    
    [_tableView reloadData];
}

-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        [self updateUserTags];
    }
    [super viewWillDisappear:animated];
}


-(void) updateUserTags
{
    NEOUser *user = [(NEOAppDelegate *)[[UIApplication sharedApplication] delegate] user];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    NSString *dobString = [dateFormatter stringFromDate:user.dateOfBirth];

    NSDictionary *dict = @{
                           @"tags": _tags,
                           
                           // These fields are not updated in tags
                           @"email" : user.email,
                           @"name" : @{@"first":user.firstName, @"last":user.lastName},
                           @"gender": user.gender,
                           @"website": user.website,
                           @"dob": dobString,
                           @"paypalEmail": user.paypalEmail,
                           @"timezoneOffset": [NSNumber numberWithLong:user.timezoneOffset]
                           };
    
    [user postProfileInfoWithDictionary:dict];
    
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
