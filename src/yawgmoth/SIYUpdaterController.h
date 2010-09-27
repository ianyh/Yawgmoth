#import <Cocoa/Cocoa.h>
#import "SIYCardManager.h"


@interface SIYUpdaterController : NSObject {
	IBOutlet SIYCardManager *cardManager;
	
	IBOutlet NSWindow *deckEditingWindow;
	IBOutlet NSPanel *updatePanel;
	IBOutlet NSProgressIndicator *progressIndicator;
	IBOutlet NSTextField *progressLabel;
	IBOutlet NSTextField *progressDetail;
	
	NSModalSession modalSession;
}

- (NSArray *)csvRowsFromString:(NSString *)fileString;
- (NSString *)superTypeFromType:(NSString *)type;
- (void)update;
- (void)startUpdate;
- (void)endUpdate;
- (NSString *)loadUpdateMarker;
- (void)writeUpdateMarker;

- (void)update07;
- (void)update071;
- (void)update072;

@end
