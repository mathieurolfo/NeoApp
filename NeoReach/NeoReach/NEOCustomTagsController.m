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
    cell.indexPath = indexPath;
    cell.delegate = self;
    
    //NSLog(@"%@", cell.tagTitle.text);
    //NSLog(@"cell is %f by %f using bounds", cell.bounds.size.width, cell.bounds.size.height);
    return cell;
    
}

-(void)deleteButtonClicked:(NEOTagCollectionViewCell *)tagCell
{
    
    if (self.tags.count == 1) {
        
    } else {
        [self.tags removeObjectAtIndex:tagCell.indexPath.row];
        [UIView setAnimationsEnabled:NO];
        [self.tagsCollectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:tagCell.indexPath]];
        
        [self.tagsCollectionView reloadItemsAtIndexPaths:self.tagsCollectionView.indexPathsForVisibleItems];
        [UIView setAnimationsEnabled:YES];
        [UIView animateWithDuration:0 animations:^{
            [self.tagsCollectionView performBatchUpdates:^{
                
                
            }completion:nil];
        }];
    }
    
    
    //[self.tagsCollectionView.collectionViewLayout invalidateLayout];
    

}

#pragma mark Flow Layout Delegate Methods

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    UIFont *tagFont = [UIFont fontWithName:@"Lato-Regular" size:13.0];
    CGFloat width = [self.tags[indexPath.row] sizeWithAttributes:@{NSFontAttributeName: tagFont}].width;
    width = round(width+0.5) + 30;
    //CGFloat height = [cell.tagTitle.text sizeWithAttributes:@{NSFontAttributeName: cell.tagTitle.font}].height;
    //NSLog(@"%f", width);
    return CGSizeMake(width, 26);
   
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

        NEOUser *user = [(NEOAppDelegate *)[[UIApplication sharedApplication] delegate] user];
        self.tags = [[NSMutableArray alloc] initWithArray:user.tags];
        //NSLog(@"%@", self.tags);
        
        
    }
    return self;
}

-(void)saveAndCheckTags
{
    NEOAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSLog(@"Using custom back button...");
    [delegate.rootNav popViewControllerAnimated:YES];
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
    
    //customize the navigation bar to have a custom tag option
    self.navigationItem.title = @"Tags";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" Back" style:UIBarButtonItemStyleBordered target:self action:@selector(saveAndCheckTags)];
    
    //[[UIBarButtonItem alloc] initWithImage:<#(UIImage *)#> style:<#(UIBarButtonItemStyle)#> target:<#(id)#> action:<#(SEL)#>]
    

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
