
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
    //NSLog(@"%@", indexPath);

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
    return cell;
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
    
    //clicking profile information takes you to profile info
    if (indexPath.section == 1 && indexPath.row == 0) {
        NEOProfileInfoController *profileController = [[NEOProfileInfoController alloc] init];
        [delegate.rootNav pushViewController:profileController animated:YES];
        NSLog(@"pushing profileController");
       
                [delegate.drawer closeDrawerAnimated:YES completion:^(BOOL completed) {
            
        }];
    }

    //clicking link accounts brings you to link accounts page (?)
    /* if (indexPath.section == 1 && indexPath.row == 1) {
        NEOProfileInfoController *profileController = [[NEOProfileInfoController alloc] init];
        [delegate.rootNav pushViewController:profileController animated:YES];
        NSLog(@"pushing profileController");
        // delegate.rootNav.presentedViewController.navigationItem.title = @"Pro";
        UINavigationItem *navItem = profileController.navigationItem;
        navItem.title = @"Profile Info";
        [delegate.drawer closeDrawerAnimated:YES completion:^(BOOL completed) {
            
        }];
    } */

    //clicking tags brings you to display of tags
    if (indexPath.section == 1 && indexPath.row == 2) {
        NEOTagsController *tagsController = [[NEOTagsController alloc] init];
        [delegate.rootNav pushViewController:tagsController animated:YES];
        NSLog(@"pushing tagsController");
        [delegate.drawer closeDrawerAnimated:YES completion:^(BOOL completed) {
            
        }];
    }

    
    //clicking logout button returns to login screen
    if (indexPath.section == 1 && indexPath.row == 3) {
        
        [delegate.login.loginIndicator stopAnimating];
        [delegate.login.loginButton setEnabled:YES];
        delegate.login.logInOutInfoLabel.text = @"Successfully logged out";
        delegate.drawer.centerViewController = delegate.login;
        //[[NSURLCache sharedURLCache] removeAllCachedResponses];
        
        //deletes login info!!! feels a little too shotgun though.
        for(NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
        
        
        [delegate.drawer closeDrawerAnimated:YES completion:^(BOOL completed) {
            
        }];
    }
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Other Methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateName) name:@"doUpdateName" object:nil];
    }
    return self;
}

-(void)updateName
{
    
    NEOAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.nameLabel.text = [NSString stringWithFormat:@"     Welcome, %@", delegate.user.firstName];
        //[self.nameLabel setNeedsLayout];
        NSLog(@"Updated Name in Side Menu");
    });
    

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.nameLabel.font = [UIFont fontWithName:@"Lato-Bold" size:16.0];
    self.nameLabel.text = @"    Welcome";
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
