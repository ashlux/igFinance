
#import <UIKit/UIKit.h>
#import "AbstractTextEditingUITableViewController.h"
#import "GoogleClientLogin.h"
#import "GDataFinance.h"

@interface AddTransactionViewController : AbstractTextEditingUITableViewController {
	GoogleClientLogin *googleClientLogin;
	GDataServiceGoogleFinance *financeService;
	GDataEntryFinancePortfolio *portfolio;
	
	IBOutlet UITextField *symbolTextField;
	IBOutlet UITextField *transactionTypeTextField;
	IBOutlet UITextField *transactionDateTextField;
	IBOutlet UITextField *sharesTextField;
	IBOutlet UITextField *priceTextField;
	IBOutlet UITextField *priceCurrencyTextField;
	IBOutlet UITextField *commissionTextField;
	IBOutlet UITextField *commissionCurrencyTextField;
	IBOutlet UITextView *notesTextView;
	IBOutlet UIActivityIndicatorView *activityIndicator;
}

@property (nonatomic, retain) GoogleClientLogin *googleClientLogin;
@property (nonatomic, retain) GDataServiceGoogleFinance *financeService;
@property (nonatomic, retain) GDataEntryFinancePortfolio *portfolio;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;

@property (nonatomic, retain) IBOutlet UITextField *symbolTextField;
@property (nonatomic, retain) IBOutlet UITextField *transactionTypeTextField;
@property (nonatomic, retain) IBOutlet UITextField *transactionDateTextField;
@property (nonatomic, retain) IBOutlet UITextField *sharesTextField;
@property (nonatomic, retain) IBOutlet UITextField *priceTextField;
@property (nonatomic, retain) IBOutlet UITextField *priceCurrencyTextField;
@property (nonatomic, retain) IBOutlet UITextField *commissionTextField;
@property (nonatomic, retain) IBOutlet UITextField *commissionCurrencyTextField;
@property (nonatomic, retain) IBOutlet UITextView *notesTextView;

- (IBAction)cancel;
- (IBAction)addTransaction;

@end
