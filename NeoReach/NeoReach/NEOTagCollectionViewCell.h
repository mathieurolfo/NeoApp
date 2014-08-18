//
//  NEOTagCollectionViewCell.h
//  NeoReach
//
//  Created by Mathieu Rolfo on 8/15/14.
//  Copyright (c) 2014 NeoReach. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NEOTagCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
- (IBAction)deleteClicked:(id)sender;


@property (strong, nonatomic) IBOutlet UILabel *tagTitle;
@property (strong, nonatomic) NSIndexPath *indexPath;




@end
