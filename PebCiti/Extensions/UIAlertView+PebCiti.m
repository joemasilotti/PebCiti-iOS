#import "UIAlertView+PebCiti.h"

@implementation UIAlertView (PebCiti)

+ (UIAlertView *)displayAlertViewWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
    [alertView show];
    return alertView;
}

@end
