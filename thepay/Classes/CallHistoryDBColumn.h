//
//  CallHistoryDBColumn.h
//  thePAY
//
//  Created by Telecentro on 2015. 12. 4..
//  Copyright © 2015년 Telecentro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CallHistoryDBColumn : NSObject




+(NSString *)TABLE_NAME;
+(NSString *)ID ;
+(NSString *)COUNTRY_CODE;
+(NSString *)COUNTRY_NUMBER;
+(NSString *)INTER_NUMBER;
+(NSString *)CALL_NUMBER;
+(NSString *)NAME;
+(NSString *)DATE;

+(NSInteger) COL_IDX_ID 			;
+(NSInteger) COL_IDX_COUNTRY_CODE	;
+(NSInteger) COL_IDX_COUNTRY_NUMBER ;
+(NSInteger) COL_IDX_INTER_NUMBER ;
+(NSInteger) COL_IDX_CALL_NUMBER 	;
+(NSInteger) COL_IDX_NAME 			;
+(NSInteger) COL_IDX_DATE 			;
@end
