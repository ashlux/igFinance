
#import "AddTransactionViewController.h"


@implementation AddTransactionViewController

@synthesize symbolTextField;
@synthesize transactionTypeTextField;
@synthesize transactionDateTextField;
@synthesize sharesTextField;
@synthesize priceTextField;
@synthesize commissionTextField;
@synthesize notesTextView;

- (void)dealloc {
	[symbolTextField release];
	[transactionTypeTextField release];
	[transactionDateTextField release];
	[sharesTextField release];
	[priceTextField release];
	[commissionTextField release];
	[notesTextView release];
	
    [super dealloc];
}


@end
