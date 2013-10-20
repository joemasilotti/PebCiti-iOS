#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

@interface PCStation : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) CLLocation* location;
@property (nonatomic) NSUInteger docksAvailable;

@end
