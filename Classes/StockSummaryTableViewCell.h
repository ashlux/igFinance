
#import <UIKit/UIKit.h>
#import "GDataFinance.h"

@interface StockSummaryTableViewCell : UITableViewCell {
	IBOutlet UILabel *symbolLabel;
	IBOutlet UILabel *fullNameLabel;
	IBOutlet UILabel *sharesLabel;
	
	GDataEntryFinancePosition *position;
}

@property (nonatomic, retain) IBOutlet UILabel *symbolLabel;
@property (nonatomic, retain) IBOutlet UILabel *fullNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *sharesLabel;

@property (nonatomic, retain) GDataEntryFinancePosition *position;

- (void)updateWithPosition:(GDataEntryFinancePosition *)positionArg;

@end
