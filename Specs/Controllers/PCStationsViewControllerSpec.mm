#import "PCStationsViewController.h"
#import "UIBarButtonItem+Spec.h"
#import "PCHomeViewController.h"
#import "UIAlertView+Spec.h"
#import "PCStationList.h"
#import "PCStation.h"
#import "PebCiti.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface PCStationsViewController (Specs)
@property (nonatomic, strong) NSArray *stations;
@property (nonatomic) BOOL showOpenDocks;
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
            spy_on(PebCiti.sharedInstance.stationList);
            PebCiti.sharedInstance.stationList stub_method(@selector(stations)).and_return(@[ ]);

            [controller viewWillAppear:NO];
        });

        it(@"should copy the stations array", ^{
            controller.stations should equal(PebCiti.sharedInstance.stationList.stations);
        });

        it(@"should show open docks", ^{
            controller.showOpenDocks should be_truthy;
        });
    });

    describe(@"-tableView:numberOfRowsInSection:", ^{
        beforeEach(^{
            controller.stations = @[ @"one", @"two" ];
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
            station1.bikesAvailable = 3;
            station2 = [[PCStation alloc] initWithID:@2];
            station2.name = @"Second and Second";
            station2.docksAvailable = 2;
            station2.bikesAvailable = 2;
            station3 = [[PCStation alloc] initWithID:@3];
            station3.name = @"Third and Third";
            station3.docksAvailable = 3;
            station3.bikesAvailable = 1;

            controller.stations = @[ station1, station2, station3 ];
        });

        subjectAction(^{
            cell1 = [controller tableView:nil cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            cell2 = [controller tableView:nil cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
            cell3 = [controller tableView:nil cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
        });

        it(@"should display each station's name", ^{
            cell1.textLabel.text should equal(@"First and First");
            cell2.textLabel.text should equal(@"Second and Second");
            cell3.textLabel.text should equal(@"Third and Third");
        });

        context(@"when displaying open docks", ^{
            beforeEach(^{
                controller.showOpenDocks = YES;
            });

            it(@"should display the number of open docks at each station", ^{
                cell1.detailTextLabel.text should equal(@"1");
                cell2.detailTextLabel.text should equal(@"2");
                cell3.detailTextLabel.text should equal(@"3");
            });
        });

        context(@"when displaying bikes", ^{
            beforeEach(^{
                controller.showOpenDocks = NO;
            });

            it(@"should display the number of available bikes at each station", ^{
                cell1.detailTextLabel.text should equal(@"3");
                cell2.detailTextLabel.text should equal(@"2");
                cell3.detailTextLabel.text should equal(@"1");
            });
        });
    });

    describe(@"sortButton", ^{
        beforeEach(^{
            [controller viewWillAppear:NO];
            spy_on(controller);
            controller stub_method(@selector(tableView)).and_return(nice_fake_for([UITableView class]));
        });

        it(@"should be titled 'Docks'", ^{
            controller.sortButton.title should equal(@"Docks");
        });

        describe(@"tapping it", ^{
            beforeEach(^{
                [controller.sortButton tap];
            });

            it(@"should be titled 'Bikes'", ^{
                controller.sortButton.title should equal(@"Bikes");
            });

            it(@"should no longer show open docks", ^{
                controller.showOpenDocks should_not be_truthy;
            });

            it(@"should tell the table view to reload", ^{
                controller.tableView should have_received(@selector(reloadData));
            });

            describe(@"tapping it again", ^{
                beforeEach(^{
                    [controller.sortButton tap];
                });

                it(@"should be titled 'Docks'", ^{
                    controller.sortButton.title should equal(@"Docks");
                });

                it(@"should show open docks", ^{
                    controller.showOpenDocks should be_truthy;
                });

                it(@"should tell the table view to reload", ^{
                    controller.tableView should have_received(@selector(reloadData));
                });
            });
        });
    });
});

SPEC_END
