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
                    uint8_t bytes[] = {0x42, 0xc8, 0x6e, 0xa4, 0x1c, 0x3e, 0x4a, 0x07, 0xb8, 0x89, 0x2c, 0xcc, 0xca, 0x91, 0x41, 0x98};
                    NSData *UUID = [NSData dataWithBytes:bytes length:sizeof(bytes)];
                    watch should have_received("appMessagesSetUUID:").with(UUID);
                });

                it(@"should tell the delegate which watch successfully connected", ^{
                    manager.delegate should have_received("watchDidConnect:").with(watch);
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
                    manager.delegate should have_received("watchDoesNotSupportAppMessages");
                });
            });
        });
    });

    describe(@"-connectToPebble", ^{
        __block PBWatch *watch;

        beforeEach(^{
            spy_on(PCPebbleCentral.defaultCentral);
            manager.delegate = nice_fake_for(@protocol(PCPebbleManagerDelegate));
        });

        context(@"when there was already a connected watch", ^{
            beforeEach(^{
                watch = nice_fake_for([PBWatch class]);
                PCPebbleCentral.defaultCentral stub_method("lastConnectedWatch").and_return(watch);

                [manager connectToPebble];
            });

            it(@"should set the watch property to the most recently connected one", ^{
                manager.connectedWatch should be_same_instance_as(watch);
            });

            it(@"should set UUID on the watch", ^{
                uint8_t bytes[] = {0x42, 0xc8, 0x6e, 0xa4, 0x1c, 0x3e, 0x4a, 0x07, 0xb8, 0x89, 0x2c, 0xcc, 0xca, 0x91, 0x41, 0x98};
                NSData *UUID = [NSData dataWithBytes:bytes length:sizeof(bytes)];
                watch should have_received("appMessagesSetUUID:").with(UUID);
            });

            it(@"should tell the delegate which watch successfully connected", ^{
                manager.delegate should have_received("watchDidConnect:").with(watch);
            });
        });

        context(@"when there wasn't a previously connected watch", ^{
            beforeEach(^{
                [manager connectToPebble];
            });

            it(@"should display an alert view", ^{
                UIAlertView.currentAlertView should_not be_nil;
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
                [manager sendMessageToPebble];
            });

            it(@"should tell the connected watch to display a message", ^{
                watch should have_received("appMessagesPushUpdate:onSent:").with(@{ @1: @"Hello Pebble!" }, Arguments::anything);
            });

            describe(@"when the update completes", ^{
                __block void(^completionBlock)(PBWatch *, NSDictionary *, NSError *);

                beforeEach(^{
                    [(id<CedarDouble>)watch reset_sent_messages];

                    [manager sendMessageToPebble];

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

                    it(@"should display an alert view saying the update succeeded", ^{
                        UIAlertView.currentAlertView.message should equal(@"Message sent to Pebble successfully.");
                    });
                });

                context(@"when the push update fails", ^{
                    beforeEach(^{
                        completionBlock(watch, nil, [NSError errorWithDomain:@"" code:12 userInfo:nil]);
                    });

                    it(@"should display an alert view with an error message", ^{
                        UIAlertView.currentAlertView.message should equal(@"An error occurred updating the Pebble.");
                    });
                });
            });
        });

        context(@"when no watch is connected", ^{
            beforeEach(^{
                manager.connectedWatch should be_nil;
                [manager sendMessageToPebble];
            });

            it(@"should not send any messages to the watch reference", ^{
                watch should_not have_received("appMessagesPushUpdate:onSent:");
            });

            it(@"should display an alert view", ^{
                UIAlertView.currentAlertView should_not be_nil;
            });
        });

    });
});

SPEC_END
