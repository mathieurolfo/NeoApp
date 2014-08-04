//
//  NEOLoginController.h
//  NeoReach
//
//  Created by Sam Crognale on 7/21/14.
//  Copyright (c) 2014 NeoReach. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NEOLoginController : UIViewController <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *logInOutInfoLabel;
@property (weak, nonatomic) IBOutlet UIImageView *splashImage;
@property (weak, nonatomic) IBOutlet UILabel *neoReachLabel;


@end
