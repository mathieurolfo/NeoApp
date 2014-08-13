//
//  NEOTagsController.h
//  
//
//  Created by Mathieu Rolfo on 7/28/14.
//
//

#import <UIKit/UIKit.h>

@interface NEOTagsController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
