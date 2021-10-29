//
//  CallHistoryItem.h
//  thePAY
//
//  Created by Telecentro on 2015. 11. 27..
//  Copyright © 2015년 Telecentro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CallHistoryItem : NSObject

//private static final long serialVersionUID = -4805492737775984007L;
//private int dbId = -1;
@property (nonatomic, strong)NSString *countryCode;
@property (nonatomic, strong)NSString *countryNumber;
@property (nonatomic, strong)NSString *interNumber;
@property (nonatomic, strong)NSString *callNumber;
@property (nonatomic, strong)NSString *name;
@property (nonatomic, strong)NSString *date;

- (BOOL)isNotValidNumberItem;
- (BOOL)isNotValidCallNumberItem;


@end


@interface CallEmailItem : NSObject

//private static final long serialVersionUID = -4805492737775984007L;
//private int dbId = -1;
@property (nonatomic, strong)NSString *email;


@end
