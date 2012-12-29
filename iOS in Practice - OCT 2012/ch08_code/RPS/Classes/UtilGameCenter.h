//
//  UtilGameCenter.h
//  RPS
//
//  Created by Bear Cahill on 9/7/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@interface UtilGameCenter : NSObject <GKLeaderboardViewControllerDelegate, GKAchievementViewControllerDelegate, UINavigationControllerDelegate> {

    bool gameCenterFeaturesEnabled;
    NSArray *friendsList;
    NSMutableArray *archivedScoresToSendLater;
    NSMutableArray *archivedAchievementsToSendLater;
    
    GKMatch *gameMatch;
}
@property (nonatomic, assign) bool gameCenterFeaturesEnabled;
@property (nonatomic, retain) NSArray *friendsList;

-(void)fetchFriendsList;
-(void)reportScore:(int)score;
-(void)showLeaderboardToVC:(UIViewController*)displayWithVC forCategory:(NSString*)cat;
-(void)reportPercentage:(int)percentage ofAchievement:(NSString*)achievementID;
-(void)showAchievementsToVC:(UIViewController*)displayWithVC;

-(void)fetchMatchWithMatchDelegate:(id)del;
-(void)inviteMatchWithMatchDelegate:(id)del;


@end
