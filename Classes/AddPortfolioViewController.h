
#import <UIKit/UIKit.h>
#import "AbstractTextEditingUITableViewController.h"
#import "GoogleClientLogin.h"
#import "GDataFinance.h"

@interface AddPortfolioViewController : AbstractTextEditingUITableViewController {
	GoogleClientLogin *googleClientLogin;
	GDataServiceGoogleFinance *financeService;	
	
	IBOutlet UITextField *portfolioNameTextField;
	IBOutlet UIActivityIndicatorView *activityIndicator;
}

@property (nonatomic, retain) GoogleClientLogin *googleClientLogin;
@property (nonatomic, retain) GDataServiceGoogleFinance *financeService;

@property (nonatomic, retain) IBOutlet UITextField *portfolioNameTextField;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)addPortfolio;

@end
