#import <PebbleKit/PebbleKit.h>
#import "PCHomeViewController.h"
#import "UIAlertView+PebCiti.h"
#import "PCPebbleCentral.h"
#import "PCPebbleManager.h"
#import "PCStation.h"
#import "PebCiti.h"

@interface PCHomeViewController ()
@property (nonatomic, readwrite) PCFocusType focusType;
@property (nonatomic, strong) PCStation *previousClosestStation;
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

    NSString *closestStationName;
    if (self.focusType == PCFocusTypeBike) {
       closestStationName = PebCiti.sharedInstance.stationList.closestStationWithAvailableBike.name;
    } else {
        closestStationName = PebCiti.sharedInstance.stationList.closestStationWithOpenDock.name;
    }
    self.closestStationLabel.text = closestStationName ? closestStationName : @"";

    BOOL isSendingMessagesToPebble = PebCiti.sharedInstance.pebbleManager.isSendingMessagesToPebble;
    self.sendMessagesSwitch.on = isSendingMessagesToPebble;

    self.vibratePebbleLabel.enabled = isSendingMessagesToPebble;
    self.vibratePebbleSwitch.enabled = isSendingMessagesToPebble;
    self.vibratePebbleSwitch.on = PebCiti.sharedInstance.pebbleManager.isVibratingPebble;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [PebCiti.sharedInstance.locationManager startUpdatingLocation];
    [self setupActivityIndicator];
}

- (IBAction)focusSegmentControlValueWasChanged:(UISegmentedControl *)focusSegmentControl
{
    self.focusType = focusSegmentControl.selectedSegmentIndex;
    NSString *focus = focusSegmentControl.selectedSegmentIndex == PCFocusTypeDock ? @"Closest Open Dock:" : @"Closest Available Bike:";
    [PebCiti.sharedInstance.pebbleManager changeFocusTo:focus];
}

- (IBAction)sendMessagesSwitchWasToggled:(UISwitch *)sendMessagesSwitch
{
    if (sendMessagesSwitch.isOn) {
        [self.activityIndicator startAnimating];
    } else {
        [self.vibratePebbleSwitch setOn:NO animated:YES];
        self.vibratePebbleLabel.enabled = NO;
        self.vibratePebbleSwitch.enabled = NO;
        PebCiti.sharedInstance.pebbleManager.vibratePebble = NO;
    }
    PebCiti.sharedInstance.pebbleManager.sendMessagesToPebble = sendMessagesSwitch.isOn;
    self.previousClosestStation = nil;
}

- (IBAction)vibratePebbleSwitchWasToggled:(UISwitch *)vibratePebbleSwitch
{
    PebCiti.sharedInstance.pebbleManager.vibratePebble = vibratePebbleSwitch.isOn;
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
    self.vibratePebbleLabel.enabled = YES;
    self.vibratePebbleSwitch.enabled = YES;
}

- (void)pebbleManagerFailedToConnectToWatch:(PBWatch *)watch
{
    [self.activityIndicator stopAnimating];
    [self.sendMessagesSwitch setOn:NO animated:YES];
    self.previousClosestStation = nil;
    [UIAlertView displayAlertViewWithTitle:@"No Pebble Connected" message:@"Connect a Pebble that supports app messages before continuing."];
}

- (void)pebbleManager:(PCPebbleManager *)pebbleManager receivedError:(NSError *)error
{
    [self.sendMessagesSwitch setOn:NO animated:YES];
    [self.vibratePebbleSwitch setOn:NO animated:YES];
    self.vibratePebbleLabel.enabled = NO;
    self.vibratePebbleSwitch.enabled = NO;
    self.previousClosestStation = nil;

    if (!self.isErrorAlertPresented) {
        self.errorAlertPresented = YES;
        [UIAlertView displayAlertViewWithTitle:@"Pebble Communication Failed" message:error.localizedDescription delegate:self];
    }
}

- (void)pebbleManagerDisconnectedFromWatch:(PCPebbleManager *)pebbleManager
{
    if (self.sendMessagesSwitch.isOn) {
        [UIAlertView displayAlertViewWithTitle:@"Pebble Disconnected" message:@"Reconnect a Pebble before continuing."];
        [self.sendMessagesSwitch setOn:NO animated:YES];
    }
    [self.vibratePebbleSwitch setOn:NO animated:YES];
    self.vibratePebbleLabel.enabled = NO;
    self.vibratePebbleSwitch.enabled = NO;
    self.previousClosestStation = nil;
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
    self.currentLocationLabel.text = [NSString stringWithFormat:@"%f, %f", lastLocation.coordinate.latitude, lastLocation.coordinate.longitude];

    PCStation *closestStation;
    if (self.focusType == PCFocusTypeBike) {
        closestStation = PebCiti.sharedInstance.stationList.closestStationWithAvailableBike;
    } else {
        closestStation = PebCiti.sharedInstance.stationList.closestStationWithOpenDock;
    }
    self.closestStationLabel.text = closestStation.name;

    if (PebCiti.sharedInstance.pebbleManager.isSendingMessagesToPebble && self.previousClosestStation.stationID != closestStation.stationID) {
        [PebCiti.sharedInstance.pebbleManager sendMessageToPebble:closestStation.name];
        self.previousClosestStation = closestStation;
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
