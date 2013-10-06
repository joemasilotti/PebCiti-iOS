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
        self.title = @"PebCiti";
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
    [connectToPebbleButton setTitleColor:self.buttonTitleColor forState:UIControlStateNormal];
    [connectToPebbleButton setTitleColor:self.buttonTitleHighlightedColor forState:UIControlStateHighlighted];
    [connectToPebbleButton addTarget:self action:@selector(connectToPebbleButtonWasTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:connectToPebbleButton];
    self.connectToPebbleButton = connectToPebbleButton;
}

- (void)setupSendToPebbleButton
{
    UIButton *sendToPebbleButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 175.0f, 320.0f, 50.0f)];
    [sendToPebbleButton setTitle:@"Send Message to Pebble" forState:UIControlStateNormal];
    [sendToPebbleButton setTitleColor:self.buttonTitleColor forState:UIControlStateNormal];
    [sendToPebbleButton setTitleColor:self.buttonTitleHighlightedColor forState:UIControlStateHighlighted];
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

- (UIColor *)buttonTitleColor
{
    if ([self.view respondsToSelector:@selector(tintColor)]) {
        return self.view.tintColor;
    } else {
        return [UIColor blueColor];
    }
}

- (UIColor *)buttonTitleHighlightedColor
{
    return [[self buttonTitleColor] colorWithAlphaComponent:0.5f];
}

@end
