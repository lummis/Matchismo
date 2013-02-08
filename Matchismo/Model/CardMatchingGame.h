//
//  CardMatchingGame.h
//  Matchismo
//
//  Created by Robert Lummis on 2/5/13.
//  Copyright (c) 2013 Electric Turkey Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Deck.h"

@interface CardMatchingGame : NSObject

- (id)initWithCardCount:(NSUInteger)count usingDeck:(Deck *)deck;
- (void)flipCardAtIndex:(NSUInteger)index;
- (Card *)cardAtIndex:(NSUInteger)index;

@property (nonatomic, readonly) int score;
@property (nonatomic, readonly) NSString *comment;
@property (nonatomic) int mode; //2 or 3

@end
