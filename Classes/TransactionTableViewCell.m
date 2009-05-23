
#import "TransactionTableViewCell.h"

@implementation TransactionTableViewCell

@synthesize transactionTypeLabel;
@synthesize sharesLabel;
@synthesize priceLabel;
@synthesize commissionLabel;
@synthesize dateLabel;
@synthesize noteTextView;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
    }
    return self;
}

- (void)updateWithTransaction:(GDataEntryFinanceTransaction *)transaction {
	GDataFinanceTransactionData *transactionData = [transaction transactionData];
	
	[transactionTypeLabel setText:[transactionData type]];

	[sharesLabel setText:[NSString stringWithFormat:@"%@ shares", [transactionData shares]]];
	
	GDataPrice *price = [transactionData price];
	[priceLabel setText:[NSString stringWithFormat:@"Price: %@ %@", 
						 [[price moneyWithPrimaryCurrency] amount], 
						 [[price moneyWithPrimaryCurrency] currencyCode]]];

	GDataCommission *commission = [transactionData commission];
	[commissionLabel setText:[NSString stringWithFormat:@"Commission: %@ %@", 
						 [[commission moneyWithPrimaryCurrency] amount], 
						 [[commission moneyWithPrimaryCurrency] currencyCode]]];
	
	[noteTextView setText:[transactionData notes]];
	[noteTextView setFont:[UIFont systemFontOfSize:10]];
	
	NSDate *date = [[transactionData date] date];
	[dateLabel setText:[date descriptionWithCalendarFormat:@"%B %e, %Y" 
												  timeZone:nil 
													locale:[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]]];
}

- (void)dealloc {
	[transactionTypeLabel release];
	[sharesLabel release];
	[priceLabel release];
	[commissionLabel release];
	[dateLabel release];
	[noteTextView release];

    [super dealloc];
}


@end
