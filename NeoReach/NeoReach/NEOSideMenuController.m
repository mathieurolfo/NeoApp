
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

@interface NEOSideMenuController ()
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
    NSLog(@"%@", indexPath);
    
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
        // delegate.rootNav.presentedViewController.navigationItem.title = @"Pro";
        UINavigationItem *navItem = profileController.navigationItem;
        navItem.title = @"Profile Info";
        
    }

    
    //clicking logout button returns to login screen
    if (indexPath.section == 1 && indexPath.row == 3) {
        //[delegate.rootNav pushViewController:delegate.login animated:YES];
        
        delegate.login.logInOutInfoLabel.text = @"Successfully logged out";
        delegate.drawer.centerViewController = delegate.login;
        
    }
    
    [delegate.drawer closeDrawerAnimated:YES completion:^(BOOL completed) {
        
    }];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Other Methods

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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
