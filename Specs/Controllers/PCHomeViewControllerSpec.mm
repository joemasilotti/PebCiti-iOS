#import "PCStationsViewController.h"
#import "PCHomeViewController.h"
#import "UIAlertView+Spec.h"
#import "PCPebbleCentral.h"
#import "PCPebbleManager.h"
#import "UIControl+Spec.h"
#import "PCAnalytics.h"
#import "PCStation.h"
#import "PebCiti.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PCHomeViewControllerSpec)

describe(@"PCHomeViewController", ^{
    __block PCHomeViewController *controller;

    beforeEach(^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        controller = [storyboard instantiateViewControllerWithIdentifier:@"PCHomeView"];
        [[[UINavigationController alloc] initWithRootViewController:controller] autorelease];
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

    describe(@"when the view is about to appear", ^{
        beforeEach(^{
            spy_on(PebCiti.sharedInstance.analytics);
            [controller viewWillAppear:NO];
        });

        it(@"should tell the analytics to track the 'Home Screen'", ^{
            PebCiti.sharedInstance.analytics should have_received(@selector(setActiveScreenName:)).with(@"Home Screen");
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

    describe(@"focusSegmentControl", ^{
        beforeEach(^{
            controller.view should_not be_nil;
        });

        context(@"when the focus type is the closest bike", ^{
            beforeEach(^{
                controller.focusType should equal(PCFocusTypeBike);
            });

            it(@"should be 'Bike'", ^{
                controller.focusSegmentControl.selectedSegmentIndex = 0;
            });

            describe(@"changing it to 'Dock'", ^{
                beforeEach(^{
                    spy_on(PebCiti.sharedInstance.pebbleManager);
                    [controller.focusSegmentControl setSelectedSegmentIndex:1];
                    [controller.focusSegmentControl sendActionsForControlEvents:UIControlEventValueChanged];
                });

                it(@"should change the property to 'Dock'", ^{
                    controller.focusType should equal(PCFocusTypeDock);
                });

                it(@"should tell the Pebble that is is focusing on open docks", ^{
                    PebCiti.sharedInstance.pebbleManager should have_received(@selector(setFocusIsBike:)).with(NO);
                });

                describe(@"changing it back to 'Bike'", ^{
                    beforeEach(^{
                        [controller.focusSegmentControl setSelectedSegmentIndex:0];
                        [controller.focusSegmentControl sendActionsForControlEvents:UIControlEventValueChanged];
                    });

                    it(@"should change the property to 'Bike'", ^{
                        controller.focusType should equal(PCFocusTypeBike);
                    });

                    it(@"should tell the Pebble that is is focusing on an available bike", ^{
                        PebCiti.sharedInstance.pebbleManager should have_received(@selector(setFocusIsBike:)).with(YES);
                    });
                });
            });
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
        });

        context(@"when no closest station has been found", ^{
            beforeEach(^{
                controller.view should_not be_nil;
            });

            it(@"should display an empty string", ^{
                controller.closestStationLabel.text should equal(@"");
            });
        });

        context(@"when requesting an available bike", ^{
            beforeEach(^{
                controller.focusType should equal(PCFocusTypeBike);

                PCStation *station = [[[PCStation alloc] initWithID:@1] autorelease];
                station.name = @"Available Dock Station Name";
                stationList stub_method(@selector(closestStationWithAvailableBike)).and_return(station);

                controller.view should_not be_nil;
            });

            it(@"should be the name of the closest station with an available bike", ^{
                controller.closestStationLabel.text should equal(@"Available Dock Station Name");
            });
        });

        context(@"when requesting an open dock", ^{
            beforeEach(^{
                controller.view should_not be_nil;
                [controller.focusSegmentControl setSelectedSegmentIndex:1];
                [controller.focusSegmentControl sendActionsForControlEvents:UIControlEventValueChanged];

                PCStation *station = [[[PCStation alloc] initWithID:@1] autorelease];
                station.name = @"Open Dock Station Name";
                stationList stub_method(@selector(closestStationWithOpenDock)).and_return(station);

                [controller viewDidLoad];
            });

            it(@"should update to the name of the closest station with an open dock", ^{
                controller.closestStationLabel.text should equal(@"Open Dock Station Name");
            });
        });

        describe(@"on a location update", ^{
            __block PCStation *station;

            beforeEach(^{
                station = [[[PCStation alloc] initWithID:@1] autorelease];
            });

            subjectAction(^{
                controller.view should_not be_nil;
                CLLocationManager *locationManager = nice_fake_for([CLLocationManager class]);
                CLLocation *location = nice_fake_for([CLLocation class]);
                [controller locationManager:locationManager didUpdateLocations:@[ location ]];
            });

            context(@"when requesting an available bike", ^{
                beforeEach(^{
                    station.name = @"Available Dock Station Name";
                    stationList stub_method(@selector(closestStationWithAvailableBike)).and_return(station);
                });

                it(@"should update to the name of the closest station with an available bike", ^{
                    controller.closestStationLabel.text should equal(@"Available Dock Station Name");
                });

                describe(@"when requesting a station with an open bike", ^{
                    beforeEach(^{
                        station.name = @"Open Dock Station Name";
                        stationList stub_method(@selector(closestStationWithOpenDock)).and_return(station);

                        [controller.focusSegmentControl setSelectedSegmentIndex:1];
                        [controller.focusSegmentControl sendActionsForControlEvents:UIControlEventValueChanged];
                    });

                    it(@"should update to the name of the closest station with an open dock", ^{
                        controller.closestStationLabel.text should equal(@"Open Dock Station Name");
                    });
                });
            });
        });
    });

    describe(@"viewing the station list", ^{
        beforeEach(^{
            controller.view should_not be_nil;
        });

        describe(@"selecting the station list row", ^{
            beforeEach(^{
                [controller performSegueWithIdentifier:@"PCHomeViewToPCStationsView" sender:nil];
            });

            it(@"should push a PCStationsVC to the nav stack", ^{
                controller.navigationController.topViewController should be_instance_of([PCStationsViewController class]);
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
                __block PCStation *station;

                beforeEach(^{
                    spy_on(PebCiti.sharedInstance.stationList);
                    station = [[[PCStation alloc] initWithID:@1] autorelease];
                });

                subjectAction(^{
                    CLLocationManager *locationManager = nice_fake_for([CLLocationManager class]);
                    CLLocation *location = nice_fake_for([CLLocation class]);
                    [controller locationManager:locationManager didUpdateLocations:@[ location ]];
                });

                context(@"when requesting the closest bike", ^{
                    beforeEach(^{
                        station.name = @"Station Name with Bike";
                        PebCiti.sharedInstance.stationList stub_method(@selector(closestStationWithAvailableBike)).and_return(station);
                    });

                    it(@"should send the name of the closest station with a bike to the Pebble", ^{
                        PebCiti.sharedInstance.pebbleManager should have_received(@selector(sendMessageToPebble:)).with(@"Station Name with Bike");
                    });

                    describe(@"when asking for the closest open dock", ^{
                        beforeEach(^{
                            station.name = @"Station Name with Open Dock";
                            PebCiti.sharedInstance.stationList stub_method(@selector(closestStationWithOpenDock)).and_return(station);

                            [controller.focusSegmentControl setSelectedSegmentIndex:1];
                            [controller.focusSegmentControl sendActionsForControlEvents:UIControlEventValueChanged];
                        });

                        it(@"should send the name of the closest station with an open dock to the Pebble", ^{
                            PebCiti.sharedInstance.pebbleManager should have_received(@selector(sendMessageToPebble:)).with(@"Station Name with Open Dock");
                        });
                    });
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

                    describe(@"when another error occurs before the first is dismissed", ^{
                        __block NSError *newError;

                        beforeEach(^{
                            newError = [NSError errorWithDomain:@"Domain" code:123 userInfo:@{ NSLocalizedDescriptionKey: @"New error message." }];
                            [controller pebbleManager:nice_fake_for([PCPebbleManager class]) receivedError:newError];
                        });

                        it(@"should not show another alert", ^{
                            UIAlertView.currentAlertView.message should equal(error.localizedDescription);
                        });
                    });

                    describe(@"when another error occurs after the first is dismissed", ^{
                        __block NSError *newError;

                        beforeEach(^{
                            [UIAlertView.currentAlertView dismissWithCancelButton];
                            newError = [NSError errorWithDomain:@"Domain" code:123 userInfo:@{ NSLocalizedDescriptionKey: @"Third error message." }];
                            [controller pebbleManager:nice_fake_for([PCPebbleManager class]) receivedError:newError];
                        });

                        it(@"should show another alert", ^{
                            UIAlertView.currentAlertView.message should equal(@"Third error message.");
                        });
                    });
                });
            });

            describe(@"subsequent location updates", ^{
                __block CLLocationManager *locationManager;
                __block CLLocation *location;

                beforeEach(^{
                    PCStation *station = [[[PCStation alloc] initWithID:@1] autorelease];
                    station.name = @"First Station";

                    spy_on(PebCiti.sharedInstance.stationList);
                    PebCiti.sharedInstance.stationList stub_method(@selector(closestStationWithAvailableBike)).and_return(station);

                    locationManager = nice_fake_for([CLLocationManager class]);
                    location = nice_fake_for([CLLocation class]);
                    [controller locationManager:locationManager didUpdateLocations:@[ location ]];
                });

                it(@"should send the station name to the Pebble", ^{
                    PebCiti.sharedInstance.pebbleManager should have_received(@selector(sendMessageToPebble:)).with(@"First Station");
                });

                context(@"with different stations", ^{
                    beforeEach(^{
                        PCStation *station = [[[PCStation alloc] initWithID:@2] autorelease];
                        station.name = @"Second Station";

                        PCStationList *stationList = nice_fake_for([PCStationList class]);
                        stationList stub_method(@selector(closestStationWithAvailableBike)).and_return(station);
                        spy_on(PebCiti.sharedInstance);
                        PebCiti.sharedInstance stub_method(@selector(stationList)).and_return(stationList);

                        [controller locationManager:locationManager didUpdateLocations:@[ location ]];
                    });

                    it(@"should send the second station name to the Pebble", ^{
                        PebCiti.sharedInstance.pebbleManager should have_received(@selector(sendMessageToPebble:)).with(@"Second Station");
                    });
                });

                context(@"with the same station", ^{
                    beforeEach(^{
                        PCStation *station = [[[PCStation alloc] initWithID:@1] autorelease];
                        station.name = @"Second Station";

                        PCStationList *stationList = nice_fake_for([PCStationList class]);
                        stationList stub_method(@selector(closestStationWithAvailableBike)).and_return(station);
                        spy_on(PebCiti.sharedInstance);
                        PebCiti.sharedInstance stub_method(@selector(stationList)).and_return(stationList);
                    });

                    context(@"after the Pebble failed to connect", ^{
                        beforeEach(^{
                            [controller pebbleManagerFailedToConnectToWatch:nice_fake_for([PCPebbleManager class])];
                            [(id<CedarDouble>)PebCiti.sharedInstance.pebbleManager reset_sent_messages];
                            [controller locationManager:locationManager didUpdateLocations:@[ location ]];
                        });

                        it(@"should send the second station name to the Pebble", ^{
                            PebCiti.sharedInstance.pebbleManager should have_received(@selector(sendMessageToPebble:)).with(@"Second Station");
                        });
                    });

                    context(@"after message sending failed", ^{
                        beforeEach(^{
                            [controller pebbleManager:nice_fake_for([PCPebbleManager class]) receivedError:nice_fake_for([NSError class])];
                            [(id<CedarDouble>)PebCiti.sharedInstance.pebbleManager reset_sent_messages];
                            [controller locationManager:locationManager didUpdateLocations:@[ location ]];
                        });

                        it(@"should send the second station name to the Pebble", ^{
                            PebCiti.sharedInstance.pebbleManager should have_received(@selector(sendMessageToPebble:)).with(@"Second Station");
                        });
                    });

                    context(@"after the Pebble disconnected", ^{
                        beforeEach(^{
                            [controller pebbleManagerDisconnectedFromWatch:nice_fake_for([PCPebbleManager class])];
                            [(id<CedarDouble>)PebCiti.sharedInstance.pebbleManager reset_sent_messages];
                            [controller locationManager:locationManager didUpdateLocations:@[ location ]];
                        });

                        it(@"should send the second station name to the Pebble", ^{
                            PebCiti.sharedInstance.pebbleManager should have_received(@selector(sendMessageToPebble:)).with(@"Second Station");
                        });
                    });

                    context(@"after sending messages to Pebble is toggled", ^{
                        beforeEach(^{
                            [controller sendMessagesSwitchWasToggled:controller.sendMessagesSwitch];
                            [controller sendMessagesSwitchWasToggled:controller.sendMessagesSwitch];

                            [(id<CedarDouble>)PebCiti.sharedInstance.pebbleManager reset_sent_messages];
                            [controller locationManager:locationManager didUpdateLocations:@[ location ]];
                        });

                        it(@"should send the second station name to the Pebble", ^{
                            PebCiti.sharedInstance.pebbleManager should have_received(@selector(sendMessageToPebble:)).with(@"Second Station");
                        });
                    });

                    context(@"and no other special circumstances occurred", ^{
                        beforeEach(^{
                            [(id<CedarDouble>)PebCiti.sharedInstance.pebbleManager reset_sent_messages];
                            [controller locationManager:locationManager didUpdateLocations:@[ location ]];
                        });

                        it(@"should not send the second station name to the Pebble", ^{
                            PebCiti.sharedInstance.pebbleManager should_not have_received(@selector(sendMessageToPebble:));
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

    describe(@"selecting a row in the table", ^{
        beforeEach(^{
            [controller viewWillAppear:NO];
            [controller viewDidAppear:NO];
            spy_on(UIApplication.sharedApplication);
            UIApplication.sharedApplication stub_method(@selector(openURL:));
            spy_on([NSUserDefaults standardUserDefaults]);
        });

        context(@"selecting the 'Download Pebble App' row", ^{
            __block UITableView *tableView;
            __block NSIndexPath *indexPath;

            beforeEach(^{
                UITableViewCell *cell = controller.tableView.visibleCells[3];
                indexPath = [controller.tableView indexPathForCell:cell];
                tableView = nice_fake_for([UITableView class]);
            });

            subjectAction(^{
                [controller tableView:tableView didSelectRowAtIndexPath:indexPath];
            });

            context(@"when the Pebble SDK 2.0 setting is set", ^{
                beforeEach(^{
                    [NSUserDefaults standardUserDefaults] stub_method(@selector(boolForKey:)).with(@"pebble_sdk_2_0").and_return(YES);
                });

                it(@"should open Safari directed at the 2.0 .pbw file", ^{
                    NSURL *pbwURL = [NSURL URLWithString:@"http://masilotti.com/PebCiti/SDK2.0/PebCiti.pbw"];
                    UIApplication.sharedApplication should have_received(@selector(openURL:)).with(pbwURL);
                });
            });

            context(@"when the Pebble SDK 2.0 is off or has never been set", ^{
                beforeEach(^{
                    [NSUserDefaults standardUserDefaults] stub_method(@selector(boolForKey:)).with(@"pebble_sdk_2_0").and_return(NO);
                });

                it(@"should open Safari directed at the 1.X .pbw file", ^{
                    NSURL *pbwURL = [NSURL URLWithString:@"http://masilotti.com/PebCiti/SDK1.X/PebCiti.pbw"];
                    UIApplication.sharedApplication should have_received(@selector(openURL:)).with(pbwURL);
                });
            });

            it(@"should then deselect the row that was selected", ^{
                tableView should have_received(@selector(deselectRowAtIndexPath:animated:)).with(indexPath, YES);
            });

            context(@"selecting any other row", ^{
                beforeEach(^{
                    UITableViewCell *cell = controller.tableView.visibleCells[1];
                    indexPath = [controller.tableView indexPathForCell:cell];
                });

                it(@"should not open Safari if any other cell is selected", ^{
                    UIApplication.sharedApplication should_not have_received(@selector(openURL:));
                });

                it(@"should not deselect any rows", ^{
                    tableView should_not have_received(@selector(deselectRowAtIndexPath:animated:));
                });
            });
        });
    });

    describe(@"-pebbleManager:changedFocusToBike:", ^{
        beforeEach(^{
            spy_on(controller);
            controller stub_method(@selector(focusSegmentControl)).and_return(nice_fake_for([UISegmentedControl class]));
        });

        describe(@"when setting the focus to 'Dock'", ^{
            beforeEach(^{
                [controller pebbleManager:nice_fake_for([PCPebbleManager class]) changedFocusToBike:NO];
            });

            it(@"should change the segment control to 'Dock'", ^{
                controller.focusSegmentControl should have_received(@selector(setSelectedSegmentIndex:)).with(PCFocusTypeDock);
            });

            describe(@"when setting the focus to 'Bike'", ^{
                beforeEach(^{
                    [controller pebbleManager:nice_fake_for([PCPebbleManager class]) changedFocusToBike:YES];
                });

                it(@"should change the segment control to 'Bike'", ^{
                    controller.focusSegmentControl should have_received(@selector(setSelectedSegmentIndex:)).with(PCFocusTypeBike);
                });
            });
        });
    });
});

SPEC_END
