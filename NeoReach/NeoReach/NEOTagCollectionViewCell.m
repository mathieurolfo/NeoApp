//
//  NEOTagCollectionViewCell.m
//  NeoReach
//
//  Created by Mathieu Rolfo on 8/15/14.
//  Copyright (c) 2014 NeoReach. All rights reserved.
//

#import "NEOTagCollectionViewCell.h"

@implementation NEOTagCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"NEOTagCollectionViewCell" owner:self options:nil];
        
        self = [arrayOfViews objectAtIndex:0];
        self.tagTitle.textColor = [UIColor blackColor];
        self.backgroundColor = [UIColor lightGrayColor];
        self.tagTitle.font = [UIFont fontWithName:@"Lato-Regular" size:13.0];
    }
    return self;
}

-(CGSize)intrinsicContentSize
{
    [self.tagTitle sizeToFit];
    CGSize size = [self.tagTitle intrinsicContentSize];
    
    size.width += 5;
    size.height += 5;
    
    
    return size;
   
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
