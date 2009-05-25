
#import <UIKit/UIKit.h>
#import "AbstractTextEditingUITableViewController.h"

@interface AddTransactionViewController : AbstractTextEditingUITableViewController {
	IBOutlet UITextField *symbolTextField;
	IBOutlet UITextField *transactionTypeTextField;
	IBOutlet UITextField *transactionDateTextField;
	IBOutlet UITextField *sharesTextField;
	IBOutlet UITextField *priceTextField;
	IBOutlet UITextField *commissionTextField;
	IBOutlet UITextView *notesTextView;
}

@property (nonatomic, retain) IBOutlet UITextField *symbolTextField;
@property (nonatomic, retain) IBOutlet UITextField *transactionTypeTextField;
@property (nonatomic, retain) IBOutlet UITextField *transactionDateTextField;
@property (nonatomic, retain) IBOutlet UITextField *sharesTextField;
@property (nonatomic, retain) IBOutlet UITextField *priceTextField;
@property (nonatomic, retain) IBOutlet UITextField *commissionTextField;
@property (nonatomic, retain) IBOutlet UITextView *notesTextView;

@end
