#import <CoreLocation/CoreLocation.h>
#import "UIAlertView+Spec.h"
#import "PCStationList.h"
#import "PCStation.h"
#import "PebCiti.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PCStationListSpec)

describe(@"PCStationList", ^{
    __block PCStationList *stationList;

    beforeEach(^{
        [PSHKFixtures setDirectory:@FIXTURESDIR];
        stationList = [[[PCStationList alloc] init] autorelease];
    });

    describe(@"on initialization", ^{
        it(@"should make a network request", ^{
            NSURLConnection.connections should_not be_empty;
        });

        describe(@"the network request", ^{
            __block NSURLConnection *connection;

            beforeEach(^{
                connection = NSURLConnection.connections[0];
            });

            it(@"should ask the CitiBikeNYC api for the list of stations", ^{
                connection.request.URL should equal([NSURL URLWithString:@"http://citibikenyc.com/stations/json"]);
            });

            it(@"should be the connection's delegate", ^{
                connection.delegate should be_same_instance_as(stationList);
            });

            context(@"when the network request returns successfully", ^{
                context(@"when the response is valid JSON", ^{
                    beforeEach(^{
                        stationList.delegate = nice_fake_for(@protocol(PCStationListDelegate));
                        PSHKFakeHTTPURLResponse *successResponse = [[PSHKFakeResponses responsesForRequest:@"/stations.json"] success];
                        [connection receiveResponse:successResponse];
                    });

                    it(@"should store the stations", ^{
                        stationList.count should equal(3);

                        stationList[0].name should equal(@"W 52 St & 11 Ave");
                        stationList[1].name should equal(@"Franklin St & W Broadway");
                        stationList[2].name should equal(@"St James Pl & Pearl St");

                        stationList[0].docksAvailable should equal(37);
                        stationList[1].docksAvailable should equal(7);
                        stationList[2].docksAvailable should equal(25);

                        stationList[0].location.coordinate.latitude should equal(40.76727216f);
                        stationList[1].location.coordinate.latitude should equal(40.71911552f);
                        stationList[2].location.coordinate.latitude should equal(40.71117416f);

                        stationList[0].location.coordinate.longitude should equal(-73.99392888f);
                        stationList[1].location.coordinate.longitude should equal(-74.00666661f);
                        stationList[2].location.coordinate.longitude should equal(-74.00016545f);
                    });

                    it(@"should alert the delegate the stations have been updated", ^{
                        stationList.delegate should have_received("stationListWasUpdated:").with(stationList);
                    });
                });

                context(@"when the response returns invalid JSON", ^{
                    beforeEach(^{
                        PSHKFakeHTTPURLResponse *successResponse = [[PSHKFakeResponses responsesForRequest:@"/stations_invalid.json"] success];
                        [connection receiveResponse:successResponse];
                    });

                    it(@"should display an alert view", ^{
                        UIAlertView.currentAlertView should_not be_nil;
                    });
                });
            });

            context(@"when the request encounters a network error", ^{
                beforeEach(^{
                    [stationList connection:connection didFailWithError:[NSError errorWithDomain:@"Network Error" code:3 userInfo:nil]];
                });

                it(@"should display an alert view", ^{
                    UIAlertView.currentAlertView should_not be_nil;
                });
            });

            context(@"when the request encounters a server error", ^{
                beforeEach(^{
                    PSHKFakeHTTPURLResponse *failureResponse = [PSHKFakeHTTPURLResponse responseFromFixtureNamed:@"/stations.json" statusCode:404];
                    [connection receiveResponse:failureResponse];
                });

                it(@"should display an alert view", ^{
                    UIAlertView.currentAlertView should_not be_nil;
                });
            });
        });
    });

    describe(@"-closestStation:", ^{
        beforeEach(^{
            spy_on(PebCiti.sharedInstance.locationManager);
            PSHKFakeHTTPURLResponse *successResponse = [[PSHKFakeResponses responsesForRequest:@"/stations.json"] success];
            [NSURLConnection.connections[0] receiveResponse:successResponse];
        });

        context(@"when the user has reported a location", ^{
            beforeEach(^{
                CLLocation *userLocation = [[[CLLocation alloc] initWithLatitude:40.71117415f longitude:-74.00016544f] autorelease];
                PebCiti.sharedInstance.locationManager stub_method("location").and_return(userLocation);
            });

            it(@"should return the station with the smallest distance to the user's location", ^{
                stationList.closestStation.name should equal(@"St James Pl & Pearl St");
            });
        });

        context(@"when the user has not yet reported a location", ^{
            beforeEach(^{
                PebCiti.sharedInstance.locationManager stub_method("location");
            });

            it(@"should return nil", ^{
                stationList.closestStation should be_nil;
            });
        });
    });
});

SPEC_END
