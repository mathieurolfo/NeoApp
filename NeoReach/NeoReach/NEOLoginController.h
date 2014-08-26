//
//  NEOLoginController.h
//  NeoReach
//
//  Created by Sam Crognale on 7/21/14.
//  Copyright (c) 2014 NeoReach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface NEOLoginController : UIViewController <FBLoginViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *logInOutInfoLabel;
@property (weak, nonatomic) IBOutlet UIImageView *splashImage;
@property (weak, nonatomic) IBOutlet UILabel *neoReachLabel;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) UIActivityIndicatorView *loginIndicator;
@property (nonatomic, strong) NSString *token;

-(void)endSuccessfulRequest;
-(void)endUnsuccessfulRequest;

@end
