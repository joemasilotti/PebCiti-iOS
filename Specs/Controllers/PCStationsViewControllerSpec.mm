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
        controller.view should_not be_nil;
    });

    describe(@"-delegate", ^{
        it(@"should be the same as the one passed in", ^{
            controller.delegate should be_same_instance_as(delegate);
        });
    });

    describe(@"the 'Done' button", ^{
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

    describe(@"-title", ^{
        it(@"should have a title of 'Stations'", ^{
            controller.title should equal(@"Stations");
        });
    });
});

SPEC_END
