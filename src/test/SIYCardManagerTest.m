#import "SIYCardManagerTest.h"


@implementation SIYCardManagerTest

- (void)setUp
{
	cardManager = [[NSApp delegate] cardManager];	
	fullCard = [cardManager managedObjectWithPredicate:[NSPredicate predicateWithFormat:@"(name == %@) AND (set == %@)", @"Nantuko Shade", @"Magic 2011"] 
									  inEntityWithName:@"FullCard"];
}

- (void)testTempCardInsertAndFetch
{
	NSManagedObject *tempCard1, *tempCard2;
	
	tempCard1 = [cardManager insertTempCollectionCardFromCard:fullCard];
	tempCard2 = [cardManager tempCardWithName:fullCard.name withSet:fullCard.set];
	
	STAssertTrue([tempCard1.name isEqualToString:tempCard2.name] && [tempCard1.set isEqualToString:tempCard2.set],
				 @"TempCard fetch was inconsitent with parameters: name(%@, %@), set(%@, %@)", tempCard1.name, tempCard2.name, tempCard1.set, tempCard2.set);
}

- (void)testCollectionCardInsertAndFetch
{
	NSManagedObject *card1, *card2;
	SIYMetaCard *metaCard1, *metaCard2;

	card1 = [cardManager insertCollectionCardFromCard:fullCard inDeck:nil];
	card2 = [cardManager collectionCardWithCardName:fullCard.name withSet:fullCard.set inDeck:nil];
	
	STAssertTrue([card1.name isEqualToString:card2.name] && [card1.set isEqualToString:card2.set],
				 @"CollectionCard fetch was inconsistent with parameters: name(%@, %@), set (%@, %@)", card1.name, card2.name, card1.set, card2.set);

	metaCard1 = card1.metaCard;
	metaCard2 = card2.metaCard;
	
	STAssertEqualObjects(metaCard1, metaCard2, @"CollectionCard insert was inconsistent; different MetaCards");
}

- (void)testDeckInsertAndFetch
{
	NSManagedObject *deck1, *deck2;
	
	deck1 = [cardManager insertDeck:@"foobar"];
	deck2 = [cardManager deckWithName:@"foobar"];
	
	STAssertTrue([deck1.name isEqualToString:deck2.name], @"Deck fetch was inconsistent with parameters: name(%@, %@)", deck1.name, deck2.name);
	STAssertEqualObjects(deck1.metaCards, deck2.metaCards, @"Deck insert was inconsistent; different MetaCard sets");
}

- (void)testCardIncrement
{
	NSManagedObject *tempCard, *card;
	
	tempCard = [cardManager insertTempCollectionCardFromCard:fullCard];
	[cardManager incrementQuantityForCard:tempCard withIncrement:1];
	
	STAssertTrue([tempCard.quantity intValue] == 1,
				 @"Increment of TempCollectionCard failed. Expected quantity 1 but got %@", tempCard.quantity);
	
	card = [cardManager insertCollectionCardFromCard:fullCard inDeck:nil];
	[cardManager incrementQuantityForCard:card withIncrement:5];
	
	STAssertTrue([card.quantity intValue] == 5,
				 @"Increment of CollectionCard failed. Expected quantity 5 but got %@", card.quantity);
	
	[cardManager incrementQuantityForCard:card withIncrement:-5];
	
	STAssertNil([cardManager collectionCardWithCardName:fullCard.name withSet:fullCard.set inDeck:nil],
				@"CollectionCard not deleted when quantity reduced to 0");
	STAssertNil([cardManager metaCardWithCardName:fullCard.name inDeck:nil],
				@"MetaCard not deleted when last CollectionCard quantity reduced to 0");
}

@end
