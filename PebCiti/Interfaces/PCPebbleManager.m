#import "PCPebbleManager.h"
#import "PCPebbleCentral.h"

@interface PCPebbleManager ()
@property (nonatomic, strong, readwrite) PBWatch *connectedWatch;
@end

@implementation PCPebbleManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        PCPebbleCentral.defaultCentral.delegate = self;
    }
    return self;
}

- (void)connectToPebble
{
    self.connectedWatch = PCPebbleCentral.defaultCentral.lastConnectedWatch;
    if (self.connectedWatch) {
        [self.connectedWatch appMessagesSetUUID:self.UUID];
        [self.delegate pebbleManagerConnectedToWatch:self.connectedWatch];
    } else {
        [self.delegate pebbleManagerFailedToConnectToWatch:nil];
    }
}

- (void)sendMessageToPebble
{
    if (self.connectedWatch) {
        __weak PCPebbleManager *weakSelf = self;
        NSDictionary *update = @{ @1: @"Hello Pebble!" };
        [self.connectedWatch appMessagesPushUpdate:update onSent:^(PBWatch *watch, NSDictionary *update, NSError *error) {
            [weakSelf.delegate pebbleManagerSentMessageWithError:error];
        }];
    } else {
        [self.delegate pebbleManagerFailedToConnectToWatch:nil];
    }
}

#pragma mark - <PBPebbleManagerDelegate>

- (void)pebbleCentral:(PBPebbleCentral *)central watchDidConnect:(PBWatch *)watch isNew:(BOOL)isNew
{
    __weak PCPebbleManager *weakSelf = self;
    [watch appMessagesGetIsSupported:^(PBWatch *watch, BOOL isAppMessagesSupported) {
        if (isAppMessagesSupported) {
            weakSelf.connectedWatch = watch;
            [weakSelf.connectedWatch appMessagesSetUUID:weakSelf.UUID];
            [self.delegate pebbleManagerConnectedToWatch:watch];
        } else {
            [self.delegate pebbleManagerFailedToConnectToWatch:watch];
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
