//
//  NEOBrowseCampaignsCell.h
//  NeoReach
//
//  Created by Sam Crognale on 9/2/14.
//  Copyright (c) 2014 NeoReach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NEOCampaign.h"

#define BROWSE_LOGO_HEIGHT 160.0
#define BROWSE_GEN_LINK_HEIGHT 40.0
#define BROWSE_DETAILS_HEIGHT_WITHOUT_TEXT 32.0 // 8.0 + 16.0 + 8.0


@interface NEOBrowseCampaignsCell : UITableViewCell <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NEOCampaign *campaign;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
