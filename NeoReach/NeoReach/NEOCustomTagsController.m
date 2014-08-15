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
    
    static NSString *cellIdentifier = @"NEOTagCollectionViewCell";
    NEOTagCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.tagTitle.text = [self.tags objectAtIndex:indexPath.row];
    return cell;
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
        
        
        //self.tagsCollectionView.collectionViewLayout = ;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.tagsCollectionView registerClass:[NEOTagCollectionViewCell class] forCellWithReuseIdentifier:@"NEOTagCollectionViewCell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
