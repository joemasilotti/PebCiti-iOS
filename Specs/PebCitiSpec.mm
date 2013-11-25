#import <CoreLocation/CoreLocation.h>
#import "PCPebbleManager.h"
#import "PCStationList.h"
#import "PCAnalytics.h"
#import "PebCiti.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PebCitiSpec)

describe(@"PebCiti", ^{
    __block PebCiti *pebCiti;

    beforeEach(^{
        pebCiti = PebCiti.sharedInstance;
    });

    it(@"should behave like a singleton", ^{
        pebCiti should be_same_instance_as(PebCiti.sharedInstance);
    });

    describe(@"-pebbleManager", ^{
        it(@"should be a PCPebbleManager", ^{
            pebCiti.pebbleManager should be_instance_of([PCPebbleManager class]);
        });

        it(@"should always return the same manager", ^{
            pebCiti.pebbleManager should be_same_instance_as(pebCiti.pebbleManager);
        });
    });

    describe(@"-locationManager", ^{
        it(@"should be a CLLocationManager", ^{
            pebCiti.locationManager should be_instance_of([CLLocationManager class]);
        });

        it(@"should always return the same manager", ^{
            pebCiti.locationManager should be_same_instance_as(pebCiti.locationManager);
        });
    });

    describe(@"-stations", ^{
        it(@"should be a PCStationList", ^{
            pebCiti.stationList should be_instance_of([PCStationList class]);
        });

        it(@"should always return the same list", ^{
            pebCiti.stationList should be_same_instance_as(pebCiti.stationList);
        });
    });

    describe(@"-analytics", ^{
        it(@"should be a PCAnalytics", ^{
            pebCiti.analytics should be_instance_of([PCAnalytics class]);
        });

        it(@"should always return the same list", ^{
            pebCiti.analytics should be_same_instance_as(pebCiti.analytics);
        });
    });
});

SPEC_END
