//
//  NEOProfileInfoController.m
//  NeoReach
//
//  Created by Mathieu Rolfo on 7/23/14.
//  Copyright (c) 2014 NeoReach. All rights reserved.
//

#import "NEOProfileInfoController.h"
#import "NEODashboardHeaderCell.h"
#import "NEOAppDelegate.h"

@interface NEOProfileInfoController ()

@end

@implementation NEOProfileInfoController


#pragma mark TableViewDelegate Protocol Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    switch (indexPath.row) {
            /*
        case 0:
        {
            NEOAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
            NEODashboardProfileCell *prc = [tableView dequeueReusableCellWithIdentifier:@"NEODashboardProfileCell" forIndexPath:indexPath];
            
            prc.profileImage.image = [UIImage imageNamed:@"juliana.png"];
            
            NSString *username = [NSString stringWithFormat:@"%@ %@", [[delegate.userProfileDictionary valueForKeyPath:@"data.Profile.name.first"] objectAtIndex:0], [[delegate.userProfileDictionary valueForKeyPath:@"data.Profile.name.last"] objectAtIndex:0]];
            prc.nameLabel.text = username;

            cell = (UITableViewCell *)prc;
            break;
        }
             */
        default:
            cell = [[UITableViewCell alloc] init];
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    CGFloat height = 0.0;
    
    switch (indexPath.row) {
        case 0: // picture
            height = screenHeight / 3;
            break;
        /*case 1: // browse
            height = screenHeight / 16;
            break;
        case 2: // stats
            height = screenHeight / 4;
            break; */
        default: // posts
            height = screenHeight / 12;
    }
    
    return height;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UINavigationItem *navItem = self.navigationItem;
        navItem.title = @"Profile Info";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
