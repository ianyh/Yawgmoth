#import <Cocoa/Cocoa.h>


@interface SIYCardImageManager : NSObject {
	NSString *cardImagesDirectory;
	NSString *mainDownloadingCardName;
	NSMutableDictionary *cardImageDownloaders;
}

- (id)initWithApplicationSupportDirectory:(NSString *)applicationSupportDirectory;

- (NSString *)imageFileNameFromCardName:(NSString *)cardName;
- (NSImage *)imageForCardWithName:(NSString *)cardName withAction:(SEL)action withTarget:(id)target;
- (BOOL)mainDownloadingCardIsDownloading;
- (NSString *)mainDownloadingCardName;

@end
