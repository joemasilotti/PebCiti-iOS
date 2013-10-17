#import "PCStationsViewController.h"

@interface PCStationsViewController ()
@property (nonatomic, weak, readwrite) id<PCStationsViewControllerDelegate> delegate;
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

@end
