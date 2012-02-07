//
//  CIMNetEngine.m
//  CIMModule
//
//  Created by 林 董 on 12-2-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CIMNetEngine.h"

@implementation CIMNetEngine
@synthesize dbDelegate;

- (long) ConnectServer:(NSString *)strServerAddress Port:(NSInteger)nPort
{
    return 0;
}

- (long) LoginUserName:(NSString *)strNSUserName PassWord:(NSString *)strNSPassWord
{
    return 0;
}

- (long) Logout
{
    return 0;
}

- (long)GetOfflineData:(GUID *)guidCompany Selector:(SEL)method withObject:(id)selRecv
{
    
//    NSString * strXMLSchema = [[NSBundle mainBundle] pathForResource:@"1.xml" ofType:nil];
//    NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:strXMLSchema];
//    NSData *data1 = [file readDataToEndOfFile];
//    [file closeFile];
//    
//    [dbDelegate CreateTableByXML:data1];
//    return 0;
    
    NSString *urlString = [NSString stringWithFormat:@"http://192.168.1.54/CIMWebService/Service1.asmx"]; 
    
    NSString *soapMessage = nil;
    soapMessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                   "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                   "<soap:Body>\n"
                   "<HelloWorld xmlns=\"http://tempuri.org/\" />\n"
                   "</soap:Body>\n"
                   "</soap:Envelope>\n"];
    
    NSURL *url = [NSURL URLWithString:urlString];
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
	NSString *msgLength = [NSString stringWithFormat:@"%d", [soapMessage length]];
	
	//以下对请求信息添加属性前四句是必有的，第五句是soap信息。
	[theRequest addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
	[theRequest addValue: @"http://tempuri.org/HelloWorld" forHTTPHeaderField:@"SOAPAction"];
	
	[theRequest addValue: msgLength forHTTPHeaderField:@"Content-Length"];
	[theRequest setHTTPMethod:@"POST"];
	[theRequest setHTTPBody: [soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    
	//请求
	NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	
	//如果连接已经建好，则初始化data
	if( theConnection )
	{
		webData = [[NSMutableData alloc] init];
	}
	else
	{
		NSLog(@"theConnection is NULL");
	}
    return 0;
}


-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	//[webData setLength: 0];
	NSLog(@"connection: didReceiveResponse:1");
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[webData appendData:data];
	NSLog(@"connection: didReceiveData:2");
    
}

//如果电脑没有连接网络，则出现此信息（不是网络服务器不通）
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"ERROR with theConenction");
	[connection release];
	[webData release];
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSLog(@"3 DONE. Received Bytes: %d", [webData length]);
	NSString *theXML = [[NSString alloc] initWithBytes: [webData bytes] length:[webData length] encoding:NSUTF8StringEncoding];
//    theXML = [theXML stringByReplacingOccurrencesOfString:@"%" withString:@"%%"]; 
	NSLog(@"%@", theXML);
	[theXML release];
	
	//重新加載xmlParser
	if( xmlParser )
	{
		[xmlParser release];
	}
	
	xmlParser = [[NSXMLParser alloc] initWithData: webData];
	[xmlParser setDelegate: self];
	[xmlParser setShouldResolveExternalEntities: YES];
	[xmlParser parse];
	
	[connection release];
	//[webData release];
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *) namespaceURI qualifiedName:(NSString *)qName
   attributes: (NSDictionary *)attributeDict
{
	//NSLog(@"4 parser didStarElemen: namespaceURI: attributes:");
    
    if( [elementName isEqualToString:@"HelloWorldResult"])
	{
		if(!soapResults)
		{
			soapResults = [[NSMutableString alloc] init];
		}
		recordResults = YES;
	}
	
}
-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	//NSLog(@"5 parser: foundCharacters:");
    
	if( recordResults )
	{
		[soapResults appendString: string];
	}
}
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	//NSLog(@"6 parser: didEndElement:");
    
	if( [elementName isEqualToString:@"HelloWorldResult"])
	{
		recordResults = FALSE;
		NSString *strResult = [NSString stringWithFormat:@"Result is: %@", soapResults];
        
        [dbDelegate CreateTableByXML:[soapResults dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSLog(@"%@", strResult);
       // [strResult release];
        
		//[soapResults release];
		soapResults = nil;

        
	}
	
}

@end
