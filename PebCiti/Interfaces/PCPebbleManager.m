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
                    [weakSelf.watch appMessagesSetUUID:[weakSelf UUIDData]];
                    [weakSelf.delegate pebbleManagerConnectedToWatch:weakSelf];
                    [self.watch appMessagesAddReceiveUpdateHandler:^BOOL(PBWatch *watch, NSDictionary *update) {
                        _focusIsBike = [[update objectForKey:@0] boolValue];
                        [weakSelf.delegate pebbleManager:weakSelf changedFocusToBike:_focusIsBike];
                        return YES;
                    }];
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
        NSDictionary *update = @{ @1: message };
        [self.watch appMessagesPushUpdate:update onSent:^(PBWatch *watch, NSDictionary *update, NSError *error) {
            if (error) {
                weakSelf.sendMessagesToPebble = NO;
                [weakSelf.delegate pebbleManager:weakSelf receivedError:error];
            }
        }];
    }
}

- (void)setFocusIsBike:(BOOL)focusIsBike
{
    if (self.isSendingMessagesToPebble) {
        NSDictionary *update = @{ @0: focusIsBike ? @1 : @0 };
        __weak PCPebbleManager *weakSelf = self;
        [self.watch appMessagesPushUpdate:update onSent:^(PBWatch *watch, NSDictionary *update, NSError *error) {
            if (error) {
                weakSelf.sendMessagesToPebble = NO;
                [weakSelf.delegate pebbleManager:weakSelf receivedError:error];
            }
        }];
    }
}

- (void)setVibratePebble:(BOOL)vibratePebble
{
    NSDictionary *update = @{ @2: [NSNumber numberWithBool:vibratePebble] };
    __weak PCPebbleManager *weakSelf = self;
    [self.watch appMessagesPushUpdate:update onSent:^(PBWatch *watch, NSDictionary *update, NSError *error) {
        if (!error) {
            _vibratePebble = vibratePebble;
        } else {
            _vibratePebble = NO;
            _sendMessagesToPebble = NO;
            [weakSelf.delegate pebbleManager:weakSelf receivedError:error];
        }
    }];
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

- (NSData *)UUIDData
{
    NSUUID *UUID = [[NSUUID alloc] initWithUUIDString:@"F6BB82D0-B5BF-4EC7-A97A-405D3A350444"];
    uuid_t uuid;
    [UUID getUUIDBytes:uuid];
    return [NSData dataWithBytes:uuid length:16];
}

@end
