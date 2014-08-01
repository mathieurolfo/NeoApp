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


@property (strong, nonatomic) NSString *fbXAuth;
@property (strong, nonatomic) NSString *fbXDigest;

@end
