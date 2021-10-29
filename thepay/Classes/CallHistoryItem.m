//
//  CallHistoryItem.m
//  thePAY
//
//  Created by Telecentro on 2015. 11. 27..
//  Copyright © 2015년 Telecentro. All rights reserved.
//

#import "CallHistoryItem.h"
#import "TimeUtils.h"

@implementation CallHistoryItem

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.date = [TimeUtils getCurrentDate];
    }
    return self;
}

- (BOOL)isNotValidNumberItem {
    if (self.callNumber == [NSNull null] || self.countryCode == [NSNull null] || self.date == [NSNull null]) {
        return true;
    } else {
        return false;
    }
}

- (BOOL)isNotValidCallNumberItem {
    if (self.callNumber == [NSNull null] || self.countryCode == [NSNull null] || self.countryNumber == [NSNull null] || self.date == [NSNull null] || self.interNumber == [NSNull null]) {
        return true;
    } else {
        return false;
    }
}

@end

@implementation CallEmailItem


- (id)copyWithZone:(NSZone*)zone
{
    CallEmailItem *item = [[CallEmailItem alloc]init];
    item.email = _email;
    return item;
    
    
}
@end
