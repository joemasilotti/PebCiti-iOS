#import "UIAlertView+PebCiti.h"
#import "UIAlertView+Spec.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(UIAlertViewPebCitiSpec)

describe(@"UIAlertView_PebCiti", ^{
    __block UIAlertView *alertView;

    describe(@"-displayAlertViewWithTitle:message:", ^{
        beforeEach(^{
            alertView = [UIAlertView displayAlertViewWithTitle:@"Title" message:@"Message"];
        });

        it(@"should display the alert view", ^{
            UIAlertView.currentAlertView should be_same_instance_as(alertView);
        });

        it(@"should set the title", ^{
            alertView.title should equal(@"Title");
        });

        it(@"should set the message", ^{
            alertView.message should equal(@"Message");
        });
    });
});

SPEC_END
