#import "PCStationsViewController.h"
#import "UIAlertView+PebCiti.h"
#import "PCAnalytics.h"
#import "PCStation.h"
#import "PebCiti.h"

@interface PCStationsViewController ()
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) NSArray *stations;
@property (nonatomic) BOOL showOpenDocks;
@end

@implementation PCStationsViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [PebCiti.sharedInstance.analytics setActiveScreenName:@"Stations Screen"];
    self.stations = [PebCiti.sharedInstance.stationList.stations copy];
    self.showOpenDocks = YES;
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.stations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StationCellIdentifier"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"StationCellIdentifier"];
    }

    PCStation *station = self.stations[indexPath.row];
    cell.textLabel.text = station.name;
    if (self.showOpenDocks) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)station.docksAvailable];
    } else {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)station.bikesAvailable];
    }
    return cell;
}

- (IBAction)sortButtonWasTapped:(UIBarButtonItem *)sender
{
    self.showOpenDocks = !self.showOpenDocks;
    self.sortButton.title = self.showOpenDocks ? @"Docks" : @"Bikes";
    [self.tableView reloadData];
}

@end
