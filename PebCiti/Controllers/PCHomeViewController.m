#import "PCHomeViewController.h"
#import <PebbleKit/PebbleKit.h>
#import "UIAlertView+PebCiti.h"
#import "PCPebbleCentral.h"
#import "PCPebbleManager.h"
#import "PebCiti.h"

@interface PCHomeViewController ()
@property (nonatomic, weak, readwrite) UILabel *connectedPebbleLabel;
@property (nonatomic, weak, readwrite) UIButton *connectToPebbleButton;
@property (nonatomic, weak, readwrite) UITextField *messageTextField;
@property (nonatomic, weak, readwrite) UIButton *sendToPebbleButton;
@property (nonatomic, weak, readwrite) UILabel *currentLocationLabel;
@property (nonatomic, weak, readwrite) UIButton *viewStationsButton;
@property (nonatomic, weak, readwrite) UIActivityIndicatorView *activityIndicator;
@end

@implementation PCHomeViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"PebCiti";
        [self setupConnectedPebbleLabel];
        [self setupConnectToPebbleButton];
        [self setupMessageTextField];
        [self setupSendToPebbleButton];
        [self setupCurrentLocationLabel];
        [self setupViewStationsButton];
        [self setupActivityIndicator];

        PebCiti.sharedInstance.pebbleManager.delegate = self;
        PebCiti.sharedInstance.locationManager.delegate = self;
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    PBWatch *connectedWatch = PCPebbleCentral.defaultCentral.lastConnectedWatch;
    self.connectedPebbleLabel.text = connectedWatch.isConnected ? connectedWatch.name : @"";

    [PebCiti.sharedInstance.locationManager startUpdatingLocation];
}

#pragma mark - <PCPebbleManagerDelegate>

- (void)pebbleManagerConnectedToWatch:(PBWatch *)watch
{
    self.connectedPebbleLabel.text = watch.name;
    [self.activityIndicator stopAnimating];
}

- (void)pebbleManagerFailedToConnectToWatch:(PBWatch *)watch
{
    [self.activityIndicator stopAnimating];
    self.connectedPebbleLabel.text = @"";
    NSString *message = watch ? @"Pebble doesn't support app messages." : @"No connected Pebble recognized.";
    [UIAlertView displayAlertViewWithTitle:@"Cannot Connect to Pebble" message:message];
}

- (void)pebbleManagerSentMessageWithError:(NSError *)error
{
    [self.activityIndicator stopAnimating];
    NSString *message = error ? error.localizedDescription : @"Message sent to Pebble successfully.";
    [UIAlertView displayAlertViewWithTitle:@"" message:message];
}

#pragma mark - <UITextFieldDelegate>

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

#pragma mark - <PCStationsViewControllerDelegate>

- (void)stationsViewControllerIsDone
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - <CLLocationManagerDelegate>

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *lastLocation = locations.lastObject;
    self.currentLocationLabel.text = [NSString stringWithFormat:@"%.4f, %.4f", lastLocation.coordinate.latitude, lastLocation.coordinate.longitude];
}

#pragma mark - Private

#pragma mark Setup UI Elements

- (void)setupConnectedPebbleLabel
{
    UILabel *connectedPebbleLabelStaticLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 0, 160.0f, 50.0f)];
    connectedPebbleLabelStaticLabel.text = @"Connected Pebble: ";
    [self.view addSubview:connectedPebbleLabelStaticLabel];

    UILabel *connectedPebbleLabel = [[UILabel alloc] initWithFrame:CGRectMake(170.0f, 0, 140.0f, 50.0f)];
    connectedPebbleLabel.textAlignment = NSTextAlignmentRight;
    PBWatch *watch = PebCiti.sharedInstance.pebbleManager.connectedWatch;
    connectedPebbleLabel.text = watch ? watch.name : @"";
    [self.view addSubview:connectedPebbleLabel];
    self.connectedPebbleLabel = connectedPebbleLabel;
}

- (void)setupConnectToPebbleButton
{
    UIButton *connectToPebbleButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 35.0f, 320.0f, 50.0f)];
    [connectToPebbleButton setTitle:@"Connect to Pebble" forState:UIControlStateNormal];
    [connectToPebbleButton setTitleColor:self.buttonTitleColor forState:UIControlStateNormal];
    [connectToPebbleButton setTitleColor:self.buttonTitleHighlightedColor forState:UIControlStateHighlighted];
    [connectToPebbleButton addTarget:self action:@selector(connectToPebbleButtonWasTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:connectToPebbleButton];
    self.connectToPebbleButton = connectToPebbleButton;

    UIView *horizontalRule = [[UIView alloc] initWithFrame:CGRectMake(10.0f, 95.0f, 300.0f, 2.0f)];
    horizontalRule.backgroundColor = [self buttonTitleColor];
    [self.view addSubview:horizontalRule];
}

- (void)setupMessageTextField
{
    UITextField *messageTextField = [[UITextField alloc] initWithFrame:CGRectMake(25.0f, 125.0f, 270.0f, 40.0f)];
    messageTextField.delegate = self;
    messageTextField.returnKeyType = UIReturnKeyDone;
    messageTextField.text = @"";
    messageTextField.borderStyle = UITextBorderStyleRoundedRect;
    messageTextField.textAlignment = NSTextAlignmentCenter;
    messageTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.view addSubview:messageTextField];
    self.messageTextField = messageTextField;
}

- (void)setupSendToPebbleButton
{
    UIButton *sendToPebbleButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 165.0f, 320.0f, 50.0f)];
    [sendToPebbleButton setTitle:@"Send Message to Pebble" forState:UIControlStateNormal];
    [sendToPebbleButton setTitleColor:self.buttonTitleColor forState:UIControlStateNormal];
    [sendToPebbleButton setTitleColor:self.buttonTitleHighlightedColor forState:UIControlStateHighlighted];
    [sendToPebbleButton addTarget:self action:@selector(sendToPebbleButtonWasTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sendToPebbleButton];
    self.sendToPebbleButton = sendToPebbleButton;

    UIView *horizontalRule = [[UIView alloc] initWithFrame:CGRectMake(10.0f, 225.0f, 300.0f, 2.0f)];
    horizontalRule.backgroundColor = [self buttonTitleColor];
    [self.view addSubview:horizontalRule];
}

- (void)setupCurrentLocationLabel
{
    UILabel *currentLocationStaticLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 235.0f, 140.0f, 50.0f)];
    currentLocationStaticLabel.text = @"Current Location: ";
    [self.view addSubview:currentLocationStaticLabel];

    UILabel *currentLocationLabel = [[UILabel alloc] initWithFrame:CGRectMake(150.0f, 235.0f, 160.0f, 50.0f)];
    currentLocationLabel.textAlignment = NSTextAlignmentRight;
    currentLocationLabel.text = @"";
    [self.view addSubview:currentLocationLabel];
    self.currentLocationLabel = currentLocationLabel;
}

- (void)setupViewStationsButton
{
    UIButton *viewStationsButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 270.0f, 320.0f, 50.0f)];
    [viewStationsButton setTitle:@"View All Stations" forState:UIControlStateNormal];
    [viewStationsButton setTitleColor:self.buttonTitleColor forState:UIControlStateNormal];
    [viewStationsButton setTitleColor:self.buttonTitleHighlightedColor forState:UIControlStateHighlighted];
    [viewStationsButton addTarget:self action:@selector(viewStationsButtonWasTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:viewStationsButton];
    self.viewStationsButton = viewStationsButton;
}

#pragma mark UI Element Actions

- (void)setupActivityIndicator
{
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    activityIndicator.color = [UIColor blackColor];
    activityIndicator.hidesWhenStopped = YES;
    [self.view addSubview:activityIndicator];
    self.activityIndicator = activityIndicator;
}

- (void)connectToPebbleButtonWasTapped
{
    [self.activityIndicator startAnimating];
    [PebCiti.sharedInstance.pebbleManager connectToPebble];
}

- (void)sendToPebbleButtonWasTapped
{
    [self.activityIndicator startAnimating];
    [PebCiti.sharedInstance.pebbleManager sendMessageToPebble:self.messageTextField.text];
}

- (void)viewStationsButtonWasTapped
{
    PCStationsViewController *stationsViewController = [[PCStationsViewController alloc] initWithDelegate:self];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:stationsViewController];
    [self presentViewController:navController animated:YES completion:nil];
}

#pragma mark UIButton Color Helpers

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
