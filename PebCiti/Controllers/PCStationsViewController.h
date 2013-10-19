#import <UIKit/UIKit.h>
#import "PCStationList.h"

@protocol PCStationsViewControllerDelegate <NSObject>
- (void)stationsViewControllerIsDone;
@end

@interface PCStationsViewController : UITableViewController <PCStationListDelegate>

@property (nonatomic, weak, readonly) id<PCStationsViewControllerDelegate> delegate;

- (instancetype)initWithDelegate:(id<PCStationsViewControllerDelegate>)delegate;

@end
