
#import "StockSummaryTableViewCell.h"

@implementation StockSummaryTableViewCell

@synthesize symbolLabel;
@synthesize fullNameLabel;
@synthesize sharesLabel;

@synthesize position;

- (void)updateWithPosition:(GDataEntryFinancePosition *)positionArg {
	self.position = positionArg;
	NSString *symbol = [NSString stringWithFormat:@"%@ (%@)", 
						[[position symbol] symbol], [[position symbol] exchange]];
	[symbolLabel setText:symbol];
	[fullNameLabel setText:[[position symbol] fullName]];
	NSNumber *shares = [[position positionData] shares];
	if (![shares isEqualToNumber:[NSNumber numberWithInt:0]]) {
		[sharesLabel setText:[shares stringValue]];
	} else {
		[sharesLabel setText:@""];
	}
}

- (void)dealloc {
	[symbolLabel release];
	[fullNameLabel release];
	[sharesLabel release];
	
    [super dealloc];
}

@end
