#import "PCAppDelegate.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PCAppDelegateSpec)

describe(@"PCAppDelegate", ^{
    __block PCAppDelegate *delegate;

    beforeEach(^{
        delegate = [[[PCAppDelegate alloc] init] autorelease];
    });

    describe(@"when the app is launched", ^{
        beforeEach(^{
            [delegate application:nil didFinishLaunchingWithOptions:nil];
        });

        it(@"should have a root view controller", ^{
            delegate.window.rootViewController should be_instance_of([UIViewController class]);
        });
    });
});

SPEC_END
