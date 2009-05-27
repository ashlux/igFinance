
#import "AddPortfolioViewController.h"

@implementation AddPortfolioViewController

@synthesize googleClientLogin;
@synthesize financeService;

@synthesize portfolioNameTextField;
@synthesize defaultCurrencyTextField;
@synthesize activityIndicator;

@synthesize currencyPicker;

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

- (IBAction)changeDefaultCurrency {
	if (currencyPicker == nil) {
		currencyPicker = [[CurrencyPickerViewController alloc] 
														initWithNibName:@"CurrencyPickerViewController" bundle:[NSBundle mainBundle]];
	}
	currencyPicker.selectedCurrency = defaultCurrencyTextField.text;
	[self.navigationController pushViewController:currencyPicker animated:YES];
	[defaultCurrencyTextField setText:[currencyPicker selectedCurrency]];
}

- (IBAction)cancel {
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)addPortfolio {
	[self.activityIndicator startAnimating];
	NSLog(@"Adding portfolio %@ for %@.", portfolioNameTextField.text, [googleClientLogin username]);
	NSURL *feedURL = [NSURL URLWithString:kGDataGoogleFinanceDefaultPortfoliosFeed];
	GDataEntryFinancePortfolio *newPortfolio = [GDataEntryFinancePortfolio portfolioEntry];
	[newPortfolio setTitleWithString:portfolioNameTextField.text];
	[newPortfolio setPortfolioData:[GDataPortfolioData portfolioData]];
	[[newPortfolio portfolioData] setCurrencyCode:defaultCurrencyTextField.text];
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

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	// returned from sub-viewcontroller
	if (currencyPicker != nil) {
		[self.defaultCurrencyTextField setText:[currencyPicker selectedCurrency]];
	}
}

- (void)dealloc {
	[activityIndicator release];
	[defaultCurrencyTextField release];
	[portfolioNameTextField release];
	
	[currencyPicker release];
	
    [super dealloc];
}


@end
