#import "PCStationsViewController.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PCStationsViewControllerSpec)

describe(@"PCStationsViewController", ^{
    __block PCStationsViewController *controller;
    __block id<PCStationsViewControllerDelegate> delegate;

    beforeEach(^{
        delegate = nice_fake_for(@protocol(PCStationsViewControllerDelegate));
        controller = [[[PCStationsViewController alloc] initWithDelegate:delegate] autorelease];
    });

    describe(@"-delegate", ^{
        it(@"should be the same as the one passed in", ^{
            controller.delegate should be_same_instance_as(delegate);
        });
    });

    describe(@"the 'Done' button", ^{
        beforeEach(^{
            controller.view should_not be_nil;
        });

        it(@"should be the left nav bar button item", ^{
            controller.navigationItem.leftBarButtonItem should be_instance_of([UIBarButtonItem class]);
        });

        describe(@"tapping the button", ^{
            beforeEach(^{
                [controller.navigationItem.leftBarButtonItem.target performSelector:controller.navigationItem.leftBarButtonItem.action];
            });

            it(@"should tell the delegate the button was tapped", ^{
                controller.delegate should have_received("stationsViewControllerIsDone");
            });
        });
    });

    describe(@"loading the view", ^{
        beforeEach(^{
            controller.view should_not be_nil;
        });

        it(@"should have a title of 'Stations'", ^{
            controller.title should equal(@"Stations");
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

            it(@"should delegate to the stations controller", ^{
                connection.delegate should be_same_instance_as(controller);
            });

            context(@"when the network request returns successfully", ^{
                beforeEach(^{
                    PSHKFakeHTTPURLResponse *successResponse = [[PSHKFakeResponses responsesForRequest:@"/stations.json"] success];
                    [connection receiveResponse:successResponse];
                });

                it(@"should set the table cell's to the station's names", ^{
                    UITableViewCell *cell = controller.tableView.visibleCells[0];
                    cell.textLabel.text should equal(@"W 52 St & 11 Ave");

                    cell = controller.tableView.visibleCells[1];
                    cell.textLabel.text should equal(@"Franklin St & W Broadway");

                    cell = controller.tableView.visibleCells[2];
                    cell.textLabel.text should equal(@"St James Pl & Pearl St");
                });

                it(@"should set the table cell's detail text to the number of docks available", ^{
                    UITableViewCell *cell = controller.tableView.visibleCells[0];
                    cell.detailTextLabel.text should equal(@"37");

                    cell = controller.tableView.visibleCells[1];
                    cell.detailTextLabel.text should equal(@"7");

                    cell = controller.tableView.visibleCells[2];
                    cell.detailTextLabel.text should equal(@"25");
                });
            });
        });
    });
});

SPEC_END
