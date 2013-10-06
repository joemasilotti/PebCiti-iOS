#import <Foundation/Foundation.h>
#import <PebbleKit/PebbleKit.h>

@interface PCPebbleManager : NSObject <PBPebbleCentralDelegate>

@property (nonatomic, strong, readonly) PBWatch *connectedWatch;

- (void)connectToPebble;
- (void)sendMessageToPebble;

@end
