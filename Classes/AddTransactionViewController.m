
#import "AddTransactionViewController.h"


@implementation AddTransactionViewController

@synthesize googleClientLogin;
@synthesize financeService;
@synthesize portfolio;
@synthesize activityIndicator;

@synthesize symbolTextField;
@synthesize transactionTypeTextField;
@synthesize transactionDateTextField;
@synthesize sharesTextField;
@synthesize priceTextField;
@synthesize priceCurrencyTextField;
@synthesize commissionTextField;
@synthesize commissionCurrencyTextField;
@synthesize notesTextView;

-(void) loadView {
	[super loadView];
	
	self.navigationItem.title = @"New transaction";
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

- (IBAction)cancel {
	// remove self
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)portfolioEntryTicket:(GDataServiceTicket *)ticket
			finishedWithFeed:(GDataEntryFinancePortfolio *)object {
	[self.activityIndicator stopAnimating];
	[[self.navigationController popViewControllerAnimated:YES] viewWillAppear:YES];	
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

- (IBAction)addTransaction {
	[self.activityIndicator startAnimating];
	NSLog(@"Adding transaction to %@.", [portfolio title]);
	NSURL *feedURL = [NSURL URLWithString:kGDataGoogleFinanceDefaultPortfoliosFeed];
	GDataEntryFinanceTransaction *newTransaction = [GDataEntryFinanceTransaction transactionEntry];
	[newTransaction setTransactionData:[GDataFinanceTransactionData transactionDataWithType:transactionTypeTextField.text]];
    [financeService fetchEntryByInsertingEntry:newTransaction
									forFeedURL:feedURL
									  delegate:self
							 didFinishSelector:@selector(transactionEntryTicket:finishedWithFeed:)
							   didFailSelector:@selector(transactionEntryTicket:failedWithError:)];
}

- (void)dealloc {
	[symbolTextField release];
	[transactionTypeTextField release];
	[transactionDateTextField release];
	[sharesTextField release];
	[priceTextField release];
	[priceCurrencyTextField release];
	[commissionTextField release];
	[commissionCurrencyTextField release];
	[notesTextView release];
	
    [super dealloc];
}


@end
