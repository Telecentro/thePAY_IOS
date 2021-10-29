//
//  AutoCompleteDBColumn.h
//  thepay
//
//  Created by seojin on 2020/11/20.
//  Copyright © 2020 Duo Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AutoCompleteDBColumn : NSObject

+(NSString *)TABLE_NAME;
+(NSString *)ID ;
+(NSString *)COUNTRY_CODE;
+(NSString *)COUNTRY_NUMBER;
+(NSString *)NAME;
+(NSString *)TYPE;
+(NSString *)TEXT;
+(NSString *)DATE;
+(NSString *)CATE;
+(NSString *)INTER_NUMBER;
+(NSString *)SAVE_TYPE;

+(NSInteger) COL_IDX_ID;
+(NSInteger) COL_IDX_COUNTRY_CODE;
+(NSInteger) COL_IDX_COUNTRY_NUMBER;
+(NSInteger) COL_IDX_NAME;
+(NSInteger) COL_IDX_TYPE;
+(NSInteger) COL_IDX_TEXT;
+(NSInteger) COL_IDX_DATE;
+(NSInteger) COL_IDX_CATE;
+(NSInteger) COL_IDX_INTER_NUMBER;
+(NSInteger) COL_IDX_SAVE_TYPE;

@end

NS_ASSUME_NONNULL_END
