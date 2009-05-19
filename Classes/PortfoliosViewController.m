
#import "PortfoliosViewController.h"

@implementation PortfoliosViewController

@synthesize googleClientLogin;
@synthesize uitableView;
@synthesize gDataFeedFinancePortfolio;

- (GDataServiceGoogleFinance*) financeService {
	static  GDataServiceGoogleFinance *service = nil;
	if (!service) {
		service = [[GDataServiceGoogleFinance alloc] init];
		[service setShouldCacheDatedData:YES];
		[service setServiceShouldFollowNextLinks:YES];
		[service setShouldServiceFeedsIgnoreUnknowns:YES];
	}
	
	[service setUserAgent:@"ashlux-igFinance-0.1"];
	[service setUserCredentialsWithUsername:[googleClientLogin username] 
								   password:[googleClientLogin password]];
	return service;
}

-(void)loadPortfolios {
	NSLog(@"Getting all of the user's portfolios for %@.", [googleClientLogin username]);
	GDataServiceGoogleFinance *service = [self financeService];		
	NSURL *feedURL = [NSURL URLWithString:kGDataGoogleFinanceDefaultPortfoliosFeed];
	[service fetchFinanceFeedWithURL:feedURL
							delegate:self
				   didFinishSelector:@selector(portfolioFeedTicket:finishedWithFeed:)
					 didFailSelector:@selector(portfolioFeedTicket:failedWithError:)];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	super.title = @"Portfolios";
	[self loadPortfolios];
}

- (void)portfolioFeedTicket:(GDataServiceTicket *)ticket
           finishedWithFeed:(GDataFeedFinancePortfolio *)object {
	gDataFeedFinancePortfolio = [object retain];
	[uitableView reloadData];
	NSLog(@"UITableView::::::%@", uitableView);
	
	for (int i = 0; i < [[object entries] count]; ++i) {
		NSLog(@"Portfolio%d:::::::::>>>>>>>>> %@", i, [[gDataFeedFinancePortfolio entries] objectAtIndex:i]);
	}	
}

- (void)portfolioFeedTicket:(GDataServiceTicket *)ticket
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSLog(@"Number of rows in section: %d", [[gDataFeedFinancePortfolio entries] count]);
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
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


- (void)dealloc {
	[uitableView release];
    [super dealloc];
}


@end

