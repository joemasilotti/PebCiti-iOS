#import <Crashlytics/Crashlytics.h>
#import "PCAppDelegate.h"
#import "TestFlight.h"
#import "PebCiti.h"

@implementation PCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Crashlytics startWithAPIKey:@"d719996ce2f7809259d6b116a1e5b1cf5d0f316d"];
#ifndef DEBUG
    [TestFlight setDeviceIdentifier:[UIDevice.currentDevice.identifierForVendor UUIDString]];
    [TestFlight takeOff:@"8aaf96c4-077f-40ed-b336-10c1acadb047"];
#endif
    [PebCiti.sharedInstance setUpAppearance];
    return YES;
}

@end
