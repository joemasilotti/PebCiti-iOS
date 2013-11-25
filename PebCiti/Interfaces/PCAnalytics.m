#import "GAIDictionaryBuilder.h"
#import "PCAnalytics.h"
#import "GAIFields.h"

@interface PCAnalytics ()
@property (nonatomic, strong, readwrite) id<GAITracker> tracker;
@end

@implementation PCAnalytics

- (instancetype)init
{
    if (self = [super init]) {
#ifndef DEBUG
        self.tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-45996750-1"];
#endif
    }
    return self;
}

- (void)setActiveScreenName:(NSString *)screenName
{
    if (self.tracker) {
        [self.tracker set:kGAIScreenName value:screenName];
        [self.tracker send:[[GAIDictionaryBuilder createAppView] build]];
    }
}

@end
