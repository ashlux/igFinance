
#import <UIKit/UIKit.h>
#import "GoogleClientLogin.h"
#import "GDataFinance.h"
#import "ARRollerView.h"
#import "ARRollerProtocol.h"

@interface PortfoliosViewController : UITableViewController<ARRollerDelegate> {
	GoogleClientLogin *googleClientLogin;
	GDataFeedFinancePortfolio *gDataFeedFinancePortfolio;

	IBOutlet UITableView *uitableView;
	IBOutlet UIActivityIndicatorView *activityIndicator;
	IBOutlet UITabBar *myTabBar;
}

@property (nonatomic, retain) GDataFeedFinancePortfolio *gDataFeedFinancePortfolio;
@property (nonatomic, retain) GoogleClientLogin *googleClientLogin;
@property (nonatomic, retain) IBOutlet UITableView *uitableView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) IBOutlet UITabBar *myTabBar;

@end
