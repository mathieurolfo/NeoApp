//
//  NEOLoginController.h
//  NeoReach
//
//  Created by Sam Crognale on 7/21/14.
//  Copyright (c) 2014 NeoReach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NEOSessionConfigContainer.h"

@interface NEOLoginController : UIViewController <UIWebViewDelegate, NSCoding>

@property (weak, nonatomic) IBOutlet UILabel *logInOutInfoLabel;
@property (weak, nonatomic) IBOutlet UIImageView *splashImage;
@property (weak, nonatomic) IBOutlet UILabel *neoReachLabel;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) UIActivityIndicatorView *loginIndicator;
@property (strong, nonatomic) NSURLSessionConfiguration *sessionConfig;
@property (strong, nonatomic) NEOSessionConfigContainer *sessionContainer;

-(BOOL)saveChanges;
-(NSString *)configArchivePath;

@end
