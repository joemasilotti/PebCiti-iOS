#import <Foundation/Foundation.h>
#import <PebbleKit/PebbleKit.h>

@protocol PCPebbleManagerDelegate
- (void)watchDidConnect:(PBWatch *)watch;
- (void)watchDoesNotSupportAppMessages;
@end

@interface PCPebbleManager : NSObject <PBPebbleCentralDelegate>

@property (nonatomic, weak) id<PCPebbleManagerDelegate> delegate;
@property (nonatomic, strong, readonly) PBWatch *connectedWatch;

- (void)connectToPebble;
- (void)sendMessageToPebble;

@end
