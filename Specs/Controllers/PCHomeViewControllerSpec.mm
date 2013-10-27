#import "PCStationsViewController.h"
#import "PCHomeViewController.h"
#import "UIAlertView+Spec.h"
#import "PCPebbleCentral.h"
#import "PCPebbleManager.h"
#import "UIControl+Spec.h"
#import "PCStation.h"
#import "PebCiti.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PCHomeViewControllerSpec)

describe(@"PCHomeViewController", ^{
    __block PCHomeViewController *controller;

    beforeEach(^{
        controller = [[[PCHomeViewController alloc] init] autorelease];
    });

    it(@"should be the Pebble manager's delegate", ^{
        PebCiti.sharedInstance.pebbleManager.delegate should be_same_instance_as(controller);
    });

    it(@"should be the location manager's delegate", ^{
        PebCiti.sharedInstance.locationManager.delegate should be_same_instance_as(controller);
    });

    describe(@"-title", ^{
        it(@"should be PebCiti", ^{
            controller.title should equal(@"PebCiti");
        });
    });

    describe(@"when the view appears", ^{
        beforeEach(^{
            spy_on(PebCiti.sharedInstance.locationManager);
            [controller viewDidAppear:NO];
        });

        it(@"should tell the location manager to start updating the user's location", ^{
            PebCiti.sharedInstance.locationManager should have_received("startUpdatingLocation");
        });
    });

    describe(@"-sendMessagesSwitch", ^{
        __block PCPebbleManager *pebbleManager;

        beforeEach(^{
            pebbleManager = nice_fake_for([PCPebbleManager class]);
            spy_on(PebCiti.sharedInstance);
            PebCiti.sharedInstance stub_method(@selector(pebbleManager)).and_return(pebbleManager);
        });

        context(@"when the Pebble manager is not sending messages", ^{
            beforeEach(^{
                pebbleManager stub_method(@selector(isSendingMessagesToPebble)).and_return(NO);
                controller.view should_not be_nil;
            });

            it(@"should be off", ^{
                controller.sendMessagesSwitch.isOn should_not be_truthy;
            });

            describe(@"turning the switch on", ^{
                beforeEach(^{
                    controller.sendMessagesSwitch.on = YES;
                    controller.vibratePebbleLabel.enabled = YES;
                    controller.vibratePebbleSwitch.enabled = YES;
                    controller.vibratePebbleSwitch.on = YES;
                    [controller sendMessagesSwitchWasToggled:controller.sendMessagesSwitch];
                });

                it(@"should display a spinner", ^{
                    controller.activityIndicator.isAnimating should be_truthy;
                });

                it(@"should tell the Pebble manager to start sending updates to the connected Pebble", ^{
                    pebbleManager should have_received(@selector(setSendMessagesToPebble:)).with(YES);
                });

                it(@"should not change the vibrate label or switch", ^{
                    controller.vibratePebbleLabel.isEnabled should be_truthy;
                    controller.vibratePebbleSwitch.isEnabled should be_truthy;
                    controller.vibratePebbleSwitch.isOn should be_truthy;
                });

                it(@"should not change any vibrate settings", ^{
                    pebbleManager should_not have_received(@selector(setVibratePebble:));
                });

                describe(@"when a Pebble connects successfully", ^{
                    beforeEach(^{
                        [controller pebbleManagerConnectedToWatch:pebbleManager];
                    });

                    it(@"should hide the spinner", ^{
                        controller.activityIndicator.isAnimating should_not be_truthy;
                    });

                    it(@"should not display an alert view", ^{
                        UIAlertView.currentAlertView should be_nil;
                    });
                });

                describe(@"when no Pebble successfully connects", ^{
                    beforeEach(^{
                        spy_on(controller.sendMessagesSwitch);
                        [controller pebbleManagerFailedToConnectToWatch:nice_fake_for([PCPebbleManager class])];
                    });

                    it(@"should set the switch back to off", ^{
                        controller.sendMessagesSwitch should have_received(@selector(setOn:animated:)).with(NO, YES);
                    });

                    it(@"should hide the spinner", ^{
                        controller.activityIndicator.isAnimating should_not be_truthy;
                    });

                    it(@"should display an error alert view", ^{
                        UIAlertView.currentAlertView should_not be_nil;
                    });
                });
            });

            describe(@"when the Pebble disconnects", ^{
                beforeEach(^{
                    spy_on(controller.sendMessagesSwitch);
                    [controller pebbleManagerDisconnectedFromWatch:nice_fake_for([PCPebbleManager class])];
                });

                it(@"should not display an alert view", ^{
                    UIAlertView.currentAlertView should be_nil;
                });

                it(@"should not tell the switch to do anything else", ^{
                    controller.sendMessagesSwitch should_not have_received(@selector(setOn:animated:));
                });
            });
        });

        context(@"when the Pebble manager is sending messages", ^{
            beforeEach(^{
                pebbleManager stub_method(@selector(isSendingMessagesToPebble)).and_return(YES);
                controller.view should_not be_nil;
            });

            it(@"should be on", ^{
                controller.sendMessagesSwitch.isOn should be_truthy;
            });

            describe(@"turning the switch off", ^{
                beforeEach(^{
                    controller.sendMessagesSwitch.on = NO;
                    controller.vibratePebbleLabel.enabled = YES;
                    controller.vibratePebbleSwitch.enabled = YES;
                    controller.vibratePebbleSwitch.on = YES;
                    spy_on(controller.sendMessagesSwitch);
                    [controller sendMessagesSwitchWasToggled:controller.sendMessagesSwitch];
                });

                it(@"should tell the Pebble manager to start stop updates to the connected Pebble", ^{
                    pebbleManager should have_received(@selector(setSendMessagesToPebble:)).with(NO);
                });

                it(@"should not display a spinner", ^{
                    controller.activityIndicator.isAnimating should_not be_truthy;
                });

                it(@"should not display an alert view", ^{
                    UIAlertView.currentAlertView should be_nil;
                });

                it(@"should not tell the switch to do anything else", ^{
                    controller.sendMessagesSwitch should_not have_received(@selector(setOn:animated:));
                });

                it(@"should disable the vibrate label", ^{
                    controller.vibratePebbleLabel.isEnabled should_not be_truthy;
                });

                it(@"should turn off the vibrate switch", ^{
                    controller.vibratePebbleSwitch.isOn should_not be_truthy;
                });

                it(@"should disable the vibrate switch", ^{
                    controller.vibratePebbleSwitch.isEnabled should_not be_truthy;
                });

                it(@"should tell the Pebble manager to stop vibrating the Pebble", ^{
                    pebbleManager should have_received(@selector(setVibratePebble:)).with(NO);
                });
            });

            describe(@"when the Pebble disconnects", ^{
                beforeEach(^{
                    spy_on(controller.sendMessagesSwitch);
                    [controller pebbleManagerDisconnectedFromWatch:nice_fake_for([PCPebbleManager class])];
                });

                it(@"should display an alert view", ^{
                    UIAlertView.currentAlertView should_not be_nil;
                });

                it(@"should set the switch to off", ^{
                    controller.sendMessagesSwitch should have_received(@selector(setOn:animated:)).with(NO, YES);
                });
            });
        });
    });

    describe(@"-vibratePebbleSwitch", ^{
        beforeEach(^{
            spy_on(PebCiti.sharedInstance);
            PebCiti.sharedInstance stub_method(@selector(pebbleManager)).and_return(nice_fake_for([PCPebbleManager class]));
        });

        context(@"when the Pebble manager is sending messages", ^{
            beforeEach(^{
                PebCiti.sharedInstance.pebbleManager stub_method(@selector(isSendingMessagesToPebble)).and_return(YES);
            });

            context(@"when the Pebble manager is vibrating the Pebble", ^{
                beforeEach(^{
                    PebCiti.sharedInstance.pebbleManager stub_method(@selector(isVibratingPebble)).and_return(YES);
                    controller.view should_not be_nil;
                });

                it(@"should be enabled", ^{
                    controller.vibratePebbleSwitch.isEnabled should be_truthy;
                });

                it(@"should be on", ^{
                    controller.vibratePebbleSwitch.isOn should be_truthy;
                });

                it(@"the label should be enabled", ^{
                    controller.vibratePebbleLabel.isEnabled should be_truthy;
                });

                describe(@"turning the switch off", ^{
                    beforeEach(^{
                        controller.vibratePebbleSwitch.on = NO;
                        [controller vibratePebbleSwitchWasToggled:controller.vibratePebbleSwitch];
                    });

                    it(@"should tell the Pebble manager to stop vibrating the Pebble", ^{
                        PebCiti.sharedInstance.pebbleManager should have_received(@selector(setVibratePebble:)).with(NO);
                    });
                });
            });

            context(@"when the Pebble manager is not vibrating the Pebble", ^{
                beforeEach(^{
                    PebCiti.sharedInstance.pebbleManager stub_method(@selector(isVibratingPebble)).and_return(NO);
                    controller.view should_not be_nil;
                });

                it(@"should be enabled", ^{
                    controller.vibratePebbleSwitch.isEnabled should be_truthy;
                });

                it(@"should be off", ^{
                    controller.vibratePebbleSwitch.isOn should_not be_truthy;
                });

                it(@"the label should still be enabled", ^{
                    controller.vibratePebbleLabel.isEnabled should be_truthy;
                });

                describe(@"turning the switch on", ^{
                    beforeEach(^{
                        controller.vibratePebbleSwitch.on = YES;
                        [controller vibratePebbleSwitchWasToggled:controller.vibratePebbleSwitch];
                    });

                    it(@"should tell the Pebble manager to start vibrating the Pebble", ^{
                        PebCiti.sharedInstance.pebbleManager should have_received(@selector(setVibratePebble:)).with(YES);
                    });
                });
            });
        });

        context(@"when the Pebble manager is not sending messages", ^{
            beforeEach(^{
                PebCiti.sharedInstance.pebbleManager stub_method(@selector(isSendingMessagesToPebble)).and_return(NO);
                controller.view should_not be_nil;
            });

            it(@"should be disabled", ^{
                controller.vibratePebbleSwitch.isEnabled should_not be_truthy;
            });

            it(@"should be off", ^{
                controller.vibratePebbleSwitch.isOn should_not be_truthy;
            });

            it(@"the label should be disabled", ^{
                controller.vibratePebbleLabel.isEnabled should_not be_truthy;
            });
        });

        describe(@"interacting with the Pebble", ^{
            beforeEach(^{
                controller.view should_not be_nil;
            });

            describe(@"when a Pebble connects", ^{
                beforeEach(^{
                    controller.vibratePebbleLabel.enabled = NO;
                    controller.vibratePebbleSwitch.enabled = NO;
                    [controller pebbleManagerConnectedToWatch:nice_fake_for([PCPebbleManager class])];
                });

                it(@"should enable the vibrate switch", ^{
                    controller.vibratePebbleSwitch.isEnabled should be_truthy;
                });

                it(@"should enable the vibrate label", ^{
                    controller.vibratePebbleLabel.isEnabled should be_truthy;
                });
            });

            describe(@"when a Pebble disconnects", ^{
                beforeEach(^{
                    controller.vibratePebbleLabel.enabled = YES;
                    controller.vibratePebbleSwitch.enabled = YES;
                    controller.vibratePebbleSwitch.on = YES;
                    [controller pebbleManagerDisconnectedFromWatch:nice_fake_for([PCPebbleManager class])];
                });

                it(@"should disable the vibrate switch", ^{
                    controller.vibratePebbleSwitch.isEnabled should_not be_truthy;
                });

                it(@"should turn the vibrate switch off", ^{
                    controller.vibratePebbleSwitch.isOn should_not be_truthy;
                });

                it(@"should disable the vibrate label", ^{
                    controller.vibratePebbleLabel.isEnabled should_not be_truthy;
                });
            });

            describe(@"when sending a message to the Pebble fails", ^{
                beforeEach(^{
                    controller.vibratePebbleLabel.enabled = YES;
                    controller.vibratePebbleSwitch.enabled = YES;
                    controller.vibratePebbleSwitch.on = YES;
                    [controller pebbleManager:nice_fake_for([PCPebbleManager class]) receivedError:nice_fake_for([NSError class])];
                });

                it(@"should disable the vibrate switch", ^{
                    controller.vibratePebbleSwitch.isEnabled should_not be_truthy;
                });

                it(@"should turn the vibrate switch off", ^{
                    controller.vibratePebbleSwitch.isOn should_not be_truthy;
                });

                it(@"should disable the vibrate label", ^{
                    controller.vibratePebbleLabel.isEnabled should_not be_truthy;
                });
            });
        });
    });

    describe(@"-currentLocationLabel", ^{
        beforeEach(^{
            controller.view should_not be_nil;
        });

        it(@"should display an empty string", ^{
            controller.currentLocationLabel.text should equal(@"");
        });

        describe(@"on a location update", ^{
            __block CLLocation *firstLocation, *secondLocation;

            beforeEach(^{
                firstLocation = [[[CLLocation alloc] initWithLatitude:-24.023 longitude:64.435] autorelease];
                secondLocation = [[[CLLocation alloc] initWithLatitude:-24.026 longitude:64.445] autorelease];

                CLLocationManager *locationManager = nice_fake_for([CLLocationManager class]);
                [controller locationManager:locationManager didUpdateLocations:@[ firstLocation, secondLocation ]];
            });

            it(@"should update to the most recent location lat and long", ^{
                controller.currentLocationLabel.text should equal(@"-24.026000, 64.445000");
            });
        });
    });

    describe(@"-closestStationLabel", ^{
        __block PCStationList *stationList;

        beforeEach(^{
            stationList = nice_fake_for([PCStationList class]);
            spy_on(PebCiti.sharedInstance);
            PebCiti.sharedInstance stub_method(@selector(stationList)).and_return(stationList);
            controller.view should_not be_nil;
        });

        it(@"should display an empty string", ^{
            controller.closestStationLabel.text should equal(@"");
        });

        describe(@"on a location update", ^{
            beforeEach(^{
                PCStation *closestStation = nice_fake_for([PCStation class]);
                closestStation stub_method(@selector(name)).and_return(@"1st Ave & 2nd St.");
                stationList stub_method("closestStation").and_return(closestStation);

                CLLocationManager *locationManager = nice_fake_for([CLLocationManager class]);
                CLLocation *location = nice_fake_for([CLLocation class]);
                [controller locationManager:locationManager didUpdateLocations:@[ location ]];
            });

            it(@"should update to the closest station's name", ^{
                controller.closestStationLabel.text should equal(@"1st Ave & 2nd St.");
            });
        });
    });

    describe(@"-viewStationsButton", ^{
        beforeEach(^{
            controller.view should_not be_nil;
        });

        describe(@"tapping the button", ^{
            beforeEach(^{
                [controller.viewStationsButton tap];
            });

            it(@"should display a UINavigationController", ^{
                controller.presentedViewController should be_instance_of([UINavigationController class]);
            });

            it(@"should have the root of the nav controller be a PCStationsViewController", ^{
                [(UINavigationController *)controller.presentedViewController topViewController] should be_instance_of([PCStationsViewController class]);
            });

            it(@"should be the stationsVC's delegate", ^{
                [(PCStationsViewController *)[(UINavigationController *)controller.presentedViewController topViewController] delegate] should be_same_instance_as(controller);
            });

            describe(@"when the stations view is dismissed", ^{
                beforeEach(^{
                    [controller stationsViewControllerIsDone];
                });

                it(@"should dismiss the presented view controller", ^{
                    controller.presentedViewController should be_nil;
                });
            });
        });
    });

    describe(@"-activityIndicator", ^{
        beforeEach(^{
            controller.view should_not be_nil;
        });

        describe(@"when the view appears", ^{
            beforeEach(^{
                [controller viewDidAppear:NO];
            });

            it(@"should be hidden", ^{
                controller.activityIndicator.isHidden should be_truthy;
            });

            it(@"should not be spinning", ^{
                controller.activityIndicator.isAnimating should_not be_truthy;
            });

            it(@"should fill the screen", ^{
                CGRectEqualToRect(controller.activityIndicator.frame, controller.view.frame) should be_truthy;
            });
        });
    });

    describe(@"sending messages to the Pebble", ^{
        beforeEach(^{
            spy_on(PebCiti.sharedInstance.pebbleManager);
        });

        context(@"when the Pebble manager should be updating the Pebble", ^{
            beforeEach(^{
                PebCiti.sharedInstance.pebbleManager stub_method(@selector(isSendingMessagesToPebble)).and_return(YES);
            });

            describe(@"when a location update occurs", ^{
                beforeEach(^{
                    PCStation *station = nice_fake_for([PCStation class]);
                    station stub_method(@selector(name)).and_return(@"Station Name");

                    spy_on(PebCiti.sharedInstance.stationList);
                    PebCiti.sharedInstance.stationList stub_method(@selector(closestStation)).and_return(station);

                    CLLocationManager *locationManager = nice_fake_for([CLLocationManager class]);
                    CLLocation *location = nice_fake_for([CLLocation class]);
                    [controller locationManager:locationManager didUpdateLocations:@[ location ]];
                });

                it(@"should send the closest station name to the Pebble", ^{
                    PebCiti.sharedInstance.pebbleManager should have_received(@selector(sendMessageToPebble:)).with(@"Station Name");
                });

                describe(@"when an error occurs sending the message", ^{
                    __block NSError *error;

                    beforeEach(^{
                        controller.view should_not be_nil;
                        spy_on(controller.sendMessagesSwitch);

                        error = [NSError errorWithDomain:@"Domain" code:123 userInfo:@{ NSLocalizedDescriptionKey: @"Some message." }];
                        [controller pebbleManager:nice_fake_for([PCPebbleManager class]) receivedError:error];
                    });

                    it(@"should display an alert with the error message", ^{
                        UIAlertView.currentAlertView.message should equal(error.localizedDescription);
                    });

                    it(@"should turn the switch off", ^{
                        controller.sendMessagesSwitch should have_received(@selector(setOn:animated:)).with(NO, YES);
                    });

                    describe(@"when anothe error occurs before the first is dismissed", ^{
                        __block NSError *newError;

                        beforeEach(^{
                            newError = [NSError errorWithDomain:@"Domain" code:123 userInfo:@{ NSLocalizedDescriptionKey: @"New error message." }];
                            [controller pebbleManager:nice_fake_for([PCPebbleManager class]) receivedError:newError];
                        });

                        it(@"should not show another alert", ^{
                            UIAlertView.currentAlertView.message should equal(error.localizedDescription);
                        });
                    });
                });
            });
        });

        context(@"when the Pebble manager should not be updating the Pebble", ^{
            beforeEach(^{
                PebCiti.sharedInstance.pebbleManager stub_method(@selector(isSendingMessagesToPebble)).and_return(NO);
            });

            describe(@"when a location update occurs", ^{
                beforeEach(^{
                    CLLocationManager *locationManager = nice_fake_for([CLLocationManager class]);
                    CLLocation *location = nice_fake_for([CLLocation class]);
                    [controller locationManager:locationManager didUpdateLocations:@[ location ]];
                });

                it(@"should not send any messages to the Pebble", ^{
                    PebCiti.sharedInstance.pebbleManager should_not have_received(@selector(sendMessageToPebble:));
                });
            });
        });
    });
});

SPEC_END
