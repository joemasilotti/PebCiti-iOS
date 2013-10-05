#import <Foundation/Foundation.h>

@class PCPebbleManager;

@interface PebCiti : NSObject

@property (nonatomic, strong, readonly) PCPebbleManager *pebbleManager;

+ (PebCiti *)sharedInstance;

@end
