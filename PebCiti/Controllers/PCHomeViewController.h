#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import "PCStationsViewController.h"
#import "PCPebbleManager.h"

@interface PCHomeViewController : UIViewController <PCPebbleManagerDelegate, PCStationsViewControllerDelegate, CLLocationManagerDelegate>

@property (nonatomic, weak) IBOutlet UILabel *connectedPebbleLabel;
@property (nonatomic, weak) IBOutlet UIButton *connectToPebbleButton;
@property (nonatomic, weak) IBOutlet UILabel *currentLocationLabel;
@property (nonatomic, weak) IBOutlet UILabel *closestStationLabel;
@property (nonatomic, weak) IBOutlet UIButton *viewStationsButton;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)connectToPebbleButtonWasTapped:(UIButton *)connectToPebbleButton;
- (IBAction)viewStationsButtonWasTapped:(UIButton *)viewStationsButton;

@end
