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

        it(@"should display a UINavigationController", ^{
            delegate.window.rootViewController should be_instance_of([UINavigationController class]);
        });

        describe(@"the navigation controller", ^{
            it(@"should contain a PCHomeViewController", ^{
                delegate.window.rootViewController.childViewControllers[0] should be_instance_of([PCHomeViewController class]);
            });
        });
    });
});

SPEC_END
