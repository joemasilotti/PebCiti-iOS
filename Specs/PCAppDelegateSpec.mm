#import "PCHomeViewController.h"
#import "PCAppDelegate.h"
#import "PebCiti.h"

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
            spy_on(PebCiti.sharedInstance);
            [delegate application:nil didFinishLaunchingWithOptions:nil];
        });

        it(@"should ask PebCiti to set up the appearance of the app", ^{
            PebCiti.sharedInstance should have_received(@selector(setUpAppearance));
        });
    });
});

SPEC_END
