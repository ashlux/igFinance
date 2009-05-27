
#import <UIKit/UIKit.h>
#import "AbstractTextEditingUITableViewController.h"
#import "GoogleClientLogin.h"
#import "GDataFinance.h"
#import "CurrencyPickerViewController.h"

@interface AddPortfolioViewController : AbstractTextEditingUITableViewController {
	GoogleClientLogin *googleClientLogin;
	GDataServiceGoogleFinance *financeService;	
	
	IBOutlet UITextField *portfolioNameTextField;
	IBOutlet UITextField *defaultCurrencyTextField;
	IBOutlet UIActivityIndicatorView *activityIndicator;
	
	CurrencyPickerViewController *currencyPicker;
}

@property (nonatomic, retain) GoogleClientLogin *googleClientLogin;
@property (nonatomic, retain) GDataServiceGoogleFinance *financeService;

@property (nonatomic, retain) IBOutlet UITextField *portfolioNameTextField;
@property (nonatomic, retain) IBOutlet UITextField *defaultCurrencyTextField;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, retain) CurrencyPickerViewController *currencyPicker;

- (IBAction)addPortfolio;
- (IBAction)cancel;
- (IBAction)changeDefaultCurrency;

@end
