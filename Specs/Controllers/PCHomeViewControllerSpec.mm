#import "PCHomeViewController.h"
#import "PebCiti.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PCHomeViewControllerSpec)

describe(@"PCHomeViewController", ^{
    __block PCHomeViewController *controller;

    beforeEach(^{
        controller = [[[PCHomeViewController alloc] init] autorelease];
    });

    describe(@"-connectToPebbleButton", ^{
        it(@"should exist in the view hierarchy", ^{
            [controller.view subviews] should contain(controller.connectToPebbleButton);
        });

        describe(@"when the button is tapped", ^{
            beforeEach(^{
                spy_on(PebCiti.sharedInstance.pebbleManager);
                [controller.connectToPebbleButton sendActionsForControlEvents:UIControlEventTouchUpInside];
            });

            it(@"should tell the Pebble manager to send a message", ^{
                PebCiti.sharedInstance.pebbleManager should have_received("connectToPebble");
            });
        });
    });

    describe(@"-sendToPebbleButton", ^{
        it(@"should exist in the view hierarchy", ^{
            [controller.view subviews] should contain(controller.sendToPebbleButton);
        });

        describe(@"when the button is tapped", ^{
            beforeEach(^{
                spy_on(PebCiti.sharedInstance.pebbleManager);
                [controller.sendToPebbleButton sendActionsForControlEvents:UIControlEventTouchUpInside];
            });

            it(@"should tell the Pebble manager to send a message", ^{
                PebCiti.sharedInstance.pebbleManager should have_received("sendMessageToPebble");
            });
        });
    });
});

SPEC_END
