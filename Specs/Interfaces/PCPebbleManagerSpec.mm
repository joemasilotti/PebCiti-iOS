#import "UIAlertView+Spec.h"
#import "PCPebbleManager.h"
#import "PCPebbleCentral.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface PCPebbleManager (Specs)
@property (nonatomic, strong, readwrite) PBWatch *connectedWatch;
@end

SPEC_BEGIN(PCPebbleManagerSpec)

describe(@"PCPebbleManager", ^{
    __block PCPebbleManager *manager;

    beforeEach(^{
        manager = [[[PCPebbleManager alloc] init] autorelease];
    });

    it(@"should be a PebbleCentral delegate", ^{
        [manager conformsToProtocol:@protocol(PBPebbleCentralDelegate)] should be_truthy;
    });

    it(@"should be the default pebble central's delegate", ^{
        PCPebbleCentral.defaultCentral.delegate should be_same_instance_as(manager);
    });

    describe(@"<PBPebbleCentralDelegate>", ^{
        describe(@"-pebbleCentral:watchDidConnect:isNew:", ^{
            __block PBWatch *watch;
            __block void(^completionBlock)(PBWatch *, BOOL);

            beforeEach(^{
                manager.delegate = nice_fake_for(@protocol(PCPebbleManagerDelegate));
                watch = nice_fake_for([PBWatch class]);

                [manager pebbleCentral:nil watchDidConnect:watch isNew:YES];

                NSArray *sentMessages = [(id<CedarDouble>)watch sent_messages];
                sentMessages = [sentMessages filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSInvocation *invocation, NSDictionary *bindings) {
                    return invocation.selector == @selector(appMessagesGetIsSupported:);
                }]];
                NSInvocation *lastMessage = [sentMessages lastObject];

                void(^localCompletionBlock)(PBWatch *, BOOL);
                [lastMessage getArgument:&localCompletionBlock atIndex:2];
                completionBlock = [localCompletionBlock copy];
            });

            afterEach(^{
                [completionBlock release];
                completionBlock = nil;
            });

            context(@"when the watch can accept app messages", ^{
                beforeEach(^{
                    completionBlock(watch, YES);
                });

                it(@"should ask the watch if it can receive app messages", ^{
                    watch should have_received("appMessagesGetIsSupported:");
                });

                it(@"should set the connected watch property", ^{
                    manager.connectedWatch should be_same_instance_as(watch);
                });

                it(@"should set UUID on the watch", ^{
                    uint8_t bytes[] = { 0xF6, 0xBB, 0x82, 0xD0, 0xB5, 0xBF, 0x4E, 0xC7, 0xA9, 0x7A, 0x40, 0x5D, 0x3A, 0x35, 0x04, 0x44 };
                    NSData *UUID = [NSData dataWithBytes:bytes length:sizeof(bytes)];
                    watch should have_received("appMessagesSetUUID:").with(UUID);
                });

                it(@"should tell the delegate which watch successfully connected", ^{
                    manager.delegate should have_received("pebbleManagerConnectedToWatch:").with(watch);
                });
            });

            context(@"when the watch cannot accept app messages", ^{
                beforeEach(^{
                    completionBlock(watch, NO);
                });

                it(@"should not set the connected watch property", ^{
                    manager.connectedWatch should be_nil;
                });

                it(@"should tell the delegate the watch does not support app messages", ^{
                    manager.delegate should have_received("pebbleManagerFailedToConnectToWatch:").with(watch);
                });
            });
        });
    });

    describe(@"-connectToPebble", ^{
        __block PBWatch *watch;

        beforeEach(^{
            spy_on(PCPebbleCentral.defaultCentral);
            manager.delegate = nice_fake_for(@protocol(PCPebbleManagerDelegate));
            watch = nice_fake_for([PBWatch class]);
        });

        context(@"when there was already a connected watch", ^{
            beforeEach(^{
                PCPebbleCentral.defaultCentral stub_method("lastConnectedWatch").and_return(watch);
            });

            context(@"when that watch is still connected", ^{
                beforeEach(^{
                    watch stub_method("isConnected").and_return(YES);

                    [manager connectToPebble];
                });

                it(@"should set the watch property to the most recently connected one", ^{
                    manager.connectedWatch should be_same_instance_as(watch);
                });

                it(@"should set UUID on the watch", ^{
                    uint8_t bytes[] = { 0xF6, 0xBB, 0x82, 0xD0, 0xB5, 0xBF, 0x4E, 0xC7, 0xA9, 0x7A, 0x40, 0x5D, 0x3A, 0x35, 0x04, 0x44 };
                    NSData *UUID = [NSData dataWithBytes:bytes length:sizeof(bytes)];
                    watch should have_received("appMessagesSetUUID:").with(UUID);
                });

                it(@"should tell the delegate which watch successfully connected", ^{
                    manager.delegate should have_received("pebbleManagerConnectedToWatch:").with(watch);
                });
            });

            context(@"when that watch is no longer connected", ^{
                beforeEach(^{
                    watch stub_method("isConnected").and_return(NO);

                    [manager connectToPebble];
                });

                it(@"should tell the delegate there is no connected Pebble", ^{
                    manager.delegate should have_received("pebbleManagerFailedToConnectToWatch:").with(nil);
                });
            });
        });

        context(@"when there wasn't a previously connected watch", ^{
            beforeEach(^{
                [manager connectToPebble];
            });

            it(@"should tell the delegate there is no connected Pebble", ^{
                manager.delegate should have_received("pebbleManagerFailedToConnectToWatch:").with(nil);
            });
        });
    });

    describe(@"-sendMessageToPebble", ^{
        __block PBWatch *watch;

        beforeEach(^{
            watch = nice_fake_for([PBWatch class]);
        });

        context(@"when a watch with a UUID is connected", ^{
            beforeEach(^{
                manager.connectedWatch = watch;
            });

            it(@"should tell the connected watch to display a message", ^{
                [manager sendMessageToPebble:@"message"];
                watch should have_received("appMessagesPushUpdate:onSent:").with(@{ @1: @"message" }, Arguments::anything);
            });

            describe(@"when the update completes", ^{
                __block void(^completionBlock)(PBWatch *, NSDictionary *, NSError *);

                beforeEach(^{
                    [(id<CedarDouble>)watch reset_sent_messages];
                    manager.delegate = nice_fake_for(@protocol(PCPebbleManagerDelegate));

                    [manager sendMessageToPebble:@"message"];

                    NSArray *sentMessages = [(id<CedarDouble>)watch sent_messages];
                    sentMessages = [sentMessages filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSInvocation *invocation, NSDictionary *bindings) {
                        return invocation.selector == @selector(appMessagesPushUpdate:onSent:);
                    }]];
                    NSInvocation *lastMessage = [sentMessages lastObject];

                    void(^localCompletionBlock)(PBWatch *, BOOL);
                    [lastMessage getArgument:&localCompletionBlock atIndex:3];
                    completionBlock = [localCompletionBlock copy];
                });

                afterEach(^{
                    [completionBlock release];
                    completionBlock = nil;
                });

                context(@"when the push update succeeds", ^{
                    beforeEach(^{
                        completionBlock(watch, nil, nil);
                    });

                    it(@"should tell the delegate the update succeeded", ^{
                        manager.delegate should have_received("pebbleManagerSentMessageWithError:").with(nil);
                    });
                });

                context(@"when the push update fails", ^{
                    __block NSError *error;

                    beforeEach(^{
                        error = [NSError errorWithDomain:@"PebbleError" code:12 userInfo:nil];
                        completionBlock(watch, nil, error);
                    });

                    it(@"should tell the delegate the update failed with the error", ^{
                        manager.delegate should have_received("pebbleManagerSentMessageWithError:").with(error);
                    });
                });
            });
        });

        context(@"when no watch is connected", ^{
            beforeEach(^{
                manager.connectedWatch should be_nil;
                manager.delegate = nice_fake_for(@protocol(PCPebbleManagerDelegate));

                [manager sendMessageToPebble:@"message"];
            });

            it(@"should not send any messages to the watch reference", ^{
                watch should_not have_received("appMessagesPushUpdate:onSent:");
            });

            it(@"should tell the delegate no watch is connected", ^{
                manager.delegate should have_received("pebbleManagerFailedToConnectToWatch:").with(nil);
            });
        });

    });
});

SPEC_END
