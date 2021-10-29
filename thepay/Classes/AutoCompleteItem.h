//
//  AutoCompleteItem.h
//  thepay
//
//  Created by seojin on 2020/11/20.
//  Copyright © 2020 Duo Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AutoCompleteItem : NSObject
@property (nonatomic, strong)NSString *code;
@property (nonatomic, strong)NSString *mvno;
@property (nonatomic, strong)NSString *type;
@property (nonatomic, strong)NSString *text;
@property (nonatomic, strong)NSString *name;
@property (nonatomic, strong)NSString *date;
@property (nonatomic, strong)NSString *cate;
@property (nonatomic, strong)NSString *inter;
@property (nonatomic, strong)NSString *save;

- (BOOL)isNotValidTextItem;

@end

NS_ASSUME_NONNULL_END
