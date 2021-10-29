//
//  AutoCompleteItem.m
//  thepay
//
//  Created by seojin on 2020/11/20.
//  Copyright © 2020 Duo Labs. All rights reserved.
//

#import "AutoCompleteItem.h"

@implementation AutoCompleteItem

- (BOOL)isNotValidTextItem {
    if (self.text == [NSNull null] || self.code == [NSNull null]) {
        return true;
    } else {
        return false;
    }
}

@end
