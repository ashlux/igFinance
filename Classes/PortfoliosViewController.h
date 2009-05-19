
#import <UIKit/UIKit.h>
#import "GoogleClientLogin.h"
#import "GDataFinance.h"

@interface PortfoliosViewController : UITableViewController {
	GoogleClientLogin *googleClientLogin;
	IBOutlet UITableView *uitableView;
	GDataFeedFinancePortfolio *gDataFeedFinancePortfolio;
}

@property (nonatomic, retain) GoogleClientLogin *googleClientLogin;
@property (nonatomic, retain) IBOutlet UITableView *uitableView;
@property (nonatomic, retain) GDataFeedFinancePortfolio *gDataFeedFinancePortfolio;

@end
