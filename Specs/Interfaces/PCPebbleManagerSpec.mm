#import "PCPebbleManager.h"
#import "UIAlertView+Spec.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PCPebbleManagerSpec)

describe(@"PCPebbleManager", ^{
    __block PCPebbleManager *manager;

    beforeEach(^{
        manager = [[[PCPebbleManager alloc] init] autorelease];
    });

    it(@"should be a PebbleCentral delegate", ^{
        [manager conformsToProtocol:@protocol(PBPebbleCentralDelegate)] should be_truthy;
    });

    // Always fails because PebbleKit.framework is linked under Specs.
    xit(@"should be the default pebble central's delegate", ^{
        PBPebbleCentral.defaultCentral.delegate should be_same_instance_as(manager);
    });

    describe(@"<PBPebbleCentralDelegate>", ^{
        describe(@"-pebbleCentral:watchDidConnect:isNew:", ^{
            __block PBWatch *watch;
            __block void(^completionBlock)(PBWatch *, BOOL);

            beforeEach(^{
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
            });

            context(@"when the watch cannot accept app messages", ^{
                beforeEach(^{
                    completionBlock(watch, NO);
                });

                it(@"should not set the connected watch property", ^{
                    manager.connectedWatch should be_nil;
                });

                it(@"should display an alert view", ^{
                    UIAlertView.currentAlertView should_not be_nil;
                });
            });
        });
    });
});

SPEC_END
