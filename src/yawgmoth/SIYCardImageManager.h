#import <Cocoa/Cocoa.h>


@interface SIYCardImageManager : NSObject {
	NSString *mainDownloadingCardName;
	NSMutableDictionary *cardImageDownloaders;
}

- (NSImage *)imageForCardWithName:(NSString *)cardName;
- (BOOL)mainDownloadingCardIsDownloading;

@end
