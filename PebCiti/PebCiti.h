#import <Foundation/Foundation.h>

@class PCPebbleManager, CLLocationManager, PCStationList, PCAnalytics;

@interface PebCiti : NSObject

@property (nonatomic, strong, readonly) PCPebbleManager *pebbleManager;
@property (nonatomic, strong, readonly) CLLocationManager *locationManager;
@property (nonatomic, strong, readonly) PCStationList *stationList;
@property (nonatomic, strong, readonly) PCAnalytics *analytics;

+ (PebCiti *)sharedInstance;
- (void)setUpAppearance;

@end
