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
#import <CRToast/CRToast.h>

static int defaultCellHeight = 30;
static int defaultButtonWidth = 30;

#define tagFont [UIFont fontWithName:@"Lato-Regular" size:15.0]



/* 
 * When the user enters the tags controller, they will be presented with a collection view with all of their tags. The only requirements upon saving the edited tags are that there be at least 1 (3?) tags present, and no duplicate tags present. Do we need to save a duplicate tags array? No. When the user clicks the Back/Save Button, the program will analyze the current tags controller. If there are 0 (or less than 3) tags, it will pop up an alert view that forces continued editing. Swiping on the edge of the screen also needs to be turned off. We might also want an edit button. However, if the user tries to enter a tag that already exists, we need an alert view to pop up before it is added to the array.
 *
 
 * Necessary Features
 *** special collection view cell for adding a new tag
 *** implementation of server call to save tags
 *** text checking of tags to avoid duplicates
 *** design: custom "x" button, custom back button on navigation bar
 */


@interface NEOCustomTagsController ()

@property (strong, nonatomic) NSMutableArray *tags;
@property (strong, nonatomic) NSMutableArray *tempTags;
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
    
    return cell;
    
}

-(void)deleteButtonClicked:(NEOTagCollectionViewCell *)tagCell
{
    
    [self.tags removeObjectAtIndex:tagCell.indexPath.row];
    
    [UIView setAnimationsEnabled:NO];
    [self.tagsCollectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:tagCell.indexPath]];
    [self.tagsCollectionView reloadItemsAtIndexPaths:self.tagsCollectionView.indexPathsForVisibleItems];
    [UIView setAnimationsEnabled:YES];
    
    /* //Custom animation code will probably go here
    [UIView animateWithDuration:0 animations:^{
        [self.tagsCollectionView performBatchUpdates:^{
            
            
        }completion:nil];
    }];
    
    [self.tagsCollectionView.collectionViewLayout invalidateLayout];
    */
    
    if (![self.navigationItem.leftBarButtonItem.title isEqual:@"Save"]) {
        self.navigationItem.leftBarButtonItem.title = @"Save";
        //do I need to refresh this?
        
        
        /* //turn off swipe to return to dashboard
        NEOAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        [delegate.rootNav
         */
    }
}

-(BOOL)tagIsDuplicate:(NSString *)tag
{
    for (int i = 0; i < [_tags count]; i++) {
        if ([tag isEqualToString:_tags[i]]) {
            return YES;
        }
    }
    return NO;
}


-(void)saveAndCheckTags
{
    NEOAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    
    if (self.tags.count == 0) {
        //UIAlertView *noTagsAlert = [[UIAlertView alloc] initWithTitle:@"Hold up!" message:@"Please have at least one tag in order to be matched with campaigns." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
        //[noTagsAlert show];
        
        NSDictionary *toastOptions = @{
                                       kCRToastTextKey : @"You need at least one tag.",
                                       kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
                                       kCRToastBackgroundColorKey : [UIColor orangeColor],
                                       kCRToastAnimationInTypeKey : @(CRToastAnimationTypeLinear),
                                       kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeLinear),
                                       kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionTop),
                                       kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionTop),
                                       kCRToastAnimationOutTimeIntervalKey :
                                           @0.35,
                                       kCRToastAnimationInTimeIntervalKey :
                                           @0.35,
                                       kCRToastTimeIntervalKey :
                                           @0.8
                                       };
        [CRToastManager showNotificationWithOptions:toastOptions
                                    completionBlock:^{
                                        self.textField.text = @"add new tag";
                                    }];

        
    } else {
        NSDictionary *dict = @{@"tags": _tags};
        [delegate.user postProfileInfoWithDictionary:dict];
        [delegate.rootNav popViewControllerAnimated:YES];
    }
    
}

#pragma mark Text Field Methods
-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    NSCharacterSet *badSet = [[NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890 "] invertedSet];
    //if tag is duplicate, empty, or contains invalid characters
    if ([self tagIsDuplicate:textField.text]) {
        NSDictionary *toastOptions = @{
                                       kCRToastTextKey : @"Duplicate tag.",
                                       kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
                                       kCRToastBackgroundColorKey : [UIColor orangeColor],
                                       kCRToastAnimationInTypeKey : @(CRToastAnimationTypeLinear),
                                       kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeLinear),
                                       kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionTop),
                                       kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionTop),
                                       kCRToastAnimationOutTimeIntervalKey :
                                           @0.35,
                                       kCRToastAnimationInTimeIntervalKey :
                                           @0.35,
                                       kCRToastTimeIntervalKey :
                                           @0.75
                                       };
        [CRToastManager showNotificationWithOptions:toastOptions
                                    completionBlock:^{
                                        textField.text = @"add new tag";
                                    }];
    } else if (textField.text.length == 0) {
        
    } else if ([textField.text rangeOfCharacterFromSet:badSet].location != NSNotFound) {
        //UIAlertView causes the delete buttons to turn to black for some reason so that won't work here.
        NSDictionary *toastOptions = @{
                                       kCRToastTextKey : @"Invalid tag.",
                                       kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
                                       kCRToastBackgroundColorKey : [UIColor orangeColor],
                                       kCRToastAnimationInTypeKey : @(CRToastAnimationTypeLinear),
                                       kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeLinear),
                                       kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionTop),
                                       kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionTop),
                                       kCRToastAnimationOutTimeIntervalKey :
                                           @0.35,
                                       kCRToastAnimationInTimeIntervalKey :
                                           @0.35,
                                       kCRToastTimeIntervalKey :
                                           @0.5
                                       };
        [CRToastManager showNotificationWithOptions:toastOptions
                                    completionBlock:^{
                                        textField.text = @"add new tag";
                                    }];
    } else {
        NSString *lowercase = [textField.text lowercaseString];
        [self.tags addObject:lowercase];
        [UIView setAnimationsEnabled:NO];
        [self.tagsCollectionView reloadData];
        [UIView setAnimationsEnabled:YES];
        textField.text = @"add new tag";
    }
    [textField resignFirstResponder];
    return YES;
    
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    textField.text = @"";
    return YES;
}

#pragma mark Flow Layout Delegate Methods

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.tags.count) {
        return CGSizeMake(50, defaultCellHeight);
    } else {
        CGFloat width = [self.tags[indexPath.row] sizeWithAttributes:@{NSFontAttributeName: tagFont}].width;
        width = round(width+0.5) + defaultButtonWidth;
        return CGSizeMake(width, defaultCellHeight);
    }
    
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
        
        
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tagsCollectionView.collectionViewLayout = [[NEOTagFlowLayout alloc] init];
    [self.tagsCollectionView registerClass:[NEOTagCollectionViewCell class] forCellWithReuseIdentifier:@"neoTagCollectionViewCell"];
    self.tagsCollectionView.delegate = self;
    self.tagsCollectionView.dataSource = self;
    self.tagsCollectionView.backgroundColor = [UIColor whiteColor];
    
    //customize the navigation bar to have a custom tag option
    self.navigationItem.title = @"Tags";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" Back" style:UIBarButtonItemStyleBordered target:self action:@selector(saveAndCheckTags)];
    //[[UIBarButtonItem alloc] initWithImage:<#(UIImage *)#> style:<#(UIBarButtonItemStyle)#> target:<#(id)#> action:<#(SEL)#>]
    
    self.textField.font = [UIFont fontWithName:@"Lato-Light" size:20.0];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
