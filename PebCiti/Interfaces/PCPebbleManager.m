#import "PCPebbleManager.h"

@interface PCPebbleManager ()

@property (nonatomic, strong, readwrite) PBWatch *connectedWatch;

@end

@implementation PCPebbleManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        PBPebbleCentral.defaultCentral.delegate = self;
    }
    return self;
}

- (void)sendMessageToPebble
{

}

#pragma mark - <PBPebbleManagerDelegate>

- (void)pebbleCentral:(PBPebbleCentral *)central watchDidConnect:(PBWatch *)watch isNew:(BOOL)isNew
{
    __weak PCPebbleManager *weakSelf = self;
    [watch appMessagesGetIsSupported:^(PBWatch *watch, BOOL isAppMessagesSupported) {
        if (isAppMessagesSupported) {
            weakSelf.connectedWatch = watch;
        }
    }];
}

@end
