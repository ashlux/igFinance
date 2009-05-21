
#import "StockSummaryTableViewCell.h"

@implementation StockSummaryTableViewCell

@synthesize symbolLabel;
@synthesize lastPriceLabel;
@synthesize changeButton;
@synthesize position;

- (void)updateWithPosition:(GDataEntryFinancePosition *)positionArg {
	self.position = positionArg;
	[symbolLabel setText:[[positionArg symbol] symbol]];
	//lastPriceLabel.text = [[position positionData] va;
}

- (void)dealloc {
	[symbolLabel release];
	[lastPriceLabel release];
	[changeButton release];
	
    [super dealloc];
}

@end
