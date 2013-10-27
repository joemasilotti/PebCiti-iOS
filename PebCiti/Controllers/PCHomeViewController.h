#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import "PCStationsViewController.h"
#import "PCPebbleManager.h"

@interface PCHomeViewController : UIViewController <PCPebbleManagerDelegate, PCStationsViewControllerDelegate, CLLocationManagerDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) IBOutlet UISwitch *sendMessagesSwitch;
@property (nonatomic, weak) IBOutlet UILabel *currentLocationLabel;
@property (nonatomic, weak) IBOutlet UILabel *closestStationLabel;
@property (nonatomic, weak) IBOutlet UIButton *viewStationsButton;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)sendMessagesSwitchWasToggled:(UISwitch *)sendMessagesSwitch;
- (IBAction)viewStationsButtonWasTapped:(UIButton *)viewStationsButton;

@end
