//
//  NEOAccountsController.m
//  NeoReach
//
//  Created by Sam Crognale on 8/7/14.
//  Copyright (c) 2014 NeoReach. All rights reserved.
//

#import "NEOAccountsController.h"
#import "NEOLinkedAccountCell.h"
#import "NEOLinkedAccount.h"
#import "NEOUser.h"
#import "NEOAppDelegate.h"

@interface NEOAccountsController ()

@end

@implementation NEOAccountsController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UINavigationItem *navItem = self.navigationItem;
        navItem.title = @"Link Accounts";
        


    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UINib *accountNib = [UINib nibWithNibName:@"NEOLinkedAccountCell" bundle:nil];
    [self.tableView registerNib:accountNib forCellReuseIdentifier:@"NEOLinkedAccountCell"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NEOUser *user = [(NEOAppDelegate *)[[UIApplication sharedApplication] delegate] user];
    return [user.linkedAccounts count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *) indexPath
{
    NEOUser *user = [(NEOAppDelegate *)[[UIApplication sharedApplication] delegate] user];

    
    NEOLinkedAccountCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NEOLinkedAccountCell"
                                                                 forIndexPath:indexPath];
    

    
    NEOLinkedAccount *account = user.linkedAccounts[indexPath.row];
    
    cell.reachLabel.text = [NSString stringWithFormat:@"%lu",account.reach];
    cell.nameLabel.text = account.fullName;
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}


@end
