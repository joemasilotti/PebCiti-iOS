#import "PCStation.h"

@implementation PCStation

- (instancetype)init
{
    @throw @"Use initWithID: instead.";
}

- (instancetype)initWithID:(NSNumber *)stationID
{
    if (self = [super init]) {
        self.stationID = stationID;
    }
    return self;
}

@end
