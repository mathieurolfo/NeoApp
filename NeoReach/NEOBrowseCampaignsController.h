//
//  NEOBrowseCampaignsController.h
//  NeoReach
//
//  Created by Sam Crognale on 7/21/14.
//  Copyright (c) 2014 NeoReach. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NEOBrowseCampaignsController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSURLSession *session;
@end
