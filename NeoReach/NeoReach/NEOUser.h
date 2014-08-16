//
//  NEOUser.h
//  NeoReach
//
//  Created by Sam Crognale on 8/1/14.
//  Copyright (c) 2014 NeoReach. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NEOUser : NSObject

/* These properties are pulled from the NeoReach server. They should not be directly
 * modified; user info should be pulled with pullProfileInfo and modified with 
 * postProfileInfoWithDictionary.
 */
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *gender;
@property (strong, nonatomic) NSString *website;
@property (strong, nonatomic) NSDate *dateOfBirth;
@property (strong, nonatomic) NSString *paypalEmail;
@property NSInteger timezoneOffset;
@property (strong, nonatomic) NSArray *tags;

/* These properties are pulled from the server, but cannot be changed with postProfileInfoWithDictionary. */
@property CGFloat totalEarnings;
@property NSUInteger totalClicks;
@property (strong, nonatomic) NSArray *campaigns;
@property (strong, nonatomic) NSArray *linkedAccounts;
@property (strong, nonatomic) NSString *profilePictureURL;
@property (strong, nonatomic) UIImage *profilePicture;

/* These properties are local. Do with them what you please. */
@property (strong, nonatomic) NSString *fbXAuth;
@property (strong, nonatomic) NSString *fbXDigest;



/* Sends a 'profilePulled' notification on success. If X-Auth and X-Digest were invalid, sends an
 *'invalidHeaders' notification.
 */
-(void) pullProfileInfo;

/* Sends a 'profilePosted' notification when finished. Requires a dictionary with the user fields
 * to be edited. Automatically calls pullProfileInfo when finished.
 */
-(void) postProfileInfoWithDictionary: (NSDictionary *)dict;

/* Sends a 'campaignsPulled' notification on success. */
-(void) pullCampaigns;
@end
