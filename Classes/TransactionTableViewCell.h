
#import <UIKit/UIKit.h>
#import "GDataFinance.h"

@interface TransactionTableViewCell : UITableViewCell {
	IBOutlet UILabel *transactionTypeLabel;
	IBOutlet UILabel *sharesLabel;
	IBOutlet UILabel *priceLabel;
	IBOutlet UILabel *dateLabel;
	IBOutlet UILabel *noteLabel;
}

@property (nonatomic, retain) IBOutlet UILabel *transactionTypeLabel;
@property (nonatomic, retain) IBOutlet UILabel *sharesLabel;
@property (nonatomic, retain) IBOutlet UILabel *priceLabel;
@property (nonatomic, retain) IBOutlet UILabel *dateLabel;
@property (nonatomic, retain) IBOutlet UILabel *noteLabel;

- (void)updateWithTransaction:(GDataEntryFinanceTransaction *)transaction;

@end
