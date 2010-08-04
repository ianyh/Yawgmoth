#import <Cocoa/Cocoa.h>


@interface SIYCardImageManager : NSObject {
	NSString *cardImagesDirectory;
	NSString *mainDownloadingCardName;
	NSMutableDictionary *cardImageDownloaders;
	NSMutableDictionary *fileNameToURL;
	
	SEL downloadFinishAction;
	id downloadFinishTarget;
}

- (id)initWithApplicationSupportDirectory:(NSString *)applicationSupportDirectory;

- (BOOL)cardNameIsDownloading:(NSString *)cardName;
- (NSMutableDictionary *)fileToURLDictionaryFromString:(NSString *)string;
- (void)download:(NSURLDownload *)download didFailWithError:(NSError *)error;
- (void)downloadDidFinish:(NSURLDownload *)download;
- (NSString *)imageFileNameForCardName:(NSString *)cardName;
- (NSImage *)imageForCardName:(NSString *)cardName shouldDownloadIfMissing:(BOOL)shouldDownload withAction:(SEL)action withTarget:(id)target;
- (NSString *)mainDownloadingCardName;

@end
