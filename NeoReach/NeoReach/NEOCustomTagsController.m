//
//  NEOCustomTagsController.m
//  NeoReach
//
//  Created by Mathieu Rolfo on 8/15/14.
//  Copyright (c) 2014 NeoReach. All rights reserved.
//

#import "NEOCustomTagsController.h"
#import "NEOAppDelegate.h"
#import "NEOTagCollectionViewCell.h"
#import "NEOTagFlowLayout.h"

@interface NEOCustomTagsController ()

@property (strong, nonatomic) NSMutableArray *tags;
@property (weak, nonatomic) IBOutlet UICollectionView *tagsCollectionView;

@end

@implementation NEOCustomTagsController

#pragma mark UICollectionViewDataSource Methods

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.tags count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"neoTagCollectionViewCell";
    NEOTagCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.tagTitle.text = [self.tags objectAtIndex:indexPath.row];
    NSLog(@"%@", cell.tagTitle.text);
    NSLog(@"cell is %f by %f using bounds", cell.bounds.size.width, cell.bounds.size.height);
    return cell;
}

#pragma mark Flow Layout Delegate Methods

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    //NSLog(@"%@", cell.tagTitle.text);
    
    UIFont *tagFont = [UIFont fontWithName:@"Lato-Regular" size:13.0];
    CGFloat width = [self.tags[indexPath.row] sizeWithAttributes:@{NSFontAttributeName: tagFont}].width;
    width = round(width+0.5) + 30;
    //CGFloat height = [cell.tagTitle.text sizeWithAttributes:@{NSFontAttributeName: cell.tagTitle.font}].height;
    NSLog(@"%f", width);
    return CGSizeMake(width, 30);
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 7.0;
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10.0;
}


#pragma mark Default Initialization Methods
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UINavigationItem *navItem = self.navigationItem;
        navItem.title = @"Tags";
        
        NEOUser *user = [(NEOAppDelegate *)[[UIApplication sharedApplication] delegate] user];
        self.tags = [[NSMutableArray alloc] initWithArray:user.tags];
        NSLog(@"%@", self.tags);
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tagsCollectionView.collectionViewLayout = [[NEOTagFlowLayout alloc] init];
    
    [self.tagsCollectionView registerClass:[NEOTagCollectionViewCell class] forCellWithReuseIdentifier:@"neoTagCollectionViewCell"];
    //UINib *cellNib = [UINib nibWithNibName:@"NEOTagCollectionViewCell" bundle:nil];
    //[self.tagsCollectionView registerNib:cellNib forCellWithReuseIdentifier:@"neoTagCollectionViewCell"];
    
    self.tagsCollectionView.delegate = self;
    self.tagsCollectionView.dataSource = self;
    self.tagsCollectionView.backgroundColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
