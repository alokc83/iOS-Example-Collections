//
//  UtiliTunes.m
//  iTunesAPIDemo
//
//  Created by Bear Cahill on 1/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UtiliTunes.h"
#import "JSON.h"

@implementation UtiliTunes

static AVAudioPlayer *aAudioPlayer;

+(NSArray*)searchFor:(NSString*)searchText ofType:(NSString*)type;
{
	searchText = [searchText stringByReplacingOccurrencesOfString:@" " withString:@"+"];
	NSString *url = [NSString stringWithFormat:@"http://ax.itunes.apple.com/WebObjects/MZStoreServices.woa/wa/wsSearch?term=%@&entity=%@", searchText, type];
	NSLog(@"query url: %@", url);
	
	NSError *error;
	NSString *search = [NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSUTF8StringEncoding error:&error];
	
	search = [search stringByReplacingOccurrencesOfString:@"\\n" withString:@""];
	NSDictionary *dict = [search JSONValue];
	return [dict objectForKey:@"results"];	
}

+(NSArray*)searchMusicTracksFor:(NSString*)searchText;
{
	return [UtiliTunes searchFor:searchText ofType:@"musicTrack"];
}

+(void)playSound:(NSString*)aFilePath
{
	if (nil != aAudioPlayer)
	{
		[aAudioPlayer stop];
		[aAudioPlayer release];
	}
	aAudioPlayer =[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:aFilePath] error:NULL];
	[aAudioPlayer stop];
	[aAudioPlayer play];
}

+(void)playPreviewWithTrackDict:(NSDictionary*)dict;
{
	NSData *fileData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[dict objectForKey:@"previewUrl"]]];
	NSString *path = [NSString stringWithFormat:@"%@/soundTrack.mp4", [[NSBundle mainBundle] bundlePath]];
	[fileData writeToFile:path atomically:YES];
	[self playSound:path];
}

+(void)loadiTunesWithTrackDict:(NSDictionary*)dict;
{
	NSString *url = [dict objectForKey:@"trackViewUrl"];
	url = [url stringByReplacingOccurrencesOfString:@"http" withString:@"itms"];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];	
}

@end
