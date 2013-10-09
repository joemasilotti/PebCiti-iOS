#import "PCHomeViewController.h"
#import "UIAlertView+Spec.h"
#import "PCPebbleCentral.h"
#import "PCPebbleManager.h"
#import "PebCiti.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PCHomeViewControllerSpec)

describe(@"PCHomeViewController", ^{
    __block PCHomeViewController *controller;

    describe(@"-viewDidAppear:", ^{
        __block PBWatch *watch;

        beforeEach(^{
            controller = [[[PCHomeViewController alloc] init] autorelease];
            watch = nice_fake_for([PBWatch class]);
            spy_on(PCPebbleCentral.defaultCentral);
        });

        context(@"when a Pebble is connected", ^{
            beforeEach(^{
                watch stub_method("isConnected").and_return(YES);
                watch stub_method("name").and_return(@"UI93");
                PCPebbleCentral.defaultCentral stub_method("lastConnectedWatch").and_return(watch);

                [controller viewDidAppear:NO];
            });

            it(@"should set the connected Pebble label to the Pebble's name", ^{
                controller.connectedPebbleLabel.text should equal(@"UI93");
            });
        });

        context(@"when a Pebble is not connected", ^{
            beforeEach(^{
                controller.connectedPebbleLabel.text = @"XA43";
                watch stub_method("isConnected").and_return(NO);
                PCPebbleCentral.defaultCentral stub_method("lastConnectedWatch").and_return(watch);

                [controller viewDidAppear:NO];
            });

            it(@"should set the connected Pebble label to blank", ^{
                controller.connectedPebbleLabel.text should equal(@"");
            });
        });

        context(@"when a Pebble was never connected", ^{
            beforeEach(^{
                controller.connectedPebbleLabel.text = @"XA43";

                [controller viewDidAppear:NO];
            });

            it(@"should set the connected Pebble label to blank", ^{
                controller.connectedPebbleLabel.text should equal(@"");
            });
        });
    });

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

        it(@"should exist in the view hierarchy", ^{
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

    describe(@"-messageTextField", ^{
        beforeEach(^{
            controller = [[[PCHomeViewController alloc] init] autorelease];
            controller.view should_not be_nil;
        });

        it(@"should exist in the view hierarchy", ^{
            controller.view.subviews should contain(controller.messageTextField);
        });

        it(@"should have a done button", ^{
            controller.messageTextField.returnKeyType should equal(UIReturnKeyDone);
        });

        it(@"should have it's delegate be the controller", ^{
            controller.messageTextField.delegate should be_same_instance_as(controller);
        });

        it(@"should initialize with an empty string", ^{
            controller.messageTextField.text should equal(@"");
        });
    });

    describe(@"<UITextFieldDelegate>", ^{
        beforeEach(^{
            controller = [[[PCHomeViewController alloc] init] autorelease];
        });

        it(@"should return NO", ^{
            [controller textFieldShouldReturn:controller.messageTextField] should_not be_truthy;
        });

        it(@"should tell the text field to resign as first responder", ^{
            spy_on(controller.messageTextField);
            [controller textFieldShouldReturn:controller.messageTextField];
            controller.messageTextField should have_received("resignFirstResponder");
        });
    });

    describe(@"-sendToPebbleButton", ^{
        beforeEach(^{
            controller = [[[PCHomeViewController alloc] init] autorelease];
            spy_on(PebCiti.sharedInstance);
            PebCiti.sharedInstance stub_method("pebbleManager").and_return(nice_fake_for([PCPebbleManager class]));
        });

        it(@"should exist in the view hierarchy", ^{
            controller.view.subviews should contain(controller.sendToPebbleButton);
        });

        describe(@"when the button is tapped", ^{
            beforeEach(^{
                spy_on(PebCiti.sharedInstance.pebbleManager);
                controller.activityIndicator.isAnimating should_not be_truthy;
                controller.messageTextField.text = @"TEXT";

                [controller.sendToPebbleButton sendActionsForControlEvents:UIControlEventTouchUpInside];
            });

            it(@"should start spinning the activity indicator", ^{
                controller.activityIndicator.isAnimating should be_truthy;
            });

            it(@"should tell the Pebble manager to send the text from the input field", ^{
                PebCiti.sharedInstance.pebbleManager should have_received("sendMessageToPebble:").with(@"TEXT");
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
                    controller.connectedPebbleLabel.text = @"AB98";
                    [controller.activityIndicator startAnimating];
                    controller.activityIndicator.isAnimating should be_truthy;

                    [controller pebbleManagerFailedToConnectToWatch:watch];
                });

                it(@"should clear the spinner", ^{
                    controller.activityIndicator.isAnimating should_not be_truthy;
                });

                it(@"should set the connected Pebble label to be blank", ^{
                    controller.connectedPebbleLabel.text should equal(@"");
                });

                it(@"should display an alert view", ^{
                    UIAlertView.currentAlertView.message should equal(@"Pebble doesn't support app messages.");
                });
            });

            context(@"when the manager failed to connect to any watch", ^{
                beforeEach(^{
                    controller.connectedPebbleLabel.text = @"AB98";
                    [controller.activityIndicator startAnimating];
                    controller.activityIndicator.isAnimating should be_truthy;

                    [controller pebbleManagerFailedToConnectToWatch:nil];
                });

                it(@"should clear the spinner", ^{
                    controller.activityIndicator.isAnimating should_not be_truthy;
                });

                it(@"should set the connected Pebble label to be blank", ^{
                    controller.connectedPebbleLabel.text should equal(@"");
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
