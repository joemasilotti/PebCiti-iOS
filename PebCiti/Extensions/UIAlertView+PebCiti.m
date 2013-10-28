#import "UIAlertView+PebCiti.h"

@implementation UIAlertView (PebCiti)

+ (UIAlertView *)displayAlertViewWithTitle:(NSString *)title message:(NSString *)message
{
    return [UIAlertView displayAlertViewWithTitle:title message:message delegate:nil];
}

+ (UIAlertView *)displayAlertViewWithTitle:(NSString *)title message:(NSString *)message delegate:(id<UIAlertViewDelegate>)delegate
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:delegate
                                              cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [alertView show];
    return alertView;
}

@end
