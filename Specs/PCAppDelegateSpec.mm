#import "PCHomeViewController.h"
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

        it(@"should display a PCHomeViewController", ^{
            delegate.window.rootViewController should be_instance_of([PCHomeViewController class]);
        });
    });
});

SPEC_END
