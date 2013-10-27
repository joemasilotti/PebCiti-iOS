#import "PCPebbleManager.h"
#import "PCPebbleCentral.h"

@interface PCPebbleManager ()
@property (nonatomic, strong, readwrite) PBWatch *watch;
@end

@implementation PCPebbleManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        PCPebbleCentral.defaultCentral.delegate = self;
        self.watch = PCPebbleCentral.defaultCentral.lastConnectedWatch;
    }
    return self;
}

- (void)setSendMessagesToPebble:(BOOL)sendMessagesToPebble
{
    if (sendMessagesToPebble) {
        if (self.watch.isConnected) {
            __weak PCPebbleManager *weakSelf = self;
            [self.watch appMessagesGetIsSupported:^(PBWatch *watch, BOOL isAppMessagesSupported) {
                if (isAppMessagesSupported) {
                    [weakSelf.watch appMessagesSetUUID:[weakSelf UUID]];
                    [weakSelf.delegate pebbleManagerConnectedToWatch:weakSelf];
                    _sendMessagesToPebble = YES;
                } else {
                    [weakSelf.delegate pebbleManagerFailedToConnectToWatch:weakSelf];
                }
            }];
        } else {
            [self.delegate pebbleManagerFailedToConnectToWatch:self];
        }
    } else {
        _sendMessagesToPebble = NO;
    }
}

- (void)sendMessageToPebble:(NSString *)message
{
    if (self.isSendingMessagesToPebble) {
        __weak PCPebbleManager *weakSelf = self;
        [self.watch appMessagesPushUpdate:@{ @1: message } onSent:^(PBWatch *watch, NSDictionary *update, NSError *error) {
            if (error) {
                weakSelf.sendMessagesToPebble = NO;
                [weakSelf.delegate pebbleManager:weakSelf receivedError:error];
            }
        }];
    }
}

#pragma mark - <PBPebbleManagerDelegate>

- (void)pebbleCentral:(PBPebbleCentral *)central watchDidConnect:(PBWatch *)watch isNew:(BOOL)isNew
{
    self.watch = watch;
}

- (void)pebbleCentral:(PBPebbleCentral *)central watchDidDisconnect:(PBWatch *)watch
{
    [self.delegate pebbleManagerDisconnectedFromWatch:self];
    self.sendMessagesToPebble = NO;
}

#pragma mark - Private

- (NSData *)UUID
{
    uint8_t bytes[] = { 0xF6, 0xBB, 0x82, 0xD0, 0xB5, 0xBF, 0x4E, 0xC7, 0xA9, 0x7A, 0x40, 0x5D, 0x3A, 0x35, 0x04, 0x44 };
    return [NSData dataWithBytes:bytes length:sizeof(bytes)];
}

@end
