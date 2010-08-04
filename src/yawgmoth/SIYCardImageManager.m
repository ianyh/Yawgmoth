#import "SIYCardImageManager.h"


@implementation SIYCardImageManager

- (id)initWithApplicationSupportDirectory:(NSString *)applicationSupportDirectory
{
	cardImagesDirectory = [[applicationSupportDirectory stringByAppendingPathComponent:@"CardImages"] retain];
	cardImageDownloaders = [[NSMutableDictionary dictionary] retain];
	fileNameToURL = [[NSMutableDictionary dictionary] retain];	
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    
    if ( ![fileManager fileExistsAtPath:cardImagesDirectory isDirectory:NULL] ) {
		if (![fileManager createDirectoryAtPath:cardImagesDirectory withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSAssert(NO, ([NSString stringWithFormat:@"Failed to create App Support directory %@ : %@", cardImagesDirectory, error]));
            NSLog(@"Error creating application support directory at %@ : %@",cardImagesDirectory,error);
            return nil;
		}
    }
	
	NSString *directoryPath = [[NSBundle mainBundle] resourcePath];
	NSDirectoryEnumerator *directoryEnumerator = [fileManager enumeratorAtPath:directoryPath];
	NSPredicate *fileNameRegex = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @".*txt"];
	NSString *fileName;	
	
	while ((fileName = [directoryEnumerator nextObject]) != nil) {
		if ([fileNameRegex evaluateWithObject:fileName]) {
			NSString *fileString = [NSString stringWithContentsOfFile:[directoryPath stringByAppendingPathComponent:fileName] 
															 encoding:NSASCIIStringEncoding 
															 error:nil];
			[fileNameToURL addEntriesFromDictionary:[self fileToURLDictionaryFromString:fileString]];
		}
	}
	
	return [super init];
}

- (BOOL)cardNameIsDownloading:(NSString *)cardName
{
	return [cardImageDownloaders objectForKey:cardName] != nil;
}

- (NSMutableDictionary *)fileToURLDictionaryFromString:(NSString *)string
{
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	NSArray  *lines  = [string componentsSeparatedByString:@"\n"];
	NSEnumerator *theEnum = [lines objectEnumerator];
	NSString *theLine;
	
	while (nil != (theLine = [theEnum nextObject]) )
	{
		if (![theLine isEqualToString:@""] && ![theLine hasPrefix:@"#"])
		{
			NSArray *values  = [theLine componentsSeparatedByString:@"\t"];
			[result setObject:[values objectAtIndex:1] forKey:[values objectAtIndex:0]];
		}
	}
	return result;
}

- (void)download:(NSURLDownload *)download didFailWithError:(NSError *)error
{
	while ([[cardImageDownloaders allKeysForObject:download] count] == 0) {
		[NSThread sleepForTimeInterval:0.01];
	}
	
	NSString *cardName = [[cardImageDownloaders allKeysForObject:download] objectAtIndex:0];
    if ([cardName isEqualToString:[self mainDownloadingCardName]]) {
        [downloadFinishTarget performSelector:downloadFinishAction 
                                   withObject:NULL 
                                   withObject:nil];
    }
	[cardImageDownloaders removeObjectForKey:cardName];
	[download release];	
}

- (void)downloadDidFinish:(NSURLDownload *)download
{
	while ([[cardImageDownloaders allKeysForObject:download] count] == 0) {
		[NSThread sleepForTimeInterval:0.01];
	}
	
	NSString *cardName = [[cardImageDownloaders allKeysForObject:download] objectAtIndex:0];
	[cardImageDownloaders removeObjectForKey:cardName];	
    if ([cardName isEqualToString:[self mainDownloadingCardName]]) {
        NSImage *cardImage = [self imageForCardName:cardName 
                                         shouldDownloadIfMissing:NO 
                                         withAction:nil 
                                         withTarget:nil];
        [downloadFinishTarget performSelector:downloadFinishAction 
                                   withObject:cardImage
                                   withObject:cardName];
    }
	[download release];
}

- (NSString *)imageFileNameForCardName:(NSString *)cardName
{
	return [[[[[[[cardName stringByReplacingOccurrencesOfString:@" // " withString:@"_"] 
				 stringByReplacingOccurrencesOfString:@"'" withString:@""] 
			    stringByReplacingOccurrencesOfString:@"," withString:@""] 
			   stringByReplacingOccurrencesOfString:@" " withString:@"_"] 
			  stringByReplacingOccurrencesOfString:@"-" withString:@"_"] 
			 stringByAppendingString:@".jpg"]
			lowercaseString];
}

- (NSImage *)imageForCardName:(NSString *)cardName shouldDownloadIfMissing:(BOOL)shouldDownload withAction:(SEL)action withTarget:(id)target
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *fileName = [self imageFileNameForCardName:cardName];
	NSString *filePath = [cardImagesDirectory stringByAppendingPathComponent:fileName];
    mainDownloadingCardName = cardName;
	
	if ([self cardNameIsDownloading:cardName]) {
		return nil;
	} else if ([fileManager fileExistsAtPath:filePath]) {
		return [[NSImage alloc] initWithContentsOfFile:filePath];
	} else if (shouldDownload) {
		downloadFinishAction = action;
		downloadFinishTarget = target;
		
		NSString *fileURLString = [fileNameToURL objectForKey:fileName];
		if (fileURLString == nil) {
			NSLog(@"unable to find url for card name (%@) and file name (%@)", cardName, fileName);
			return nil;
		}
		NSURL *fileURL = [NSURL URLWithString:fileURLString];
		NSURLRequest *request = [NSURLRequest requestWithURL:fileURL];
		NSURLDownload *download = [[NSURLDownload alloc] initWithRequest:request delegate:self];
		[download setDestination:filePath allowOverwrite:YES];
		[cardImageDownloaders setObject:download forKey:cardName];
	}
	
	return nil;
}

- (NSString *)mainDownloadingCardName
{
	return mainDownloadingCardName;
}

@end
