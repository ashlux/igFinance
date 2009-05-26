

#import "PortfolioViewController.h"
#import "StockSummaryTableViewCell.h"
#import "TransactionViewController.h"
#import "WebQuoteViewController.h"
#import "AddTransactionViewController.h"

@implementation PortfolioViewController

@synthesize portfolioEntryTableView;
@synthesize activityIndicator;
@synthesize myTabBar;
@synthesize googleClientLogin;
@synthesize portfolio;
@synthesize positionFeed;
@synthesize financeService;

-(void)loadPortfolio:(NSURL *) positionUrl {
	[self.activityIndicator startAnimating];	
	GDataServiceGoogleFinance *service = [self financeService];		
	[service fetchFinanceFeedWithURL:positionUrl
							 delegate:self
				   didFinishSelector:@selector(positionFeedticket:finishedWithFeed:)
					 didFailSelector:@selector(positionFeedticket:failedWithError:)];
}

- (void) loadView {
	[super loadView];
	
	// set navigation bar title
	self.navigationItem.title = [[portfolio title] stringValue];
	
	// add activity indicator to navigation bar
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
	
	// disable main tableview from scrolling, want sub-tableview to scroll instead
	((UITableView*) self.view).scrollEnabled = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self loadPortfolio :[portfolio positionURL]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {	
	return [[positionFeed entries] count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *identifier = @"StockSummaryTableViewCell";
	
	StockSummaryTableViewCell *cell = (StockSummaryTableViewCell*) [tableView dequeueReusableCellWithIdentifier:identifier]; 
	if (cell == nil) {
		NSArray * templates = [[NSBundle mainBundle] loadNibNamed:@"TableViewCells" owner:self options:nil];  
		for (id template in templates) {  
			if ([template isKindOfClass:[StockSummaryTableViewCell class]]) {  
				cell = (StockSummaryTableViewCell *)template;
			}	
		}
	}	
	
	[cell updateWithPosition:[[positionFeed entries] objectAtIndex:indexPath.row]];
	[cell setEditing:YES];
	return cell;
}  

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath {
	UITableViewCell *cell = [self tableView: tableView cellForRowAtIndexPath: indexPath];
	return cell.bounds.size.height;
}	

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	WebQuoteViewController *aView = [[WebQuoteViewController alloc] 
									 initWithNibName:@"WebQuoteViewController" bundle:[NSBundle mainBundle]];
	//[aView loadQuoteByPosition:[[positionFeed entries] objectAtIndex:indexPath.row]];
	aView.position = [[positionFeed entries] objectAtIndex:indexPath.row];
	[self.navigationController pushViewController:aView animated:YES];
	[aView release];
}
		
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	TransactionViewController *aView = [[TransactionViewController alloc] 
									  initWithNibName:@"TransactionViewController" bundle:[NSBundle mainBundle]];
	aView.googleClientLogin = googleClientLogin;
	aView.financeService = [self financeService];
	aView.position = [[[self positionFeed] entries] objectAtIndex:indexPath.row];
	[self.navigationController pushViewController:aView animated:YES];
	[aView release];
}


// fetched position list successfully
- (void)positionFeedticket:(GDataServiceTicket *)ticket
       finishedWithFeed:(GDataFeedFinancePosition *)object {
	[activityIndicator stopAnimating];
	positionFeed = [object retain];
	[portfolioEntryTableView reloadData];
}

- (void)positionFeedticket:(GDataServiceTicket *)ticket
           failedWithError:(NSError *)error {
	[activityIndicator stopAnimating];
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

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
	if (item.tag == 97) { // add transaction
		AddTransactionViewController *aView = [[AddTransactionViewController alloc] 
											 initWithNibName:@"AddTransactionViewController" bundle:[NSBundle mainBundle]];
		aView.googleClientLogin = self.googleClientLogin;
		aView.financeService = [self financeService];
		aView.portfolio = [self portfolio];
		[self.navigationController pushViewController:aView animated:YES];
		[aView release];
	} else if (item.tag == 98) { // refresh
		[self loadPortfolio:[portfolio positionURL]];
	}
	
	
	[myTabBar setSelectedItem:nil];
}

- (void)dealloc {
	[portfolioEntryTableView release];
	[activityIndicator release];
	[portfolio release];
	[myTabBar release];
	
    [super dealloc];
}

@end
