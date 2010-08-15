#import <Cocoa/Cocoa.h>
#import "SIYCardManager.h"

#define UPDATE_COUNT 2

@interface SIYUpdaterController : NSObject {
	IBOutlet SIYCardManager *cardManager;
	
	IBOutlet NSPanel *updatePanel;
	IBOutlet NSProgressIndicator *progressIndicator;
	IBOutlet NSTextField *progressLabel;
	
	NSModalSession modalSession;
}

- (NSArray *)csvRowsFromString:(NSString *)fileString;
- (NSString *)superTypeFromType:(NSString *)type;
- (void)update;
- (void)startUpdate;
- (void)endUpdate;
- (NSString *)loadUpdateMarker;
- (void)writeUpdateMarker;
- (void)incrementProgress:(double)increment;

- (void)update07;
- (void)update071;

@end
