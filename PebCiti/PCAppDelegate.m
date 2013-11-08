#import "PCAppDelegate.h"
#import "PebCiti.h"

@implementation PCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [PebCiti.sharedInstance setUpAppearance];
    return YES;
}

@end
