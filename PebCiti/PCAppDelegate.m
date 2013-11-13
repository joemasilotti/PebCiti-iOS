#import "PCAppDelegate.h"
#import "TestFlight.h"
#import "PebCiti.h"

@implementation PCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#ifndef DEBUG
    [TestFlight setDeviceIdentifier:[UIDevice.currentDevice.identifierForVendor UUIDString]];
    [TestFlight takeOff:@"8aaf96c4-077f-40ed-b336-10c1acadb047"];
#endif
    [PebCiti.sharedInstance setUpAppearance];
    return YES;
}

@end
