#import "SIYCardImageManager.h"


@implementation SIYCardImageManager

- (id)initWithApplicationSupportDirectory:(NSString *)applicationSupportDirectory
{
	cardImagesDirectory = [[applicationSupportDirectory stringByAppendingPathComponent:@"CardImages"] retain];
	cardImageDownloaders = [[NSMutableDictionary dictionary] retain];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *directoryPath = [[NSBundle mainBundle] resourcePath];
	NSString *fileName;
	NSDirectoryEnumerator *directoryEnumerator = [fileManager enumeratorAtPath:directoryPath];
	NSPredicate *fileNameRegex = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @".*txt"];
	fileNameToURL = [[NSMutableDictionary dictionary] retain];
	
	while ((fileName = [directoryEnumerator nextObject]) != nil) {
		if ([fileNameRegex evaluateWithObject:fileName]) {
			NSString *fileString = [NSString stringWithContentsOfFile:[directoryPath stringByAppendingPathComponent:fileName] encoding:NSASCIIStringEncoding error:nil];
			[fileNameToURL addEntriesFromDictionary:[fileString dictionaryFromTSV]];
		}
	}
	
	return [super init];
}

- (void)download:(NSURLDownload *)download didFailWithError:(NSError *)error
{
	while ([[cardImageDownloaders allKeysForObject:download] count] == 0) {
		[NSThread sleepForTimeInterval:0.01];
	}
	
	NSString *cardName = [[cardImageDownloaders allKeysForObject:download] objectAtIndex:0];	
	[downloadFinishTarget performSelector:downloadFinishAction withObject:nil withObject:nil];
	[cardImageDownloaders removeObjectForKey:cardName];
}

- (void)downloadDidFinish:(NSURLDownload *)download
{
	while ([[cardImageDownloaders allKeysForObject:download] count] == 0) {
		[NSThread sleepForTimeInterval:0.01];
	}
	
	NSString *cardName = [[cardImageDownloaders allKeysForObject:download] objectAtIndex:0];
	[downloadFinishTarget performSelector:downloadFinishAction withObject:[self imageForCardWithName:cardName] withObject:cardName];
	[cardImageDownloaders removeObjectForKey:cardName];
	
}

- (NSString *)imageFileNameFromCardName:(NSString *)cardName
{
	return [[[[[[[cardName stringByReplacingOccurrencesOfString:@" // " withString:@"_"] 
				 stringByReplacingOccurrencesOfString:@"'" withString:@""] 
			    stringByReplacingOccurrencesOfString:@"," withString:@""] 
			   stringByReplacingOccurrencesOfString:@" " withString:@"_"] 
			  stringByReplacingOccurrencesOfString:@":" withString:@"_"] 
			 stringByAppendingString:@".jpg"]
			lowercaseString];
}

- (NSImage *)imageForCardWithName:(NSString *)cardName withAction:(SEL)action withTarget:(id)target
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *fileName = [self imageFileNameFromCardName:cardName];
	NSString *filePath = [cardImagesDirectory stringByAppendingPathComponent:fileName];
	
	mainDownloadingCardName = cardName;
	downloadFinishAction = action;
	downloadFinishTarget = target;

	if ([fileManager fileExistsAtPath:filePath]) {
		NSLog(@"file exists: %@", fileName);
		return [[NSImage alloc] initWithContentsOfFile:filePath];
	} else {
		NSString *fileURLString = [fileNameToURL objectForKey:fileName];
		if (fileURLString == nil) {
			return nil;
		}
		NSURL *fileURL = [NSURL URLWithString:fileURLString];
		NSURLRequest *request = [NSURLRequest requestWithURL:fileURL];
		NSURLDownload *download = [[[NSURLDownload alloc] initWithRequest:request delegate:self] retain];
		[download setDestination:filePath allowOverwrite:YES];
		[cardImageDownloaders setObject:download forKey:cardName];
	}
	
	return nil;
}
						  
- (NSImage *)imageForCardWithName:(NSString *)cardName
{
	NSString *fileName = [self imageFileNameFromCardName:cardName];
	NSString *filePath = [cardImagesDirectory stringByAppendingPathComponent:fileName];

	return [[NSImage alloc] initWithContentsOfFile:filePath];
}

- (BOOL)mainDownloadingCardIsDownloading
{
	return ([cardImageDownloaders objectForKey:[self mainDownloadingCardName]] != nil);
}

- (NSString *)mainDownloadingCardName
{
	return mainDownloadingCardName;
}

@end
