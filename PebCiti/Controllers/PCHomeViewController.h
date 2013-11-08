#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import "PCStationsViewController.h"
#import "PCPebbleManager.h"

enum {
    PCFocusTypeBike = 0,
    PCFocusTypeDock
};
typedef NSUInteger PCFocusType;


@interface PCHomeViewController : UITableViewController <PCPebbleManagerDelegate, CLLocationManagerDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) IBOutlet UISegmentedControl *focusSegmentControl;
@property (nonatomic, weak) IBOutlet UISwitch *sendMessagesSwitch;
@property (nonatomic, weak) IBOutlet UILabel *vibratePebbleLabel;
@property (nonatomic, weak) IBOutlet UISwitch *vibratePebbleSwitch;
@property (nonatomic, weak) IBOutlet UILabel *currentLocationLabel;
@property (nonatomic, weak) IBOutlet UILabel *closestStationLabel;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, readonly) PCFocusType focusType;

- (IBAction)focusSegmentControlValueWasChanged:(UISegmentedControl *)focusSegmentControl;
- (IBAction)sendMessagesSwitchWasToggled:(UISwitch *)sendMessagesSwitch;
- (IBAction)vibratePebbleSwitchWasToggled:(UISwitch *)vibratePebbleSwitch;

@end
