//
//  NEOCampaign.h
//  NeoReach
//
//  Created by Sam Crognale on 8/1/14.
//  Copyright (c) 2014 NeoReach. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NEOCampaign : NSObject
@property (strong, nonatomic) NSString *ID;

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *promotion;
@property                        float costPerClick;
@property                    NSUInteger totalClicks;
@property (strong, nonatomic) NSDate *creationDate;

@property (strong, nonatomic) NSString *imageURL;
@property (strong, nonatomic) UIImage *image;

@property (strong, nonatomic) NSString *referralURL;

/* Sends a "campaignURLGenerated" notification when completed. */
-(void)generateReferralURL;

@end
