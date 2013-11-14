#import <UIKit/UIKit.h>
#import "PCStationList.h"

@interface PCStationsViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UIBarButtonItem *sortButton;

- (IBAction)sortButtonWasTapped:(UIBarButtonItem *)sender;

@end
