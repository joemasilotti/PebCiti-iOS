#import <Foundation/Foundation.h>

@class PCStation, PCStationList;

@protocol PCStationListDelegate <NSObject>

- (void)stationListWasUpdated:(PCStationList *)stationList;

@end

@interface PCStationList : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, weak) id<PCStationListDelegate>delegate;

- (PCStation *)closestStationWithAvailableBike;
- (PCStation *)closestStationWithOpenDock;
- (NSUInteger)count;
- (PCStation *)objectAtIndexedSubscript:(NSUInteger)index;

@end
