#import "UIAlertView+Spec.h"
#import "PCStationList.h"
#import "PCStation.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PCStationListSpec)

describe(@"PCStationList", ^{
    __block PCStationList *stationList;

    beforeEach(^{
        stationList = [[[PCStationList alloc] init] autorelease];
    });

    it(@"should make a network request", ^{
        NSURLConnection.connections should_not be_empty;
    });

    describe(@"the network request", ^{
        __block NSURLConnection *connection;

        beforeEach(^{
            [PSHKFixtures setDirectory:@FIXTURESDIR];
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

SPEC_END
