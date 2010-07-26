#import <Cocoa/Cocoa.h>


@interface SIYCardImageManager : NSObject {
	NSString *mainDownloadingCardName;
	NSMutableDictionary *cardImageDownloaders;
}

- (NSImage *)imageForCardWithName:(NSString *)cardName withAction:(SEL)action withTarget:(id)target;
- (BOOL)mainDownloadingCardIsDownloading;
- (NSString *)mainDownloadingCardName;

@end
