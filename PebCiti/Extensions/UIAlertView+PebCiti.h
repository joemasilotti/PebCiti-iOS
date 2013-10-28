#import <UIKit/UIKit.h>

@interface UIAlertView (PebCiti)

+ (UIAlertView *)displayAlertViewWithTitle:(NSString *)title message:(NSString *)message;
+ (UIAlertView *)displayAlertViewWithTitle:(NSString *)title message:(NSString *)message delegate:(id<UIAlertViewDelegate>)delegate;

@end
