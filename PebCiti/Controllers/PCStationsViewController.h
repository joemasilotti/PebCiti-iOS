#import <UIKit/UIKit.h>

@protocol PCStationsViewControllerDelegate <NSObject>
- (void)stationsViewControllerIsDone;
@end

@interface PCStationsViewController : UITableViewController <NSURLConnectionDataDelegate>

@property (nonatomic, weak, readonly) id<PCStationsViewControllerDelegate> delegate;

- (instancetype)initWithDelegate:(id<PCStationsViewControllerDelegate>)delegate;

@end
