#import <Foundation/Foundation.h>

@class PCPebbleManager, CLLocationManager;

@interface PebCiti : NSObject

@property (nonatomic, strong, readonly) PCPebbleManager *pebbleManager;
@property (nonatomic, strong, readonly) CLLocationManager *locationManager;

+ (PebCiti *)sharedInstance;

@end
