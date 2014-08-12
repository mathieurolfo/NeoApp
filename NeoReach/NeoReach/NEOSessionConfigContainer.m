//
//  NEOSessionConfigContainer.m
//  NeoReach
//
//  Created by Mathieu Rolfo on 8/12/14.
//  Copyright (c) 2014 NeoReach. All rights reserved.
//

#import "NEOSessionConfigContainer.h"

@implementation NEOSessionConfigContainer

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        self.sessionConfig = [coder decodeObjectForKey:@"sessionConfig"];
    }
    NSLog(@"unarchived sessionConfig");
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.sessionConfig forKey:@"sessionConfig"];
}

-(NSString *)configArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories firstObject];
    return [documentDirectory stringByAppendingPathComponent:@"config.archive"];
}

-(BOOL)saveChanges
{
    NSString *path = [self configArchivePath];
    return [NSKeyedArchiver archiveRootObject:self.sessionConfig toFile:path];
}

@end
