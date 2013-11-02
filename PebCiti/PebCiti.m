#import <CoreLocation/CoreLocation.h>
#import "PCPebbleManager.h"
#import "PCStationList.h"
#import "PebCiti.h"

@interface PebCiti ()
@property (nonatomic, strong, readwrite) PCPebbleManager *pebbleManager;
@property (nonatomic, strong, readwrite) CLLocationManager *locationManager;
@property (nonatomic, strong, readwrite) PCStationList *stationList;
@end

static PebCiti *_sharedPebCiti;

@implementation PebCiti

+ (PebCiti *)sharedInstance
{
    if (!_sharedPebCiti) {
        _sharedPebCiti = [[PebCiti alloc] init];
    }
    return _sharedPebCiti;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.pebbleManager = [[PCPebbleManager alloc] init];
        self.locationManager = [[CLLocationManager alloc] init];
        self.stationList = [[PCStationList alloc] init];
    }
    return  self;
}

- (void)setUpAppearance
{
    NSDictionary *customFont = @{ NSFontAttributeName: [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:20.0] };
    [[UINavigationBar appearance] setTitleTextAttributes:customFont];

    [[UINavigationBar appearance] setTintColor:[self tintColor]];
    [[UIButton appearance] setTintColor:[self tintColor]];
    [[UISegmentedControl appearance] setTintColor:[self tintColor]];
}

#pragma mark - Private

- (UIColor *)tintColor
{
    return [UIColor colorWithRed:173.0f/255.0f green:53.0f/255.0f blue:52.0f/255.0f alpha:1.0f];
}

@end
