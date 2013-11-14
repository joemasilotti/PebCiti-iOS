#import <Foundation/Foundation.h>

@class PCStation, PCStationList;

@protocol PCStationListDelegate <NSObject>

- (void)stationListWasUpdated:(PCStationList *)stationList;

@end

@interface PCStationList : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, strong, readonly) NSArray *stations;
@property (nonatomic, weak) id<PCStationListDelegate>delegate;

- (void)requestStationList;
- (PCStation *)closestStationWithAvailableBike;
- (PCStation *)closestStationWithOpenDock;

@end
