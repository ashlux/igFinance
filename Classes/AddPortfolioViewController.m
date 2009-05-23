
#import "AddPortfolioViewController.h"

@implementation AddPortfolioViewController

@synthesize googleClientLogin;
@synthesize financeService;

@synthesize portfolioNameTextField;
@synthesize activityIndicator;

- (void)portfolioEntryTicket:(GDataServiceTicket *)ticket
           finishedWithFeed:(GDataEntryFinancePortfolio *)object {
	[self.activityIndicator stopAnimating];
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)portfolioEntryTicket:(GDataServiceTicket *)ticket
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

- (IBAction)addPortfolio {
	[self.activityIndicator startAnimating];
	NSLog(@"Adding portfolio %@ for %@.", portfolioNameTextField.text, [googleClientLogin username]);
	NSURL *feedURL = [NSURL URLWithString:kGDataGoogleFinanceDefaultPortfoliosFeed];
	GDataEntryFinancePortfolio *newPortfolio = [[GDataEntryFinancePortfolio alloc] init];
	[[newPortfolio portfolioData] init];
	[newPortfolio setTitleWithString:@"ASDFDSF"];
	[newPortfolio setPortfolioData:[[GDataPortfolioData alloc] init]];
	NSLog(@"%@", newPortfolio);
    [financeService fetchEntryByInsertingEntry:newPortfolio
									forFeedURL:feedURL
									  delegate:self
							 didFinishSelector:@selector(portfolioEntryTicket:finishedWithFeed:)
							   didFailSelector:@selector(portfolioEntryTicket:failedWithError:)];
}

- (void)viewDidLoad {
    [super viewDidLoad];

	self.navigationItem.title = @"New portfolio";
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
	[self.activityIndicator stopAnimating];
	
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[activityIndicator release];
	[portfolioNameTextField release];
	
    [super dealloc];
}


@end