#import "PCHomeViewController.h"
#import "PCPebbleManager.h"
#import "PebCiti.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PCHomeViewControllerSpec)

describe(@"PCHomeViewController", ^{
    __block PCHomeViewController *controller;

    describe(@"-title", ^{
        beforeEach(^{
            controller = [[[PCHomeViewController alloc] init] autorelease];
        });

        it(@"should be PebCiti", ^{
            controller.title should equal(@"PebCiti");
        });
    });

    describe(@"-connectedPebbleLabel", ^{
        __block PCPebbleManager *pebbleManager;

        beforeEach(^{
            spy_on(PebCiti.sharedInstance);
            pebbleManager = nice_fake_for([PCPebbleManager class]);
            PebCiti.sharedInstance stub_method("pebbleManager").and_return(pebbleManager);
        });

        it(@"should exist in the view heirarchy", ^{
            controller = [[[PCHomeViewController alloc] init] autorelease];
            controller.view.subviews should contain(controller.connectedPebbleLabel);
        });

        context(@"when a Pebble is connected", ^{
            beforeEach(^{
                PBWatch *watch = nice_fake_for([PBWatch class]);
                watch stub_method("name").and_return(@"PB12");
                pebbleManager stub_method("connectedWatch").and_return(watch);

                controller = [[[PCHomeViewController alloc] init] autorelease];
            });

            it(@"should be the name of the watch", ^{
                controller.connectedPebbleLabel.text should equal(@"PB12");
            });
        });

        context(@"when a Pebble is not connected", ^{
            beforeEach(^{
                pebbleManager.connectedWatch should be_nil;

                controller = [[[PCHomeViewController alloc] init] autorelease];
            });

            it(@"should be blank", ^{
                controller.connectedPebbleLabel.text should equal(@"");
            });
        });
    });

    describe(@"-connectToPebbleButton", ^{
        beforeEach(^{
            controller = [[[PCHomeViewController alloc] init] autorelease];
        });

        it(@"should exist in the view hierarchy", ^{
            controller.view.subviews should contain(controller.connectToPebbleButton);
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
        beforeEach(^{
            controller = [[[PCHomeViewController alloc] init] autorelease];
        });

        it(@"should exist in the view hierarchy", ^{
            controller.view.subviews should contain(controller.sendToPebbleButton);
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
