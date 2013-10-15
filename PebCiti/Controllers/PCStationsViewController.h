#import <UIKit/UIKit.h>

@protocol PCStationsViewControllerDelegate <NSObject>
- (void)stationsViewControllerIsDone;
@end

@interface PCStationsViewController : UITableViewController

@property (nonatomic, weak, readonly) id<PCStationsViewControllerDelegate> delegate;

- (instancetype)initWithDelegate:(id<PCStationsViewControllerDelegate>)delegate;

@end
