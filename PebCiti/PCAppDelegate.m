#import <Crashlytics/Crashlytics.h>
#import "PCAppDelegate.h"
#import "TestFlight.h"
#import "PebCiti.h"

@implementation PCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Crashlytics startWithAPIKey:@"73896b793d6e0ed4d486633b820e0ddffdc6625d"];
#ifndef DEBUG
    [TestFlight takeOff:@"8aaf96c4-077f-40ed-b336-10c1acadb047"];
#endif
    [PebCiti.sharedInstance setUpAppearance];
    return YES;
}

@end
