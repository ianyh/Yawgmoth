#import "SIYCardImageManager.h"


@implementation SIYCardImageManager

- (id)initWithApplicationSupportDirectory:(NSString *)applicationSupportDirectory
{
	cardImagesDirectory = [[applicationSupportDirectory stringByAppendingPathComponent:@"CardImages"] retain];
	return [super init];
}

- (NSString *)imageFileNameFromCardName:(NSString *)cardName
{
	return [[[[[[[cardName stringByReplacingOccurrencesOfString:@" " withString:@"_"] 
				 stringByReplacingOccurrencesOfString:@"." withString:@"_"] 
			    stringByReplacingOccurrencesOfString:@"," withString:@"_"] 
			   stringByReplacingOccurrencesOfString:@"/" withString:@"_"] 
			  stringByReplacingOccurrencesOfString:@":" withString:@"_"] 
			 stringByAppendingString:@".jpg"]
			lowercaseString];
}

- (NSImage *)imageForCardWithName:(NSString *)cardName withAction:(SEL)action withTarget:(id)target
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *fileName = [cardImagesDirectory stringByAppendingPathComponent:[self imageFileNameFromCardName:cardName]];

	if ([fileManager fileExistsAtPath:fileName]) {
		NSLog(@"file exists: %@", fileName);
		return [[NSImage alloc] initWithContentsOfFile:fileName];
	} else {
		// TODO: download image
	}
	
	return nil;
}

- (BOOL)mainDownloadingCardIsDownloading
{
	return NO;
}

- (NSString *)mainDownloadingCardName
{
	return mainDownloadingCardName;
}

@end
