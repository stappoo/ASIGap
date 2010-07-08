//
//  ASIGap.m
//
//  Created by Steve Noyce on 6/22/10.
//  Copyright 2010 Stappoo. All rights reserved.
//
//
#import "ASIGap.h"
#import "ASIHTTPRequest.h"
#import "ASIHTTPRequestDelegate.h"
#import "ASIHTTPRequestConfig.h"
#import "ASIFormDataRequest.h"

@implementation ASIGap

- (void) submitForm:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	NSUInteger argc = [arguments count];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString* appDocsPath = [paths objectAtIndex:0];
	
	NSString* successCallback = nil;
	NSString* errorCallback = nil;
	
	if(argc >= 3)
	{
		NSString* urlstring = (NSString*) [arguments objectAtIndex:0];
		NSURL *url = (NSURL*) [NSURL URLWithString:urlstring];
		
		successCallback = [arguments objectAtIndex:1];
		errorCallback = [arguments objectAtIndex:2];
				
		ASIFormDataRequest *request = [[[ASIFormDataRequest alloc] initWithURL:url] autorelease];

		[request setTimeOutSeconds:20];
		
		NSUInteger argi = 3;
		while (argi < argc) 
		{
			NSMutableString* cmd= (NSMutableString*) [arguments objectAtIndex:argi];
			
			if ([@"AddPostValue" isEqualToString:cmd])
			{
				NSString* name = (NSString*) [arguments objectAtIndex:argi+1];
				NSString* value = (NSString*) [arguments objectAtIndex:argi+2];
				[request setPostValue:value forKey:name];
				argi += 3;				
			}
			else if ([@"AddFile" isEqualToString:cmd])
			{
				NSString* name = (NSString*) [arguments objectAtIndex:argi+1];
				NSString* path = (NSString*) [arguments objectAtIndex:argi+2];
				path = [NSString stringWithFormat:@"%@/%@", appDocsPath, path];
				NSString* jsString = [[NSString alloc] initWithFormat:@"debug.log(\"path:  %@\");", path ];
				[webView stringByEvaluatingJavaScriptFromString:jsString];

				[request setFile:path forKey:name];
				argi += 3;
			}
			else if ([@"SetUsername" isEqualToString:cmd])
			{
				NSString* username = (NSString*) [arguments objectAtIndex:argi+1];
				[request setUsername:username];
				argi += 2;
			}
			else if ([@"SetPassword" isEqualToString:cmd])
			{
				NSString* password = (NSString*) [arguments objectAtIndex:argi+1];
				[request setPassword:password];
				argi += 2;
			}
			else
			{
				NSString* jsString = [[NSString alloc] initWithFormat:@"debug.log(\"got bad argument %@\");", [arguments objectAtIndex:argi] ];
				[webView stringByEvaluatingJavaScriptFromString:jsString];
		        return;				
			}
		 }

		[request startSynchronous];
		
		int statusCode = [request responseStatusCode];
		
		NSMutableString *statusMessage = (NSMutableString *)[request responseStatusMessage];
		
		if(statusCode == 201)
		{
			NSString* jsString = [[NSString  alloc] initWithFormat:@"%@();", successCallback];
			[webView stringByEvaluatingJavaScriptFromString:jsString];
			[jsString release];
		}
		else 
		{
			NSError *error = [request error];
			NSDictionary *userInfo;
			if (nil == statusMessage)
			{
				userInfo = [error userInfo];
				statusMessage = [userInfo objectForKey:@"NSLocalizedDescription"];
			}
			NSString* jsString = [[NSString  alloc] initWithFormat:@"%@(%i, \"%@\");", errorCallback, statusCode, statusMessage];
			[webView stringByEvaluatingJavaScriptFromString:jsString];
			[jsString release];
		}
	}
	else 
	{
		// FATAL
		return; 
	}
}

@end
