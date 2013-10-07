#import "PCHomeViewController.h"
#import "UIAlertView+Spec.h"
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
            spy_on(PebCiti.sharedInstance);
            PebCiti.sharedInstance stub_method("pebbleManager").and_return(nice_fake_for([PCPebbleManager class]));
        });

        it(@"should exist in the view hierarchy", ^{
            controller.view.subviews should contain(controller.connectToPebbleButton);
        });

        describe(@"when the button is tapped", ^{
            beforeEach(^{
                spy_on(PebCiti.sharedInstance.pebbleManager);
                controller.activityIndicator.isAnimating should_not be_truthy;

                [controller.connectToPebbleButton sendActionsForControlEvents:UIControlEventTouchUpInside];
            });

            it(@"should start spinning the activity indicator", ^{
                controller.activityIndicator.isAnimating should be_truthy;
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
                controller.activityIndicator.isAnimating should_not be_truthy;

                [controller.sendToPebbleButton sendActionsForControlEvents:UIControlEventTouchUpInside];
            });

            it(@"should start spinning the activity indicator", ^{
                controller.activityIndicator.isAnimating should be_truthy;
            });

            it(@"should tell the Pebble manager to send a message", ^{
                PebCiti.sharedInstance.pebbleManager should have_received("sendMessageToPebble");
            });
        });
    });

    describe(@"-activityIndicator", ^{
        beforeEach(^{
            controller = [[[PCHomeViewController alloc] init] autorelease];
        });

        it(@"should exist in the view hierarchy", ^{
            controller.view.subviews should contain(controller.activityIndicator);
        });

        it(@"should be hidden", ^{
            controller.activityIndicator.hidden should be_truthy;
        });

        it(@"should not be spinning", ^{
            controller.activityIndicator.isAnimating should_not be_truthy;
        });
    });

    describe(@"<PCPebbleManagerDelegate", ^{
        __block PBWatch *watch;

        beforeEach(^{
            watch = nice_fake_for([PBWatch class]);
            watch stub_method("name").and_return(@"PB12");
        });

        beforeEach(^{
            controller = [[[PCHomeViewController alloc] init] autorelease];
        });

        it(@"should be the default manager's delegate", ^{
            PebCiti.sharedInstance.pebbleManager.delegate should be_same_instance_as(controller);
        });

        describe(@"-pebbleManagerConnectedToWatch:", ^{
            beforeEach(^{
                [controller.activityIndicator startAnimating];
                controller.connectedPebbleLabel.text should equal(@"");

                [controller pebbleManagerConnectedToWatch:watch];
            });

            it(@"should clear the spinner", ^{
                controller.activityIndicator.isAnimating should_not be_truthy;
            });

            it(@"should update the connected Pebble label", ^{
                controller.connectedPebbleLabel.text should equal(@"PB12");
            });
        });

        describe(@"-pebbleManagerFailedToConnectToWatch:", ^{
            context(@"when the watch doesn't support app messages", ^{
                beforeEach(^{
                    [controller.activityIndicator startAnimating];
                    controller.activityIndicator.isAnimating should be_truthy;

                    [controller pebbleManagerFailedToConnectToWatch:watch];
                });

                it(@"should clear the spinner", ^{
                    controller.activityIndicator.isAnimating should_not be_truthy;
                });

                it(@"should display an alert view", ^{
                    UIAlertView.currentAlertView.message should equal(@"Pebble doesn't support app messages.");
                });
            });

            context(@"when the manager failed to connect to any watch", ^{
                beforeEach(^{
                    [controller.activityIndicator startAnimating];
                    controller.activityIndicator.isAnimating should be_truthy;

                    [controller pebbleManagerFailedToConnectToWatch:nil];
                });

                it(@"should clear the spinner", ^{
                    controller.activityIndicator.isAnimating should_not be_truthy;
                });

                it(@"should display an alert view", ^{
                    UIAlertView.currentAlertView.message should equal(@"No connected Pebble recognized.");
                });
            });
        });

        describe(@"-pebbleManagerSentMessageWithError:", ^{
            context(@"when the message was sent successfully", ^{
                beforeEach(^{
                    [controller.activityIndicator startAnimating];
                    controller.activityIndicator.isAnimating should be_truthy;

                    [controller pebbleManagerSentMessageWithError:nil];
                });

                it(@"should stop the spinner", ^{
                    controller.activityIndicator.isAnimating should_not be_truthy;
                });

                it(@"should show an alert view to the user noting the successful message send", ^{
                    UIAlertView.currentAlertView.message should equal(@"Message sent to Pebble successfully.");
                });
            });

            context(@"when the message sending reported an error", ^{
                beforeEach(^{
                    [controller.activityIndicator startAnimating];
                    controller.activityIndicator.isAnimating should be_truthy;
                    NSError *error = [NSError errorWithDomain:@"Pebble Error" code:1234 userInfo:@{ NSLocalizedDescriptionKey: @"Pebble had a problem." }];

                    [controller pebbleManagerSentMessageWithError:error];
                });

                it(@"should clear the spinner", ^{
                    controller.activityIndicator.isAnimating should_not be_truthy;
                });

                it(@"should show an alert view to the user with the error message", ^{
                    UIAlertView.currentAlertView.message should equal(@"Pebble had a problem.");
                });
            });
        });
    });
});

SPEC_END
