//
//  RechargeDBColumn.h
//  thePay
//
//  Created by Dukhee Kang on 2018. 1. 6..
//  Copyright © 2018년 Telecentro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RechargeDBColumn : NSObject

+(NSString *)TABLE_NAME;
+(NSString *)ID ;
+(NSString *)COUNTRY_CODE;
+(NSString *)COUNTRY_NUMBER;
+(NSString *)CALL_NUMBER;
+(NSString *)DATE;

+(NSInteger) COL_IDX_ID             ;
+(NSInteger) COL_IDX_COUNTRY_CODE    ;
+(NSInteger) COL_IDX_COUNTRY_NUMBER ;
+(NSInteger) COL_IDX_CALL_NUMBER     ;
+(NSInteger) COL_IDX_DATE             ;

@end
