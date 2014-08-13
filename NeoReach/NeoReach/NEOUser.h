//
//  NEOUser.h
//  NeoReach
//
//  Created by Sam Crognale on 8/1/14.
//  Copyright (c) 2014 NeoReach. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NEOUser : NSObject
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSString *profilePictureURL;
@property (strong, nonatomic) UIImage *profilePicture;

@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *gender;
@property (strong, nonatomic) NSString *website;
@property (strong, nonatomic) NSDate *dateOfBirth;

@property (strong, nonatomic) NSString *paypalEmail;
@property NSInteger timezoneOffset;
@property (strong, nonatomic) NSArray *tags;

@property (strong, nonatomic) NSMutableArray *linkedAccounts;

@property (strong, nonatomic) NSString *fbXAuth;
@property (strong, nonatomic) NSString *fbXDigest;

// will send a 'profilePulled' notification on success. If X-Auth and X-Digest were invalid, sends an 'invalidHeaders' notification.
-(void) pullProfileInfo;


// will send a 'profilePosted' notification when finished. Requires a dictionary
// with the user fields to be edited. Automatically calls pullProfileInfo when finished.
-(void) postProfileInfoWithDictionary: (NSDictionary *)dict;

@end
