//
//  NEOSessionConfigContainer.h
//  NeoReach
//
//  Created by Mathieu Rolfo on 8/12/14.
//  Copyright (c) 2014 NeoReach. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NEOSessionConfigContainer : NSObject <NSCoding>

@property (strong, nonatomic) NSURLSessionConfiguration *sessionConfig;

@end
