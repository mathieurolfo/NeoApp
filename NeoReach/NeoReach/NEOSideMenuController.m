
//
//  NEOSideMenuController.m
//  NeoReach
//
//  Created by Sam Crognale on 7/21/14.
//  Copyright (c) 2014 NeoReach. All rights reserved.
//

#import "NEOSideMenuController.h"
#import "NEOAppDelegate.h"
#import "NEOProfileInfoController.h"
#import "NEOTagsController.h"
#import "UIWebView+Clean.h"
#import "NEOAccountsController.h"
#import "NEOReferralLinkController.h"
#import "NEOCustomTagsController.h"

@interface NEOSideMenuController ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation NEOSideMenuController

#pragma mark - Menu Table View Protocol Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 2;
            break;
        case 1:
            return 4;
            break;
    }
    return 0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *) indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];

    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Payment";
                    break;
                case 1:
                    cell.textLabel.text = @"Invite Friends";
                    break;
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Profile Information";
                    break;
                case 1:
                    cell.textLabel.text = @"Link Accounts";
                    break;
                case 2:
                    cell.textLabel.text = @"Tags";
                    break;
                case 3:
                    cell.textLabel.text = @"Log Out";
                    break;
            }
        }
    cell.textLabel.font = [UIFont fontWithName:@"Lato-Regular" size:16.0];
    cell.backgroundColor = [UIColor orangeColor];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"    FINANCIAL INFORMATION";
        case 1:
            return @"    PERSONAL DETAILS";
        }
    return @"";
}

/*
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0;
}
*/

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UILabel *myLabel = [[UILabel alloc] init];
    myLabel.frame = CGRectMake(0, 0, 320, 22);
    myLabel.font = [UIFont boldSystemFontOfSize:12];
    myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    myLabel.backgroundColor = [UIColor lightGrayColor];
    
    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:myLabel];
    
    return headerView;
}

#pragma mark - Table View Cells Clicked

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NEOAppDelegate *delegate = (NEOAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (indexPath.section == 0 && indexPath.row == 1) {
        NEOReferralLinkController *referralLinkController = [[NEOReferralLinkController alloc] init];
        [delegate disableDrawerAccess];
        [delegate.rootNav pushViewController:referralLinkController animated:YES];
        [delegate.drawer closeDrawerAnimated:YES completion:^(BOOL completed) {
            
        }];
    }
    
    //clicking profile information takes you to profile info
    if (indexPath.section == 1 && indexPath.row == 0) {
        NEOProfileInfoController *profileController = [[NEOProfileInfoController alloc] init];
        [delegate disableDrawerAccess];
        [delegate.rootNav pushViewController:profileController animated:YES];
        [delegate.drawer closeDrawerAnimated:YES completion:^(BOOL completed) {
            
        }];
    }

    //clicking link accounts brings you to link accounts page
     if (indexPath.section == 1 && indexPath.row == 1) {
        [delegate disableDrawerAccess];
        NEOAccountsController *accountsController = [[NEOAccountsController alloc] init];
        [delegate.rootNav pushViewController:accountsController animated:YES];
        [delegate.drawer closeDrawerAnimated:YES completion:^(BOOL completed) {
            
        }];
    }

    //clicking tags brings you to display of tags
    if (indexPath.section == 1 && indexPath.row == 2) {
        [delegate disableDrawerAccess];
        NEOCustomTagsController *tagsController = [[NEOCustomTagsController alloc] init];
        [delegate.rootNav pushViewController:tagsController animated:YES];
        [delegate.drawer closeDrawerAnimated:YES completion:^(BOOL completed) {
            
        }];
    }

    
    //clicking logout button returns to login screen
    if (indexPath.section == 1 && indexPath.row == 3) {
        [delegate disableDrawerAccess];
        [delegate.login.loginIndicator stopAnimating];
        [delegate.login.loginButton setEnabled:YES];
        delegate.login.logInOutInfoLabel.text = @"Successfully logged out";
        delegate.drawer.centerViewController = delegate.login;

        //deletes stored session configuration
        delegate.xAuth = nil;
        delegate.xDigest = nil;

        delegate.sessionConfig = nil;
        delegate.sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"xAuth"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"xDigest"];
        NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
        
        //[FBSession.activeSession closeAndClearTokenInformation];
        delegate.login.token = nil;
        
        NSLog(@"Removed auth and digest");

        [delegate.drawer closeDrawerAnimated:YES completion:nil];
    }
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark Alert View Methods

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NEOAppDelegate *delegate = (NEOAppDelegate *)[[UIApplication sharedApplication] delegate];
    NEOProfileInfoController *profileController = [[NEOProfileInfoController alloc] init];
    [delegate.rootNav pushViewController:profileController animated:YES];
    [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
}

#pragma mark - Other Methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateName) name:@"profileUpdated" object:nil];
    }
    return self;
}

-(void)updateName
{
    
    NEOAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.nameLabel.text = [NSString stringWithFormat:@"     Welcome, %@", delegate.user.firstName];
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.nameLabel.font = [UIFont fontWithName:@"Lato-Bold" size:16.0];
    self.nameLabel.text = @"    Welcome";
    self.tableView.backgroundColor = [UIColor orangeColor];
    self.tableView.scrollEnabled = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
