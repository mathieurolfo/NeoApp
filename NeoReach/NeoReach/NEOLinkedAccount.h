//
//  NEOLinkedAccount.h
//  NeoReach
//
//  Created by Sam Crognale on 8/7/14.
//  Copyright (c) 2014 NeoReach. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NEOLinkedAccount : NSObject

@property (strong, nonatomic) NSString *fullName; // full user name, e.g. "Juliana Wetmore"
@property (strong, nonatomic) NSString *name; //name of account website, e.g. "facebook.com"
@property (strong, nonatomic) NSString *picURL;
@property (strong, nonatomic) NSString *pid;
@property NSUInteger reach;

@end
