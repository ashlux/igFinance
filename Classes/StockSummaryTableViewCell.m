
#import "StockSummaryTableViewCell.h"

@implementation StockSummaryTableViewCell

@synthesize symbolLabel;
@synthesize lastPriceLabel;
@synthesize changeButton;
@synthesize position;

- (void)viewDidLoad {
    [super viewDidLoad];
//	self.title = @"Account Details";
	
	[self getDefaults];
}

- (void)updateWithPosition:(GDataEntryFinancePosition *)positionArg {
	self.position = position;
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
