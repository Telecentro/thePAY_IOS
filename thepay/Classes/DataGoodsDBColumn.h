//
//  DataGoodsDBColumn.h
//  thePAY
//
//  Created by Telecentro on 2015. 12. 4..
//  Copyright © 2015년 Telecentro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataGoodsDBColumn : NSObject
+(NSString*) TABLE_NAME ;

+(NSString*)ID 			;
+(NSString*)MVNO_ID 	;
+(NSString*)AMOUNT 		;
+(NSString*)SORT_NO 	;
+(NSString*)MVNO_NAME ;
+(NSString *) RCG_TYPE;
+ (NSString *) PPS_NAME     ;
+(NSString *) IMAGE_NAME;
+(NSString *) IMAGE_SEL_NAME;
+(NSString *) TITLE;
@end
