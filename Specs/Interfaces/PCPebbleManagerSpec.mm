#import "UIAlertView+Spec.h"
#import "PCPebbleManager.h"
#import "PCPebbleCentral.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PCPebbleManagerSpec)

describe(@"PCPebbleManager", ^{
    __block PCPebbleManager *manager;

    beforeEach(^{
        spy_on(PCPebbleCentral.defaultCentral);
        PBWatch *watch = nice_fake_for([PBWatch class]);
        PCPebbleCentral.defaultCentral stub_method(@selector(lastConnectedWatch)).and_return(watch);

        manager = [[[PCPebbleManager alloc] init] autorelease];
        manager.delegate = nice_fake_for(@protocol(PCPebbleManagerDelegate));
    });

    it(@"should be the default pebble central's delegate", ^{
        PCPebbleCentral.defaultCentral.delegate should be_same_instance_as(manager);
    });

    it(@"should set the watch to the last connected one", ^{
        manager.watch should be_same_instance_as(PCPebbleCentral.defaultCentral.lastConnectedWatch);
    });

    describe(@"when a watch connects", ^{
        __block PBWatch *watch;

        beforeEach(^{
            watch = nice_fake_for([PBWatch class]);
            watch stub_method(@selector(isConnected)).and_return(YES);

            PBPebbleCentral *pebbleCentral = nice_fake_for([PBPebbleCentral class]);
            [manager pebbleCentral:pebbleCentral watchDidConnect:watch isNew:YES];
        });

        it(@"should set the watch to the connected watch", ^{
            manager.watch should be_same_instance_as(watch);
        });
    });

    describe(@"when telling the manager to send messages to the Pebble", ^{
        context(@"when there is a connected Pebble", ^{
            __block PBWatch *watch;
            __block void (^completion)(PBWatch *, BOOL);

            beforeEach(^{
                watch = nice_fake_for([PBWatch class]);
                watch stub_method(@selector(isConnected)).and_return(YES);
                [manager pebbleCentral:nice_fake_for([PCPebbleCentral class]) watchDidConnect:watch isNew:YES];

                manager.sendMessagesToPebble = YES;

                NSInvocation *lastMessage = [[[(id<CedarDouble>)watch sent_messages] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSInvocation *invocation, NSDictionary *bindings) {
                    return invocation.selector == @selector(appMessagesGetIsSupported:);
                }]] lastObject];

                void (^localCompletion)(PBWatch *, BOOL);
                [lastMessage getArgument:&localCompletion atIndex:2];
                completion = [localCompletion copy];
            });

            afterEach(^{
                [completion release];
            });

            context(@"and that Pebble supports app messages", ^{
                beforeEach(^{
                    completion(watch, YES);
                });

                it(@"should set the UUID on the Pebble", ^{
                    NSUUID *UUID = [[[NSUUID alloc] initWithUUIDString:@"F6BB82D0-B5BF-4EC7-A97A-405D3A350444"] autorelease];
                    uuid_t uuid;
                    [UUID getUUIDBytes:uuid];
                    NSData *UUIDData = [NSData dataWithBytes:uuid length:16];
                    watch should have_received(@selector(appMessagesSetUUID:)).with(UUIDData);
                });

                it(@"should tell the delegate it connected", ^{
                    manager.delegate should have_received(@selector(pebbleManagerConnectedToWatch:)).with(manager);
                });

                it(@"should set isSendingMessagesToPebble to YES", ^{
                    manager.isSendingMessagesToPebble should be_truthy;
                });

                describe(@"when that watch disconnects", ^{
                    beforeEach(^{
                        [manager pebbleCentral:nice_fake_for([PBPebbleCentral class]) watchDidDisconnect:watch];
                    });

                    it(@"should alert the delegate", ^{
                        manager.delegate should have_received(@selector(pebbleManagerDisconnectedFromWatch:)).with(manager);
                    });

                    it(@"should stop sending messages to the (now disconnected) Pebble", ^{
                        manager.isSendingMessagesToPebble should_not be_truthy;
                    });
                });

                describe(@"when telling the manager to vibrate the Pebble", ^{
                    __block void (^completion)(PBWatch *, NSDictionary *, NSError *);

                    beforeEach(^{
                        [manager pebbleCentral:nice_fake_for([PCPebbleCentral class]) watchDidConnect:watch isNew:YES];
                        manager.vibratePebble = YES;

                        NSInvocation *lastMessage = [[[(id<CedarDouble>)watch sent_messages] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSInvocation *invocation, NSDictionary *bindings) {
                            return invocation.selector == @selector(appMessagesPushUpdate:onSent:);
                        }]] lastObject];

                        __block void (^localCompletion)(PBWatch *, NSDictionary *, NSError *);
                        [lastMessage getArgument:&localCompletion atIndex:3];
                        completion = [localCompletion copy];
                    });

                    afterEach(^{
                        [completion release];
                    });

                    it(@"should tell the Pebble to vibrate", ^{
                        NSDictionary *update = @{ @2: @1 };
                        watch should have_received(@selector(appMessagesPushUpdate:onSent:)).with(update, Arguments::anything);
                    });

                    describe(@"when the update succeeds", ^{
                        beforeEach(^{
                            completion(watch, nil, nil);
                        });

                        it(@"should set the vibrating status to true", ^{
                            manager.isVibratingPebble should be_truthy;
                        });

                        describe(@"when telling the manager to not vibrate the Pebble", ^{
                            __block void (^offCompletion)(PBWatch *, NSDictionary *, NSError *);

                            beforeEach(^{
                                manager.vibratePebble = NO;

                                NSInvocation *lastMessage = [[[(id<CedarDouble>)watch sent_messages] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSInvocation *invocation, NSDictionary *bindings) {
                                    return invocation.selector == @selector(appMessagesPushUpdate:onSent:);
                                }]] lastObject];

                                __block void (^localCompletion)(PBWatch *, NSDictionary *, NSError *);
                                [lastMessage getArgument:&localCompletion atIndex:3];
                                offCompletion = [localCompletion copy];
                            });

                            afterEach(^{
                                [offCompletion release];
                            });

                            it(@"should tell the Pebble not to vibrate", ^{
                                NSDictionary *update = @{ @2: @0 };
                                watch should have_received(@selector(appMessagesPushUpdate:onSent:)).with(update, Arguments::anything);
                            });

                            describe(@"when the update succeeds", ^{
                                beforeEach(^{
                                    offCompletion(watch, nil, nil);
                                });

                                it(@"should set the vibrating status to false", ^{
                                    manager.isVibratingPebble should_not be_truthy;
                                });
                            });

                            describe(@"when the update fails", ^{
                                __block NSError *error;

                                beforeEach(^{
                                    error = nice_fake_for([NSError class]);
                                    offCompletion(watch, nil, error);
                                });

                                it(@"should set the vibrating status to false", ^{
                                    manager.isVibratingPebble should_not be_truthy;
                                });

                                it(@"should stop sending updates to the Pebble", ^{
                                    manager.isSendingMessagesToPebble should_not be_truthy;
                                });

                                it(@"should alert the delegate of the error", ^{
                                    manager.delegate should have_received(@selector(pebbleManager:receivedError:)).with(manager, error);
                                });
                            });
                        });
                    });

                    describe(@"when the update fails", ^{
                        __block NSError *error;

                        beforeEach(^{
                            error = nice_fake_for([NSError class]);
                            completion(watch, nil, error);
                        });

                        it(@"should set the vibrating status to false", ^{
                            manager.isVibratingPebble should_not be_truthy;
                        });

                        it(@"should stop sending updates to the Pebble", ^{
                            manager.isSendingMessagesToPebble should_not be_truthy;
                        });

                        it(@"should alert the delegate of the error", ^{
                            manager.delegate should have_received(@selector(pebbleManager:receivedError:)).with(manager, error);
                        });
                    });
                });
            });

            context(@"and that Pebble does not support app messages", ^{
                beforeEach(^{
                    completion(watch, NO);
                });

                it(@"should tell the delegate it failed to connect", ^{
                    manager.delegate should have_received(@selector(pebbleManagerFailedToConnectToWatch:)).with(manager);
                });

                it(@"should set isSendingMessagesToPebble to NO", ^{
                    manager.isSendingMessagesToPebble should_not be_truthy;
                });
            });
        });

        context(@"when there is not a connected Pebble", ^{
            beforeEach(^{
                [manager pebbleCentral:nice_fake_for([PCPebbleCentral class]) watchDidConnect:nil isNew:NO];
                manager.sendMessagesToPebble = YES;
            });

            it(@"should tell the delegate it failed to connect", ^{
                manager.delegate should have_received(@selector(pebbleManagerFailedToConnectToWatch:)).with(manager);
            });

            it(@"should set isSendingMessagesToPebble to NO", ^{
                manager.isSendingMessagesToPebble should_not be_truthy;
            });
        });
    });

    describe(@"sending a message to the Pebble", ^{
        __block PBWatch *watch;

        beforeEach(^{
            watch = nice_fake_for([PBWatch class]);
            [manager pebbleCentral:nice_fake_for([PCPebbleCentral class]) watchDidConnect:watch isNew:YES];

            spy_on(manager);
        });

        context(@"when the manager should be sending messages", ^{
            __block void (^completion)(PBWatch *, NSDictionary *, NSError *);

            beforeEach(^{
                manager stub_method(@selector(isSendingMessagesToPebble)).and_return(YES);
                [manager sendMessageToPebble:@"Message text"];

                NSInvocation *lastMessage = [[[(id<CedarDouble>)watch sent_messages] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSInvocation *invocation, NSDictionary *bindings) {
                    return invocation.selector == @selector(appMessagesPushUpdate:onSent:);
                }]] lastObject];

                void (^localCompletion)(PBWatch *, NSDictionary *, NSError *);
                [lastMessage getArgument:&localCompletion atIndex:3];
                completion = [localCompletion copy];
            });

            afterEach(^{
                [completion release];
            });

            it(@"should send the message to the Pebble", ^{
                NSDictionary *message = @{ @1: @"Message text" };
                manager.watch should have_received(@selector(appMessagesPushUpdate:onSent:)).with(message, Arguments::anything);
            });

            describe(@"when the message sent successfully", ^{
                beforeEach(^{
                    completion(watch, nil, nil);
                });

                it(@"should continue to send messages", ^{
                    manager.isSendingMessagesToPebble should be_truthy;
                });
            });

            describe(@"when the message fails to send", ^{
                __block NSError *error;

                beforeEach(^{
                    spy_on(manager);
                    error = [NSError errorWithDomain:@"Domain" code:987 userInfo:@{ NSLocalizedDescriptionKey: @"Some message." }];
                    completion(watch, nil, error);
                });

                it(@"should tell the delegate of the error", ^{
                    manager.delegate should have_received(@selector(pebbleManager:receivedError:)).with(manager, error);
                });

                it(@"should turn off sending messages", ^{
                    manager should have_received(@selector(setSendMessagesToPebble:)).with(NO);
                });
            });
        });

        context(@"when the manager should not be sending messages", ^{
            beforeEach(^{
                manager stub_method(@selector(isSendingMessagesToPebble)).and_return(NO);
                [manager sendMessageToPebble:@"Message text"];
            });

            it(@"should not send a message to the watch", ^{
                manager.watch should_not have_received(@selector(appMessagesPushUpdate:onSent:));
            });
        });
    });

    describe(@"setting the focus on the Pebble", ^{
        __block PBWatch *watch;

        beforeEach(^{
            spy_on(manager);
            watch = nice_fake_for([PBWatch class]);
        });

        context(@"when a watch is connected", ^{
            beforeEach(^{
                [manager pebbleCentral:nice_fake_for([PCPebbleCentral class]) watchDidConnect:watch isNew:YES];
            });

            context(@"when the app should be sending messages", ^{
                beforeEach(^{
                    manager stub_method(@selector(isSendingMessagesToPebble)).and_return(YES);
                    [manager changeFocusTo:@"New Focus"];
                });

                it(@"should tell the watch the new focus", ^{
                    NSDictionary *update = @{@0: @"New Focus"};
                    watch should have_received(@selector(appMessagesPushUpdate:onSent:)).with(update, Arguments::anything);
                });

                describe(@"sending the message", ^{
                    __block void (^completion)(PBWatch *, NSDictionary *, NSError *);

                    beforeEach(^{
                        NSInvocation *lastMessage = [[[(id<CedarDouble>)watch sent_messages] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSInvocation *invocation, NSDictionary *bindings) {
                            return invocation.selector == @selector(appMessagesPushUpdate:onSent:);
                        }]] lastObject];

                        void (^localCompletion)(PBWatch *, NSDictionary *, NSError *);
                        [lastMessage getArgument:&localCompletion atIndex:3];
                        completion = [localCompletion copy];
                    });

                    afterEach(^{
                        [completion release];
                    });

                    context(@"succeeds", ^{
                        beforeEach(^{
                            completion(watch, nil, nil);
                        });

                        it(@"should continue to send messages", ^{
                            manager.isSendingMessagesToPebble should be_truthy;
                        });
                    });

                    context(@"fails", ^{
                        __block NSError *error;

                        beforeEach(^{
                            error = nice_fake_for([NSError class]);
                            completion(watch, nil, error);
                        });

                        it(@"should tell the delegate of the error", ^{
                            manager.delegate should have_received(@selector(pebbleManager:receivedError:)).with(manager, error);
                        });

                        it(@"should turn off sending messages", ^{
                            manager should have_received(@selector(setSendMessagesToPebble:)).with(NO);
                        });
                    });
                });
            });

            context(@"when the app should not be sending messages", ^{
                beforeEach(^{
                    manager stub_method(@selector(isSendingMessagesToPebble)).and_return(NO);
                    [manager changeFocusTo:@"New Focus"];
                });

                it(@"should not tell the watch to change focus", ^{
                    watch should_not have_received(@selector(appMessagesPushUpdate:onSent:));
                });
            });
        });
    });

    describe(@"when telling the manager to stop sending messages to the Pebble", ^{
        __block PBWatch *watch;

        beforeEach(^{
            manager.sendMessagesToPebble = YES;
            manager.vibratePebble = YES;
            watch = nice_fake_for([PBWatch class]);
            watch stub_method(@selector(isConnected)).and_return(YES);
            [manager pebbleCentral:nice_fake_for([PCPebbleCentral class]) watchDidConnect:watch isNew:YES];
            manager.sendMessagesToPebble = NO;
        });

        it(@"should not send any messages to the watch", ^{
            watch should_not have_received(@selector(appMessagesGetIsSupported:));
        });

        it(@"should set isSendingMessagesToPebble to NO", ^{
            manager.isSendingMessagesToPebble should_not be_truthy;
        });

        it(@"should stop vibrating the Pebble", ^{
            manager.isVibratingPebble should_not be_truthy;
        });
    });
});

SPEC_END
