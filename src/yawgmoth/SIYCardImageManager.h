#import <Cocoa/Cocoa.h>
#import "TSVParser.h"


@interface SIYCardImageManager : NSObject {
	NSString *cardImagesDirectory;
	NSString *mainDownloadingCardName;
	NSMutableDictionary *cardImageDownloaders;
	NSMutableDictionary *fileNameToURL;
	
	SEL downloadFinishAction;
	id downloadFinishTarget;
}

- (id)initWithApplicationSupportDirectory:(NSString *)applicationSupportDirectory;

- (NSString *)imageFileNameFromCardName:(NSString *)cardName;
- (NSImage *)imageForCardWithName:(NSString *)cardName withAction:(SEL)action withTarget:(id)target;
- (NSImage *)imageForCardWithName:(NSString *)cardName;
- (BOOL)mainDownloadingCardIsDownloading;
- (NSString *)mainDownloadingCardName;

@end
