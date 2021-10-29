//
//  NationDBColumn.h
//  thePAY
//
//  Created by Telecentro on 2015. 12. 4..
//  Copyright © 2015년 Telecentro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NationDBColumn : NSObject

+(NSString *) TABLE_NAME ;

+(NSString *) ID 			;
+(NSString *) COUNTRY_CODE 	;
+(NSString *) NAME_KR 	;
+(NSString *) NAME_US 	;
+(NSString *) NAME_CN  		;
+(NSString *) COUNTRY_NUMBER 	;
+(NSString *) GMT 				;

+(NSInteger) COL_IDX_ID 		;
+(NSInteger) COL_IDX_COUNTRY_CODE	;
+(NSInteger) COL_IDX_NAME_KR 		;
+(NSInteger) COL_IDX_NAME_US 		;
+(NSInteger) COL_IDX_NAME_CN 		;
+(NSInteger) COL_IDX_COUNTRY_NUMBER ;
+(NSInteger) COL_IDX_GMT 			;
@end
