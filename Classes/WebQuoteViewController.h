
#import <UIKit/UIKit.h>
#import "GDataFinance.h"

@interface WebQuoteViewController : UIViewController {
	IBOutlet UIWebView *webView;

	GDataEntryFinancePosition *position;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet GDataEntryFinancePosition *position;

- (void)loadQuoteByPosition:(GDataEntryFinancePosition *) position;

@end
