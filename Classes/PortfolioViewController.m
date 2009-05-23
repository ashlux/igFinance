

#import "PortfolioViewController.h"
#import "StockSummaryTableViewCell.h"
#import "TransactionViewController.h"

@implementation PortfolioViewController

@synthesize portfolioEntryTableView;
@synthesize activityIndicator;
@synthesize googleClientLogin;
@synthesize portfolio;
@synthesize positionFeed;
@synthesize financeService;

-(void)loadPortfolio:(NSURL *) positionUrl {
	GDataServiceGoogleFinance *service = [self financeService];		
	[service fetchFinanceFeedWithURL:positionUrl
							 delegate:self
				   didFinishSelector:@selector(positionFeedticket:finishedWithFeed:)
					 didFailSelector:@selector(positionFeedticket:failedWithError:)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationItem.title = [[portfolio title] stringValue];
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

- (void)dealloc {
	[portfolioEntryTableView release];
	[activityIndicator release];
	[portfolio release];
	
    [super dealloc];
}

@end
