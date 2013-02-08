//
//  CardMatchingGame.m
//  Matchismo
//
//  Created by Robert Lummis on 2/5/13.
//  Copyright (c) 2013 Electric Turkey Software. All rights reserved.
//

#import "CardMatchingGame.h"
#import "PlayingCard.h"

@interface CardMatchingGame()
@property (strong, nonatomic) NSMutableArray *cards;
@property (nonatomic) int score;
@property (nonatomic, strong) NSString *comment; 
@end

#define MATCH_BONUS 4
#define MISMATCH_POINTS_2CARD -2
#define MISMATCH_POINTS_3CARD -4;
#define FLIP_POINTS -1

@implementation CardMatchingGame

- (NSMutableArray *)cards {
    if (!!!_cards) {
        _cards = [[NSMutableArray alloc] init];
    }
    return _cards;
}

- (id)initWithCardCount:(NSUInteger)count usingDeck:(Deck *)deck {
    if ( (self = [super init] ) ) {
        for (int i = 0; i < count; i++) {
            Card *card = [deck drawRandomCard];
            if (!!!card) {
                self = nil;
            } else {
                self.cards[i] = card;
            }
        }
        
    }
    self.mode = 2;
    return self;
}

- (Card *)cardAtIndex:(NSUInteger)index {
    return index < [self.cards count] ? self.cards[index] : nil;
}

- (void)flipCardAtIndex:(NSUInteger)index { //only get here if card is NOT unplayable
    Card *card = [self cardAtIndex:index];
    if (card.isFaceUp) {
        card.faceUp = NO;
        self.comment = [NSString stringWithFormat:@"Flipped down %@", card.contents];
        return;
    }
    
        //if we get here the card is NOT unplayable and is face down
        //get array of cards that are already up
    NSMutableArray *upCards = [[NSMutableArray alloc] init];
    for (Card *aCard in self.cards) {
        if (aCard.isFaceUp && !!!aCard.isUnplayable) {
            [upCards addObject:aCard];
        }
    }
    
        //don't flip up this card if too many would be up
    if ( [upCards count] >= self.mode) {    //don't turn card up because too many would be up
        self.comment = [NSString stringWithFormat:@"You already have %d cards up.", self.mode];
        return;
    }
    
        //flip this card up
    self.comment = [NSString stringWithFormat:@"Flipped %@ up", card.contents];
    card.faceUp = YES;
    self.score += FLIP_POINTS;
    
        //if we now have 2 (or 3) cards up go ahead and get a score based on what matches
    [upCards addObject:card];
    if ( [upCards count] == self.mode ) {
        [self evaluateCards:upCards];
    }
    
        //if not enough cards are up don't do anything else here
}

    //handle the 2 or 3 cards that are turned up
- (void)evaluateCards:(NSArray *)upCards {
    NSLog(@"evaluating %d cards", [upCards count]);
    if ( [upCards count] < 2 ) return;  //this should never happen
    
    NSMutableArray *cardsThatMatchByRank = [[NSMutableArray alloc] init];
    NSMutableArray *cardsThatMatchBySuit = [[NSMutableArray alloc] init];
    for (PlayingCard *card in upCards) {
        if ( [card matchByRank:upCards] ) [cardsThatMatchByRank addObject:card];
        if ( [card matchBySuit:upCards] ) [cardsThatMatchBySuit addObject:card];
    }
    
        //count cards that match by rank, cards that match by suit, and put the cards in a set
    NSUInteger rankMatches = [cardsThatMatchByRank count];
    NSUInteger suitMatches = [cardsThatMatchBySuit count];
    NSMutableSet *matchedCards = [NSMutableSet setWithCapacity:3];
    [matchedCards addObjectsFromArray:cardsThatMatchByRank];
    [matchedCards addObjectsFromArray:cardsThatMatchBySuit];
    
        //disable the cards that matched something
    for (PlayingCard *card in matchedCards) {
        card.unplayable = YES;
    }
    
        //get score for this play
    NSInteger scoreThisPlay = [self scoreForRankMatches:rankMatches suitMatches:suitMatches];
    
        //construct comment including the list of cards that match something (without saying
        //if it's by rank or by suit) and the score for this move
    if ( [matchedCards count] == 0 ) {
        self.comment = [NSString stringWithFormat:@"No match! %d points", scoreThisPlay];
    } else {
        self.comment = @"Matches: ";
        for (PlayingCard *card in matchedCards) {
            self.comment = [self.comment stringByAppendingString:[NSString stringWithFormat:@"%@ ", card.contents]];
        }
        self.comment = [self.comment stringByAppendingString:[NSString stringWithFormat:@"%d points", scoreThisPlay]];
    }
    
        //increment score
    self.score += scoreThisPlay;
}

-(NSInteger) scoreForRankMatches:(NSUInteger)r suitMatches:(NSUInteger)s {
    NSInteger score = 0;
    
    if (self.mode == 2) {
        if (r == 0 && s == 0) return -5;    //no match
        if (r == 2) return 10;
        if (s == 2) return 4;
        
    } else if (self.mode == 3) {
        if (r == 0 && s == 0) return -7;    //no match
        if (r == 2 && s == 0) return 8;
        if (r == 0 && s == 2) return 3;
        if (r == 2 && s == 2) return 12;
        if (r == 3) return 100;
        if (s == 3) return 20;
        
    } else {
        NSLog(@"self.mode should be 2 or 3, but it is: %d", self.mode);
    }
    
    
    

    return score;
}

@end
