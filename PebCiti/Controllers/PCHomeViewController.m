#import "PCHomeViewController.h"
#import "PCPebbleManager.h"
#import "PebCiti.h"

@interface PCHomeViewController ()
@property (nonatomic, weak, readwrite) UIButton *sendToPebbleButton;
@end

@implementation PCHomeViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupSendToPebbleButton];
    }
    return self;
}

#pragma mark - Private

- (void)setupSendToPebbleButton
{
    UIButton *sendToPebbleButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    sendToPebbleButton.center = self.view.center;
    [sendToPebbleButton addTarget:self action:@selector(sendToPebbleButtonWasTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sendToPebbleButton];
    self.sendToPebbleButton = sendToPebbleButton;
}

- (void)sendToPebbleButtonWasTapped
{
    [PebCiti.sharedInstance.pebbleManager sendMessageToPebble];
}

@end
