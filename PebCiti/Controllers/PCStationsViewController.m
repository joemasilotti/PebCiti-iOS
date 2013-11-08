#import "PCStationsViewController.h"
#import "UIAlertView+PebCiti.h"
#import "PCStation.h"
#import "PebCiti.h"

@interface PCStationsViewController ()
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) NSArray *stations;
@end

@implementation PCStationsViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    PebCiti.sharedInstance.stationList.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    PebCiti.sharedInstance.stationList.delegate = nil;
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return PebCiti.sharedInstance.stationList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StationCellIdentifier"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"StationCellIdentifier"];
    }

    PCStation *station = PebCiti.sharedInstance.stationList[indexPath.row];
    cell.textLabel.text = station.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)station.docksAvailable];
    return cell;
}

#pragma mark - <PCStationListDelegate>

- (void)stationListWasUpdated:(PCStationList *)stationList
{
    [self.tableView reloadData];
}

@end
