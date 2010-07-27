#import "TSVParser.h"


@implementation NSString (TSVParser)

- (NSMutableDictionary *)dictionaryFromTSV
{
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	NSArray  *lines  = [self componentsSeparatedByString:@"\n"];
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

@end
