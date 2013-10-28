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

        describe(@"canceling the alert view", ^{
            it(@"should not throw an exception", ^{
                ^{ [alertView dismissWithCancelButton]; } should_not raise_exception;
            });
        });
    });

    describe(@"-displayAlertViewWithTitle:message:delegate:", ^{
        __block id<UIAlertViewDelegate> delegate;

        beforeEach(^{
            delegate = nice_fake_for(@protocol(UIAlertViewDelegate));
            alertView = [UIAlertView displayAlertViewWithTitle:@"Title" message:@"Message" delegate:delegate];
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

        describe(@"canceling the alert view", ^{
            beforeEach(^{
                [alertView dismissWithCancelButton];
            });

            it(@"should tell the delegate", ^{
                delegate should have_received(@selector(alertView:didDismissWithButtonIndex:)).with(alertView, alertView.cancelButtonIndex);
            });
        });
    });
});

SPEC_END
