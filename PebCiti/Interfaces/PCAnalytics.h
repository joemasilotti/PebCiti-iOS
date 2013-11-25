#import <Foundation/Foundation.h>
#import "GAI.h"

@interface PCAnalytics : NSObject

@property (nonatomic, strong, readonly) id<GAITracker> tracker;

- (void)setActiveScreenName:(NSString *)screenName;

@end
