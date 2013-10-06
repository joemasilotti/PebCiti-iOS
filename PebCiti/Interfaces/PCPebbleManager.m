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
            [weakSelf.connectedWatch appMessagesSetUUID:weakSelf.UUID];
        } else {
            [[[UIAlertView alloc] initWithTitle:@""
                                        message:@"This Pebble doesn't support app messages."
                                       delegate:nil
                              cancelButtonTitle:@"Dismiss"
                              otherButtonTitles:nil] show];
        }
    }];
}

#pragma mark - Private

- (NSData *)UUID
{
    uint8_t bytes[] = {0x42, 0xc8, 0x6e, 0xa4, 0x1c, 0x3e, 0x4a, 0x07, 0xb8, 0x89, 0x2c, 0xcc, 0xca, 0x91, 0x41, 0x98};
    return [NSData dataWithBytes:bytes length:sizeof(bytes)];
}

@end
