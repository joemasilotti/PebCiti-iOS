#import <CoreLocation/CoreLocation.h>
#import "UIAlertView+Spec.h"
#import "PCStationList.h"
#import "PCStation.h"
#import "PebCiti.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface PCStationList (Spec)
@property (nonatomic, strong) NSArray *stations;
@end

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
                connection = [NSURLConnection.connections lastObject];
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
                        spy_on(stationList);
                        spy_on(PebCiti.sharedInstance.locationManager);
                        stationList.delegate = nice_fake_for(@protocol(PCStationListDelegate));
                    });

                    subjectAction(^{
                        PSHKFakeHTTPURLResponse *successResponse = [[PSHKFakeResponses responsesForRequest:@"/stations.json"] success];
                        [connection receiveResponse:successResponse];
                    });

                    it(@"should store the stations", ^{
                        stationList.count should equal(3);
                    });

                    context(@"when the user has reported a location", ^{
                        beforeEach(^{
                            CLLocation *userLocation = [[[CLLocation alloc] initWithLatitude:40.722543f longitude:-73.994379f] autorelease];
                            PebCiti.sharedInstance.locationManager stub_method(@selector(location)).and_return(userLocation);
                        });

                        it(@"should sort the station list by distance, closest first", ^{
                            stationList[0].stationID should equal(@79);
                            stationList[1].stationID should equal(@82);
                            stationList[2].stationID should equal(@72);

                            stationList[0].name should equal(@"Franklin St & W Broadway");
                            stationList[1].name should equal(@"St James Pl & Pearl St");
                            stationList[2].name should equal(@"W 52 St & 11 Ave");

                            stationList[0].docksAvailable should equal(7);
                            stationList[1].docksAvailable should equal(25);
                            stationList[2].docksAvailable should equal(37);

                            stationList[0].bikesAvailable should equal(26);
                            stationList[1].bikesAvailable should equal(1);
                            stationList[2].bikesAvailable should equal(2);

                            stationList[0].location.coordinate.latitude should equal(40.71911552f);
                            stationList[1].location.coordinate.latitude should equal(40.71117416f);
                            stationList[2].location.coordinate.latitude should equal(40.76727216f);

                            stationList[0].location.coordinate.longitude should equal(-74.00666661f);
                            stationList[1].location.coordinate.longitude should equal(-74.00016545f);
                            stationList[2].location.coordinate.longitude should equal(-73.99392888f);
                        });
                    });

                    context(@"when the user has not yet reported a location", ^{
                        beforeEach(^{
                            PebCiti.sharedInstance.locationManager stub_method(@selector(location));
                        });

                        it(@"should sort the station list by ID", ^{
                            stationList[0].stationID should equal(@72);
                            stationList[1].stationID should equal(@79);
                            stationList[2].stationID should equal(@82);

                            stationList[0].name should equal(@"W 52 St & 11 Ave");
                            stationList[1].name should equal(@"Franklin St & W Broadway");
                            stationList[2].name should equal(@"St James Pl & Pearl St");

                            stationList[0].docksAvailable should equal(37);
                            stationList[1].docksAvailable should equal(7);
                            stationList[2].docksAvailable should equal(25);

                            stationList[0].bikesAvailable should equal(2);
                            stationList[1].bikesAvailable should equal(26);
                            stationList[2].bikesAvailable should equal(1);

                            stationList[0].location.coordinate.latitude should equal(40.76727216f);
                            stationList[1].location.coordinate.latitude should equal(40.71911552f);
                            stationList[2].location.coordinate.latitude should equal(40.71117416f);

                            stationList[0].location.coordinate.longitude should equal(-73.99392888f);
                            stationList[1].location.coordinate.longitude should equal(-74.00666661f);
                            stationList[2].location.coordinate.longitude should equal(-74.00016545f);
                        });
                    });

                    it(@"should alert the delegate the stations have been updated", ^{
                        stationList.delegate should have_received("stationListWasUpdated:").with(stationList);
                    });

                    it(@"should update the stations after the specified delay", ^{
                        stationList should have_received(@selector(performSelector:withObject:afterDelay:)).with(@selector(requestStationList), nil, Arguments::anything);
                    });

                    describe(@"when that second network request returns successfully", ^{
                        context(@"with valid JSON", ^{
                            beforeEach(^{
                                [stationList requestStationList];
                                connection = [NSURLConnection.connections lastObject];
                                stationList.delegate = nice_fake_for(@protocol(PCStationListDelegate));
                                PSHKFakeHTTPURLResponse *successResponse = [[PSHKFakeResponses responsesForRequest:@"/stations_retry.json"] success];
                                [connection receiveResponse:successResponse];
                            });

                            it(@"should overwrite the stations with the new bike and dock counts", ^{
                                stationList.count should equal(3);

                                stationList[0].docksAvailable should equal(20);
                                stationList[1].docksAvailable should equal(8);
                                stationList[2].docksAvailable should equal(2);

                                stationList[0].bikesAvailable should equal(5);
                                stationList[1].bikesAvailable should equal(30);
                                stationList[2].bikesAvailable should equal(53);
                            });

                            it(@"should alert the delegate the stations have been updated", ^{
                                stationList.delegate should have_received("stationListWasUpdated:").with(stationList);
                            });

                            it(@"should update the stations after the specified delay", ^{
                                stationList should have_received(@selector(performSelector:withObject:afterDelay:)).with(@selector(requestStationList), nil, Arguments::anything);
                            });
                        });
                    });
                });

                context(@"when the response returns invalid JSON", ^{
                    beforeEach(^{
                        PSHKFakeHTTPURLResponse *successResponse = [[PSHKFakeResponses responsesForRequest:@"/stations_invalid.json"] success];
                        spy_on(stationList);
                        [connection receiveResponse:successResponse];
                    });

                    it(@"should display an alert view", ^{
                        UIAlertView.currentAlertView should_not be_nil;
                    });

                    it(@"should stop updating the stations", ^{
                        stationList should_not have_received(@selector(performSelector:withObject:afterDelay:));
                    });
                });
            });

            context(@"when the request encounters a network error", ^{
                beforeEach(^{
                    spy_on(stationList);
                    [stationList connection:connection didFailWithError:[NSError errorWithDomain:@"Network Error" code:3 userInfo:nil]];
                });

                it(@"should display an alert view", ^{
                    UIAlertView.currentAlertView should_not be_nil;
                });

                it(@"should stop updating the stations", ^{
                    stationList should_not have_received(@selector(performSelector:withObject:afterDelay:));
                });
            });

            context(@"when the request encounters a server error", ^{
                beforeEach(^{
                    spy_on(stationList);
                    PSHKFakeHTTPURLResponse *failureResponse = [PSHKFakeHTTPURLResponse responseFromFixtureNamed:@"/stations.json" statusCode:404];
                    [connection receiveResponse:failureResponse];
                });

                it(@"should display an alert view", ^{
                    UIAlertView.currentAlertView should_not be_nil;
                });

                it(@"should stop updating the stations", ^{
                    stationList should_not have_received(@selector(performSelector:withObject:afterDelay:));
                });
            });
        });
    });

    describe(@"closest stations", ^{
        __block PCStation *farStation, *closeStation, *closestStation, *farthestStation;

        beforeEach(^{
            spy_on(PebCiti.sharedInstance.locationManager);

            farStation = [[[PCStation alloc] initWithID:@1] autorelease];
            closeStation = [[[PCStation alloc] initWithID:@2] autorelease];
            closestStation = [[[PCStation alloc] initWithID:@3] autorelease];
            farthestStation = [[[PCStation alloc] initWithID:@4] autorelease];

            farStation.name = @"Far Station";
            closeStation.name = @"Close Station";
            closestStation.name = @"Closest Station";
            farthestStation.name = @"Farthest Station";

            farStation.location = [[[CLLocation alloc] initWithLatitude:40.717209f longitude:-73.997211f] autorelease];
            closeStation.location = [[[CLLocation alloc] initWithLatitude:40.720591f longitude:-73.995752f] autorelease];
            closestStation.location = [[[CLLocation alloc] initWithLatitude:40.722348f longitude:-73.992662f] autorelease];
            farthestStation.location = [[[CLLocation alloc] initWithLatitude:40.71272f longitude:-73.999014f] autorelease];

            stationList.stations = @[ farStation, closeStation, closestStation, farthestStation ];
        });

        describe(@"-closestStationWithAvailableBike", ^{
            beforeEach(^{
                farStation.bikesAvailable = 5;
                closeStation.bikesAvailable = 1;
                closestStation.bikesAvailable = 0;
                farthestStation.bikesAvailable = 5;
            });

            context(@"when the user has reported a location", ^{
                beforeEach(^{
                    CLLocation *userLocation = [[[CLLocation alloc] initWithLatitude:40.722543f longitude:-73.994379f] autorelease];
                    PebCiti.sharedInstance.locationManager stub_method("location").and_return(userLocation);
                });

                it(@"should return the closest station with at least one bike available", ^{
                    stationList.closestStationWithAvailableBike should equal(closeStation);
                });
            });

            context(@"when the user has not yet reported a location", ^{
                beforeEach(^{
                    PebCiti.sharedInstance.locationManager stub_method("location");
                });

                it(@"should return nil", ^{
                    stationList.closestStationWithAvailableBike should be_nil;
                });
            });
        });

        describe(@"-closestStationWithOpenDock", ^{
            beforeEach(^{
                farStation.docksAvailable = 5;
                closeStation.docksAvailable = 1;
                closestStation.docksAvailable = 0;
                farthestStation.docksAvailable = 5;
            });

            context(@"when the user has reported a location", ^{
                beforeEach(^{
                    CLLocation *userLocation = [[[CLLocation alloc] initWithLatitude:40.722543f longitude:-73.994379f] autorelease];
                    PebCiti.sharedInstance.locationManager stub_method("location").and_return(userLocation);
                });

                it(@"should return the closest station with at least one dock available", ^{
                    stationList.closestStationWithOpenDock should equal(closeStation);
                });
            });

            context(@"when the user has not yet reported a location", ^{
                beforeEach(^{
                    PebCiti.sharedInstance.locationManager stub_method("location");
                });

                it(@"should return nil", ^{
                    stationList.closestStationWithOpenDock should be_nil;
                });
            });
        });
    });
});

SPEC_END
