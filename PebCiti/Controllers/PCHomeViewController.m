#import <PebbleKit/PebbleKit.h>
#import "PCHomeViewController.h"
#import "UIAlertView+PebCiti.h"
#import "PCPebbleCentral.h"
#import "PCPebbleManager.h"
#import "PCStation.h"
#import "PebCiti.h"

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

    self.closestStationLabel.text = PebCiti.sharedInstance.stationList.closestStation.name;

    self.activityIndicator.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    PBWatch *connectedWatch = PCPebbleCentral.defaultCentral.lastConnectedWatch;
    self.connectedPebbleLabel.text = connectedWatch.isConnected ? connectedWatch.name : @"";

    [PebCiti.sharedInstance.locationManager startUpdatingLocation];
}

- (IBAction)connectToPebbleButtonWasTapped:(UIButton *)connectToPebbleButton
{
    [self.activityIndicator startAnimating];
    [PebCiti.sharedInstance.pebbleManager connectToPebble];
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
    [PebCiti.sharedInstance.pebbleManager sendMessageToPebble:stationName];
}

#pragma mark - Private

- (void)setupActivityIndicator
{
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    activityIndicator.color = [UIColor blackColor];
    activityIndicator.hidesWhenStopped = YES;
    [self.view addSubview:activityIndicator];
    self.activityIndicator = activityIndicator;
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
