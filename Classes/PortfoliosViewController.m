
#import "PortfoliosViewController.h"
#import "PortfolioViewController.h"
#import "AddPortfolioViewController.h"

@implementation PortfoliosViewController

@synthesize googleClientLogin;
@synthesize uitableView;
@synthesize gDataFeedFinancePortfolio;
@synthesize activityIndicator;
@synthesize myTabBar;

- (GDataServiceGoogleFinance*) financeService {
	static  GDataServiceGoogleFinance *service = nil;
	if (!service) {
		service = [[GDataServiceGoogleFinance alloc] init];
		[service setShouldCacheDatedData:YES];
		[service setServiceShouldFollowNextLinks:YES];
		 // YES means I can't use entries directly for updates, even if it improves performance.
		[service setShouldServiceFeedsIgnoreUnknowns:NO];
	}
	
	[service setUserAgent:@"ashlux-igFinance-0.1"];
	[service setUserCredentialsWithUsername:[googleClientLogin username] 
								   password:[googleClientLogin password]];
	return service;
}

-(void)loadPortfolios {
	[self.activityIndicator startAnimating];
	NSLog(@"Getting all of the user's portfolios for %@.", [googleClientLogin username]);
	GDataServiceGoogleFinance *service = [self financeService];		
	[GDataHTTPFetcher setIsLoggingEnabled:YES];
	NSURL *feedURL = [NSURL URLWithString:kGDataGoogleFinanceDefaultPortfoliosFeed];
	[service fetchFinanceFeedWithURL:feedURL
							delegate:self
				   didFinishSelector:@selector(portfolioFeedTicket:finishedWithFeed:)
					 didFailSelector:@selector(portfolioFeedTicket:failedWithError:)];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	// Set navigation title and start activity indicator
	self.navigationItem.title = @"Portfolios";
	self.activityIndicator = [[UIActivityIndicatorView alloc] 
							  initWithFrame:CGRectMake(0.0, 0.0, 25.0, 25.0)];
	[self.activityIndicator sizeToFit];
	self.activityIndicator.autoresizingMask =
		(UIViewAutoresizingFlexibleLeftMargin |
		 UIViewAutoresizingFlexibleRightMargin |
		 UIViewAutoresizingFlexibleTopMargin |
		 UIViewAutoresizingFlexibleBottomMargin);
	UIBarButtonItem *loadingView = [[UIBarButtonItem alloc] 
									initWithCustomView:self.activityIndicator];
	loadingView.target = self;
	self.navigationItem.rightBarButtonItem = loadingView;
	[self.activityIndicator startAnimating];

	// disable main tableview from scrolling, want sub-tableview to scroll instead
	((UITableView*) self.view).scrollEnabled = NO;
	
	[self loadPortfolios];
}

- (void)portfolioFeedTicket:(GDataServiceTicket *)ticket
           finishedWithFeed:(GDataFeedFinancePortfolio *)object {
	[self.activityIndicator stopAnimating];
	gDataFeedFinancePortfolio = [object retain];
	[uitableView reloadData];
}

- (void)portfolioFeedTicket:(GDataServiceTicket *)ticket
            failedWithError:(NSError *)error {
	[self.activityIndicator stopAnimating];
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Error code %d", [error code]]
							message:[NSString stringWithFormat:
									 @"Authentication failed: Perhaps wrong username/password combination or no internet connection?"]
							delegate:nil
							cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [alertView show];
    [alertView release];
	
	NSLog(@"%@", ticket);
	NSLog(@"%@", error);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[gDataFeedFinancePortfolio entries] count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    	
	GDataEntryFinancePortfolio *portfolio = [[gDataFeedFinancePortfolio entries] objectAtIndex:indexPath.row];
	cell.text = [[portfolio title] stringValue];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	PortfolioViewController *aView = [[PortfolioViewController alloc] 
									  initWithNibName:@"PortfolioViewController" bundle:[NSBundle mainBundle]];
	aView.googleClientLogin = googleClientLogin;
	aView.financeService = [self financeService];
	aView.portfolio = [[[self gDataFeedFinancePortfolio] entries] objectAtIndex:indexPath.row];
	[self.navigationController pushViewController:aView animated:YES];
	[aView release];
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
	if (item.tag == 99) { // add
		AddPortfolioViewController *aView = [[AddPortfolioViewController alloc] 
											 initWithNibName:@"AddPortfolioViewController" bundle:[NSBundle mainBundle]];
		aView.googleClientLogin = self.googleClientLogin;
		aView.financeService = [self financeService];
		[self.navigationController pushViewController:aView animated:YES];
		[aView release];
	} else if (item.tag == 98) { // refresh
		[self loadPortfolios];
	}
	

	[myTabBar setSelectedItem:nil];
}

- (void)viewWillAppear:(BOOL)animated { 
	[super viewWillAppear:animated];
	
	[self loadPortfolios];
}

- (void)dealloc {
	[uitableView release];
	[activityIndicator release];
	[myTabBar release];

    [super dealloc];
}


@end

