//
//  NEOTagFlowLayout.m
//  NeoReach
//
//  Created by Mathieu Rolfo on 8/15/14.
//  Copyright (c) 2014 NeoReach. All rights reserved.
//

#import "NEOTagFlowLayout.h"

@implementation NEOTagFlowLayout

-(id)init
{
    self = [super init];
    //self.itemSize = CGSizeMake(40, 100);
    self.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    return self;
}

@end
