
#import <UIKit/UIKit.h>
#import "GoogleClientLogin.h"
#import "GDataFinance.h"

@interface PortfoliosViewController : UITableViewController {
	GoogleClientLogin *googleClientLogin;
	GDataFeedFinancePortfolio *gDataFeedFinancePortfolio;

	IBOutlet UITableView *uitableView;
	IBOutlet UIActivityIndicatorView *activityIndicator;
}

@property (nonatomic, retain) GDataFeedFinancePortfolio *gDataFeedFinancePortfolio;
@property (nonatomic, retain) GoogleClientLogin *googleClientLogin;
@property (nonatomic, retain) IBOutlet UITableView *uitableView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
