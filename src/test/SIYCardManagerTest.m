#import "SIYCardManagerTest.h"


@implementation SIYCardManagerTest

- (void)testCardFetchAndInsert
{
	SIYCardManager *cardManager = [[NSApp delegate] cardManager];
	/*
	NSManagedObject *fullCard, *collectionCard1, *collectionCard2;
	SIYMetaCard *metaCard1, *metaCard2;
	
	fullCard = [cardManager managedObjectWithPredicate:[NSPredicate predicateWithFormat:@"name = %@ AND set = %@", @"Nantuko Shade", @"Torment"] 
								  inEntityWithName:@"FullCard"];
	STAssertTrue([fullCard.name isEqualToString:@"Nantuko Shade"], @"FullCard fetch");
	
	metaCard1 = [cardManager insertMetaCardFromCard:fullCard];
	metaCard2 = [cardManager metaCardWithCardName:@"Nantuko Shade" inDeck:nil];
	STAssertTrue([metaCard1.name isEqualToString:metaCard2.name], @"MetaCard consitency");
	STAssertTrue([metaCard2.name isEqualToString:@"Nantuko Shade"], @"MetaCard accuracy");
	
	collectionCard1 = [cardManager insertCollectionCardFromCard:fullCard];
	[metaCard1 addCardsObject:collectionCard1];
	collectionCard2 = [cardManager collectionCardWithCardName:@"Nantuko Shade" withSet:@"Torment" inCollection:metaCard1.cards];
	STAssertTrue([collectionCard1.name isEqualToString:collectionCard2.name] && [collectionCard1.set isEqualToString:collectionCard2.set], 
				 @"CollectionCard consistency; names (%@, %@); sets (%@, %@)", 
				 collectionCard1.name, collectionCard2.name, collectionCard1.set, collectionCard2.set);
	STAssertTrue([collectionCard2.name isEqualToString:@"Nantuko Shade"] && [collectionCard2.set isEqualToString:@"Torment"], @"CollectionCard accuracy");
	 */
}

@end
