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

- (void)download:(NSURLDownload *)download didFailWithError:(NSError *)error;
- (void)downloadDidFinish:(NSURLDownload *)download;
- (NSString *)imageFileNameForCardName:(NSString *)cardName;
- (NSImage *)imageForCardName:(NSString *)cardName shouldDownloadIfMissing:(BOOL)shouldDownload withAction:(SEL)action withTarget:(id)target;
- (NSString *)mainDownloadingCardName;

@end
