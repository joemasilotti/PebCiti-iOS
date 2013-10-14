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
    if (self.connectedWatch.isConnected) {
        [self.connectedWatch appMessagesSetUUID:self.UUID];
        [self.delegate pebbleManagerConnectedToWatch:self.connectedWatch];
    } else {
        [self.delegate pebbleManagerFailedToConnectToWatch:nil];
    }
}

- (void)sendMessageToPebble:(NSString *)message
{
    if (self.connectedWatch) {
        __weak PCPebbleManager *weakSelf = self;
        NSDictionary *update = @{ @1: message };
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
    uint8_t bytes[] = { 0xF6, 0xBB, 0x82, 0xD0, 0xB5, 0xBF, 0x4E, 0xC7, 0xA9, 0x7A, 0x40, 0x5D, 0x3A, 0x35, 0x04, 0x44 };
    return [NSData dataWithBytes:bytes length:sizeof(bytes)];
}

@end
