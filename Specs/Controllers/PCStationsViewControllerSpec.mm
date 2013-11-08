#import "PCStationsViewController.h"
#import "UIAlertView+Spec.h"
#import "PCHomeViewController.h"
#import "PCStationList.h"
#import "PCStation.h"
#import "PebCiti.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface PCStationList (Specs)
@property (nonatomic, strong) NSArray *stations;
@end

SPEC_BEGIN(PCStationsViewControllerSpec)

describe(@"PCStationsViewController", ^{
    __block PCStationsViewController *controller;

    beforeEach(^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        controller = [storyboard instantiateViewControllerWithIdentifier:@"PCStationsView"];
    });

    describe(@"-viewWillAppear:", ^{
        beforeEach(^{
            [controller viewWillAppear:NO];
        });

        it(@"should be the station list's delegate", ^{
            PebCiti.sharedInstance.stationList.delegate should be_same_instance_as(controller);
        });
    });

    describe(@"-viewWillDisappear:", ^{
        beforeEach(^{
            PebCiti.sharedInstance.stationList.delegate = controller;

            [controller viewWillDisappear:NO];
        });

        it(@"should no longer be the station list's delegate", ^{
            PebCiti.sharedInstance.stationList.delegate should be_nil;
        });
    });

    describe(@"-tableView:numberOfRowsInSection:", ^{
        beforeEach(^{
            spy_on(PebCiti.sharedInstance.stationList);
            PebCiti.sharedInstance.stationList stub_method("count").and_return(2U);
        });

        it(@"should be the same as the station list count", ^{
            [controller tableView:nil numberOfRowsInSection:0] should equal(2);
        });
    });

    describe(@"-tableView:cellForRowAtIndexPath:", ^{
        __block UITableViewCell *cell1, *cell2, *cell3;

        beforeEach(^{
            PCStation *station1, *station2, *station3;
            station1 = [[PCStation alloc] initWithID:@1];
            station1.name = @"First and First";
            station1.docksAvailable = 1;
            station2 = [[PCStation alloc] initWithID:@2];
            station2.name = @"Second and Second";
            station2.docksAvailable = 2;
            station3 = [[PCStation alloc] initWithID:@3];
            station3.name = @"Third and Third";
            station3.docksAvailable = 3;

            PebCiti.sharedInstance.stationList.stations = @[ station1, station2, station3 ];

            cell1 = [controller tableView:nil cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            cell2 = [controller tableView:nil cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
            cell3 = [controller tableView:nil cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
        });

        it(@"should display each station's name", ^{
            cell1.textLabel.text should equal(@"First and First");
            cell2.textLabel.text should equal(@"Second and Second");
            cell3.textLabel.text should equal(@"Third and Third");
        });

        it(@"should display the number of docks available at each station", ^{
            cell1.detailTextLabel.text should equal(@"1");
            cell2.detailTextLabel.text should equal(@"2");
            cell3.detailTextLabel.text should equal(@"3");
        });
    });

    describe(@"<PCStationListDelegate>", ^{
        describe(@"-stationListWasUpdated:", ^{
            __block UITableView *fakeTableView;

            beforeEach(^{
                fakeTableView = nice_fake_for([UITableView class]);
                spy_on(controller);
                controller stub_method("tableView").and_return(fakeTableView);

                [controller stationListWasUpdated:nice_fake_for([PCStationList class])];
            });

            it(@"should tell the table to reload", ^{
                fakeTableView should have_received("reloadData");
            });
        });
    });
});

SPEC_END
