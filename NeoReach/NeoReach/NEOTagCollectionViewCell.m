//
//  NEOTagCollectionViewCell.m
//  NeoReach
//
//  Created by Mathieu Rolfo on 8/15/14.
//  Copyright (c) 2014 NeoReach. All rights reserved.
//

#import "NEOTagCollectionViewCell.h"
#import "NEOAppDelegate.h"

#define BlueColor [UIColor colorWithRed:0.465639 green:0.763392 blue:1 alpha:1]


@implementation NEOTagCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"NEOTagCollectionViewCell" owner:self options:nil];
        
        self = [arrayOfViews objectAtIndex:0];
        self.tagTitle.textColor = [UIColor whiteColor];
        self.backgroundColor = BlueColor;
        self.tagTitle.font = [UIFont fontWithName:@"Lato-Regular" size:15.0];
        self.deleteButton.titleLabel.textColor = [UIColor whiteColor];
        
        [[self layer] setCornerRadius:10];
        self.clipsToBounds = YES;
        
    }
    return self;
}

-(IBAction)deleteClicked:(id)sender
{
    [self.delegate deleteButtonClicked:self];
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
