#import <PebbleKit/PebbleKit.h>
#import "PCHomeViewController.h"
#import "UIAlertView+PebCiti.h"
#import "PCPebbleCentral.h"
#import "PCPebbleManager.h"
#import "PCStation.h"
#import "PebCiti.h"

@interface PCHomeViewController ()
@property (nonatomic, getter = isErrorAlertPresented) BOOL errorAlertPresented;
@end

@implementation PCHomeViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"PebCiti";
        PebCiti.sharedInstance.pebbleManager.delegate = self;
        PebCiti.sharedInstance.locationManager.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *closestStationName = PebCiti.sharedInstance.stationList.closestStation.name;
    self.closestStationLabel.text = closestStationName ? closestStationName : @"";
    self.sendMessagesSwitch.on = PebCiti.sharedInstance.pebbleManager.isSendingMessagesToPebble;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [PebCiti.sharedInstance.locationManager startUpdatingLocation];
    [self setupActivityIndicator];
}

- (IBAction)sendMessagesSwitchWasToggled:(UISwitch *)sendMessagesSwitch
{
    if (sendMessagesSwitch.isOn) {
        [self.activityIndicator startAnimating];
    }
    PebCiti.sharedInstance.pebbleManager.sendMessagesToPebble = sendMessagesSwitch.isOn;
}

- (IBAction)viewStationsButtonWasTapped:(UIButton *)viewStationsButton
{
    PCStationsViewController *stationsViewController = [[PCStationsViewController alloc] initWithDelegate:self];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:stationsViewController];
    [self presentViewController:navController animated:YES completion:nil];
}

#pragma mark - <PCPebbleManagerDelegate>

- (void)pebbleManagerConnectedToWatch:(PBWatch *)watch
{
    [self.activityIndicator stopAnimating];
}

- (void)pebbleManagerFailedToConnectToWatch:(PBWatch *)watch
{
    [self.activityIndicator stopAnimating];
    [self.sendMessagesSwitch setOn:NO animated:YES];
    [UIAlertView displayAlertViewWithTitle:@"No Pebble Connected" message:@"Connect a Pebble that supports app messages before continuing."];
}

- (void)pebbleManager:(PCPebbleManager *)pebbleManager receivedError:(NSError *)error
{
    [self.sendMessagesSwitch setOn:NO animated:YES];
    if (!self.isErrorAlertPresented) {
        self.errorAlertPresented = YES;
        [[[UIAlertView alloc] initWithTitle:@"Pebble CommunicationFailed"
                                    message:error.localizedDescription
                                   delegate:self
                          cancelButtonTitle:@"Dismiss"
                          otherButtonTitles:nil] show];
    }
}

- (void)pebbleManagerDisconnectedFromWatch:(PCPebbleManager *)pebbleManager
{
    if (self.sendMessagesSwitch.isOn) {
        [UIAlertView displayAlertViewWithTitle:@"Pebble Disconnected" message:@"Reconnect a Pebble before continuing."];
        [self.sendMessagesSwitch setOn:NO animated:YES];
    }
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

    NSString *stationName = PebCiti.sharedInstance.stationList.closestStation.name;
    self.closestStationLabel.text = stationName;
    if (PebCiti.sharedInstance.pebbleManager.isSendingMessagesToPebble) {
        [PebCiti.sharedInstance.pebbleManager sendMessageToPebble:stationName];
    }
}

#pragma mark - <UIAlertViewDelegate>

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    self.errorAlertPresented = NO;
}

#pragma mark - Private

- (void)setupActivityIndicator
{
    self.activityIndicator.frame = self.view.frame;
    self.activityIndicator.color = [UIColor blackColor];
    self.activityIndicator.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];
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
