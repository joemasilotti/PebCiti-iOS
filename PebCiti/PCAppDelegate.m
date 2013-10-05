#import "PCHomeViewController.h"
#import "PCAppDelegate.h"

@implementation PCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    PCHomeViewController *homeViewController = [[PCHomeViewController alloc] init];
    self.window.rootViewController = homeViewController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
