
#import <UIKit/UIKit.h>
#import "GDataFinance.h"

@interface TransactionTableViewCell : UITableViewCell {
	IBOutlet UILabel *transactionTypeLabel;
	IBOutlet UILabel *sharesLabel;
	IBOutlet UILabel *priceLabel;
	IBOutlet UILabel *commissionLabel;
	IBOutlet UILabel *dateLabel;
	IBOutlet UITextView *noteTextView;
}

@property (nonatomic, retain) IBOutlet UILabel *transactionTypeLabel;
@property (nonatomic, retain) IBOutlet UILabel *sharesLabel;
@property (nonatomic, retain) IBOutlet UILabel *priceLabel;
@property (nonatomic, retain) IBOutlet UILabel *commissionLabel;
@property (nonatomic, retain) IBOutlet UILabel *dateLabel;
@property (nonatomic, retain) IBOutlet UITextView *noteTextView;

- (void)updateWithTransaction:(GDataEntryFinanceTransaction *)transaction;

@end
