#import "PCPebbleManager.h"
#import <UIKit/UIKit.h>

@interface PCHomeViewController : UIViewController <PCPebbleManagerDelegate>

@property (nonatomic, weak, readonly) UILabel *connectedPebbleLabel;
@property (nonatomic, weak, readonly) UIButton *connectToPebbleButton;
@property (nonatomic, weak, readonly) UIButton *sendToPebbleButton;
@property (nonatomic, weak, readonly) UIActivityIndicatorView *activityIndicator;

@end
