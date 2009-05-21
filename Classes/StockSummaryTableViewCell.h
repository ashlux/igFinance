
#import <UIKit/UIKit.h>
#import "GDataFinance.h"

@interface StockSummaryTableViewCell : UITableViewCell {
	IBOutlet UILabel *symbolLabel;
	IBOutlet UILabel *lastPriceLabel;
	IBOutlet UIButton *changeButton;
	
	GDataEntryFinancePosition *position;
}

@property (nonatomic, retain) IBOutlet UILabel *symbolLabel;
@property (nonatomic, retain) IBOutlet UILabel *lastPriceLabel;
@property (nonatomic, retain) IBOutlet UIButton *changeButton;
@property (nonatomic, retain) GDataEntryFinancePosition *position;

- (void)updateWithPosition:(GDataEntryFinancePosition *)positionArg;

@end
