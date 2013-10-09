#import <Foundation/Foundation.h>
#import <PebbleKit/PebbleKit.h>

@protocol PCPebbleManagerDelegate
- (void)pebbleManagerConnectedToWatch:(PBWatch *)watch;
- (void)pebbleManagerFailedToConnectToWatch:(PBWatch *)watch;
- (void)pebbleManagerSentMessageWithError:(NSError *)error;
@end

@interface PCPebbleManager : NSObject <PBPebbleCentralDelegate>

@property (nonatomic, weak) id<PCPebbleManagerDelegate> delegate;
@property (nonatomic, strong, readonly) PBWatch *connectedWatch;

- (void)connectToPebble;
- (void)sendMessageToPebble:(NSString *)message;

@end
