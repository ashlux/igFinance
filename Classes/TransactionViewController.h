
#import <UIKit/UIKit.h>
#import "GoogleClientLogin.h"
#import "GDataFinance.h"

@interface TransactionViewController : UITableViewController {
	GoogleClientLogin *googleClientLogin;
	GDataEntryFinancePosition *position;
	GDataServiceGoogleFinance *financeService;
	GDataFeedFinanceTransaction *transactionFeed;
	
	IBOutlet UIActivityIndicatorView *activityIndicator;
	IBOutlet UITableView *transactionTableView;
}

@property (nonatomic, retain) GoogleClientLogin *googleClientLogin;
@property (nonatomic, retain) GDataEntryFinancePosition *position;
@property (nonatomic, retain) GDataServiceGoogleFinance *financeService;
@property (nonatomic, retain) GDataFeedFinanceTransaction *transactionFeed;

@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) UITableView *transactionTableView;

@end
