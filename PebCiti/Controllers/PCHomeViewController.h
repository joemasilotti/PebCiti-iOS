#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import "PCStationsViewController.h"
#import "PCPebbleManager.h"

@interface PCHomeViewController : UIViewController <PCPebbleManagerDelegate, UITextFieldDelegate, PCStationsViewControllerDelegate, CLLocationManagerDelegate>

@property (nonatomic, weak, readonly) UILabel *connectedPebbleLabel;
@property (nonatomic, weak, readonly) UIButton *connectToPebbleButton;
@property (nonatomic, weak, readonly) UITextField *messageTextField;
@property (nonatomic, weak, readonly) UIButton *sendToPebbleButton;
@property (nonatomic, weak, readonly) UILabel *currentLocationLabel;
@property (nonatomic, weak, readonly) UIButton *viewStationsButton;
@property (nonatomic, weak, readonly) UIActivityIndicatorView *activityIndicator;

@end
