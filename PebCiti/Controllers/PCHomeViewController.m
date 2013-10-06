#import "PCHomeViewController.h"
#import "PCPebbleManager.h"
#import "PebCiti.h"

@interface PCHomeViewController ()
@property (nonatomic, weak, readwrite) UIButton *connectToPebbleButton;
@property (nonatomic, weak, readwrite) UIButton *sendToPebbleButton;
@end

@implementation PCHomeViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupConnectToPebbleButton];
        [self setupSendToPebbleButton];
    }
    return self;
}

#pragma mark - Private

- (void)setupConnectToPebbleButton
{
    UIButton *connectToPebbleButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 100.0f, 320.0f, 50.0f)];
    [connectToPebbleButton setTitle:@"Connect to Pebble" forState:UIControlStateNormal];
    [connectToPebbleButton setTitleColor:self.view.tintColor forState:UIControlStateNormal];
    [connectToPebbleButton setTitleColor:[self.view.tintColor colorWithAlphaComponent:0.5f] forState:UIControlStateHighlighted];
    [connectToPebbleButton addTarget:self action:@selector(connectToPebbleButtonWasTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:connectToPebbleButton];
    self.connectToPebbleButton = connectToPebbleButton;
}

- (void)setupSendToPebbleButton
{
    UIButton *sendToPebbleButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 175.0f, 320.0f, 50.0f)];
    [sendToPebbleButton setTitle:@"Send Message to Pebble" forState:UIControlStateNormal];
    [sendToPebbleButton setTitleColor:self.view.tintColor forState:UIControlStateNormal];
    [sendToPebbleButton setTitleColor:[self.view.tintColor colorWithAlphaComponent:0.5f] forState:UIControlStateHighlighted];
    [sendToPebbleButton addTarget:self action:@selector(sendToPebbleButtonWasTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sendToPebbleButton];
    self.sendToPebbleButton = sendToPebbleButton;
}

- (void)connectToPebbleButtonWasTapped
{
    [PebCiti.sharedInstance.pebbleManager connectToPebble];
}

- (void)sendToPebbleButtonWasTapped
{
    [PebCiti.sharedInstance.pebbleManager sendMessageToPebble];
}

@end
