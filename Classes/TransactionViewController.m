
#import "TransactionViewController.h"
#import "TransactionTableViewCell.h"

@implementation TransactionViewController

@synthesize googleClientLogin;
@synthesize position;
@synthesize financeService;
@synthesize transactionFeed;

@synthesize activityIndicator;
@synthesize transactionTableView;

-(void)loadTransactions:(NSURL *) transactionUrl {
	GDataServiceGoogleFinance *service = [self financeService];
	[service fetchFinanceFeedWithURL:transactionUrl
							delegate:self
				   didFinishSelector:@selector(transactionFeedTicket:finishedWithEntries:)
					 didFailSelector:@selector(transactionFeedTicket:failedWithError:)];
}

- (void)transactionFeedTicket:(GDataServiceTicket *)ticket
          finishedWithEntries:(GDataFeedFinanceTransaction *)object {
	NSLog(@"%@", object);
	NSLog(@":::::%@", [object entries]);

	[activityIndicator stopAnimating];
	self.transactionFeed = object;
	[transactionTableView reloadData];
} 

- (void)transactionFeedTicket:(GDataServiceTicket *)ticket
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

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationItem.title = [[position symbol] symbol];
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
	[self loadTransactions :[position transactionURL]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {	
	return [[transactionFeed entries] count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *identifier = @"TransactionTableViewCell";
	
	TransactionTableViewCell *cell = (TransactionTableViewCell*) [tableView dequeueReusableCellWithIdentifier:identifier]; 
	if (cell == nil) {
		NSArray * templates = [[NSBundle mainBundle] loadNibNamed:@"TableViewCells" owner:self options:nil];  
		for (id template in templates) {  
			if ([template isKindOfClass:[TransactionTableViewCell class]]) {  
				cell = (TransactionTableViewCell *)template;
			}	
		}
	}	
	
	[cell updateWithTransaction:[[transactionFeed entries] objectAtIndex:indexPath.row]];
	[cell setEditing:YES];
	return cell;
}  

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath {
	UITableViewCell *cell = [self tableView: tableView cellForRowAtIndexPath: indexPath];
	return cell.bounds.size.height;
}	

- (void)dealloc {
	[activityIndicator release];
	[transactionTableView release];
	
    [super dealloc];
}


@end
