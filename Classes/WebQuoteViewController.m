
#import "WebQuoteViewController.h"

@implementation WebQuoteViewController

@synthesize webView;
@synthesize position;

- (void)viewDidLoad {
    [super viewDidLoad];
	[self loadQuoteByPosition:position];
	[self.navigationItem setTitle:[NSString stringWithFormat:@"%@ Quote", [[position symbol] symbol]]];
}

- (void)loadQuoteByPosition:(GDataEntryFinancePosition *) positionArg {
	// http://finance.google.com/m/search?site=finance&q=GOOG
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://finance.google.com/m/search?site=finance&q=%@:%@",
									   [[positionArg symbol] exchange], [[positionArg symbol] symbol]]];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	[webView loadRequest:request];
	NSLog(@"%@", webView);
	
}

- (void)dealloc {
	[webView release];
    [super dealloc];
}

@end
