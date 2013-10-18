#import "PCStationsViewController.h"

@interface PCStationsViewController ()
@property (nonatomic, weak, readwrite) id<PCStationsViewControllerDelegate> delegate;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) NSArray *stations;
@end

@implementation PCStationsViewController

- (instancetype)init
{
    @throw @"Use initWithDelegate:";
}

- (instancetype)initWithDelegate:(id<PCStationsViewControllerDelegate>)delegate
{
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)loadView
{
    [super loadView];

    self.title = @"Stations";
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonWasTapped)];
    self.navigationItem.leftBarButtonItem = doneButton;

    [self requestStationList];
}

#pragma mark - Private

- (void)doneButtonWasTapped
{
    [self.delegate stationsViewControllerIsDone];
}

- (void)requestStationList
{
    NSURL *URL = [NSURL URLWithString:@"http://citibikenyc.com/stations/json"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [connection start];
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.stations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"CELL"];
    }
    cell.textLabel.text = self.stations[indexPath.row][@"stationName"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [self.stations[indexPath.row][@"availableDocks"] integerValue]];
    return cell;
}

#pragma mark - <NSURLConnectionDataDelegate>

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (!self.data) {
        self.data = [[NSMutableData alloc] init];
    }
    [self.data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:self.data options:0 error:nil];
    self.stations = json[@"stationBeanList"];

    [self.tableView reloadData];
}

@end
