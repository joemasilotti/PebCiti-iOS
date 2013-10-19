#import <Foundation/Foundation.h>

@class PCPebbleManager, CLLocationManager, PCStationList;

@interface PebCiti : NSObject

@property (nonatomic, strong, readonly) PCPebbleManager *pebbleManager;
@property (nonatomic, strong, readonly) CLLocationManager *locationManager;
@property (nonatomic, strong, readonly) PCStationList *stationList;

+ (PebCiti *)sharedInstance;

@end
