
#import "TransactionTableViewCell.h"

@implementation TransactionTableViewCell

@synthesize transactionTypeLabel;
@synthesize sharesLabel;
@synthesize priceLabel;
@synthesize dateLabel;
@synthesize noteLabel;

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
	[priceLabel setText:[NSString stringWithFormat:@"%@ %@", 
						[[price moneyWithPrimaryCurrency] amount], 
						[[price moneyWithPrimaryCurrency] currencyCode]]];
	
	[noteLabel setText:[transactionData notes]];
	[noteLabel setNumberOfLines:2];
	[noteLabel sizeToFit];
	
	NSLog(@"%@", [transactionData notes]);
	NSLog(@"%@", [noteLabel text]);
	
	NSDate *date = [[transactionData date] date];
	[dateLabel setText:[date descriptionWithCalendarFormat:@"%B %e, %Y" 
												  timeZone:nil 
													locale:[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]]];
}

- (void)dealloc {
	[transactionTypeLabel release];
	[sharesLabel release];
	[priceLabel release];
	[dateLabel release];
	[noteLabel release];

    [super dealloc];
}


@end
