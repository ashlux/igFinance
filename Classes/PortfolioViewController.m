

#import "PortfolioViewController.h"
#import "StockSummaryTableViewCell.h"

@implementation PortfolioViewController

@synthesize portfolioEntryTableView;
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
	
	self.title = [[portfolio title] stringValue];
	[self loadPortfolio :[portfolio positionURL]];
	
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[positionFeed entries] count] - 1;
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
	return cell;
}  

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath {
	UITableViewCell *cell = [self tableView: tableView cellForRowAtIndexPath: indexPath];
	return cell.bounds.size.height;
}	

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

// fetched position list successfully
- (void)positionFeedticket:(GDataServiceTicket *)ticket
       finishedWithFeed:(GDataFeedFinancePosition *)object {
	positionFeed = [object retain];
	[portfolioEntryTableView reloadData];
}

- (void)positionFeedticket:(GDataServiceTicket *)ticket
           failedWithError:(NSError *)error {
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
	[portfolio release];
	
    [super dealloc];
}

@end
