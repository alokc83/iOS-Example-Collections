//
//  UtilGameCenter.m
//  RPS
//
//  Created by Bear Cahill on 9/7/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "UtilGameCenter.h"


@implementation UtilGameCenter

@synthesize gameCenterFeaturesEnabled;
@synthesize friendsList;

//GKLocalPlayer - playerID (persistent), alias, underage
// - performs auth, access friends list

// GKPlayer - playerID (persistent), keep track of players, associate data w/ players
// - alias - display name

// GKScore - set value, set category (if using multiple leaderboards)
// cache for later if network unavailable
// - value, formattedValue, category, date, player, rank

// GKLeaderboard - 

// GKLeaderboardViewController - 

// Matching
// GKMatchRequest - min/max players, player group, player attribute
// GKMatchmaker
// GKMatchmakerViewController

-(void)authenticate;
{
    GKLocalPlayer *locPlayer = [GKLocalPlayer localPlayer];

    [locPlayer authenticateWithCompletionHandler:^(NSError *error) 
    {
        NSLog(@"Authenticate response error: %@", error);
        if (!error)
            self.gameCenterFeaturesEnabled = YES;
        else
            self.gameCenterFeaturesEnabled = NO;
    }];
}

-(void)fetchFriendsList;
{
    GKLocalPlayer *locPlayer = [GKLocalPlayer localPlayer];

    [locPlayer loadFriendsWithCompletionHandler:^(NSArray *friends, NSError *error) {
        if (friends)
            self.friendsList = friends;
        else
            // handle error
            self.friendsList = nil;
    }];
}

-(void)archiveScoreToSendLater:(NSData*)score;
{
    if (nil == archivedScoresToSendLater)
        archivedScoresToSendLater = [NSMutableArray arrayWithCapacity:5];
    
    [archivedScoresToSendLater addObject:score];
}

-(void)archiveAchievementToSendLater:(NSData*)achievement;
{
    if (nil == archivedAchievementsToSendLater)
        archivedAchievementsToSendLater = [NSMutableArray arrayWithCapacity:5];
    
    [archivedAchievementsToSendLater addObject:achievement];
}

-(void)reportScore:(int)score;
{
    GKScore *theScore = [[GKScore alloc] init];
    
    theScore.value = score;
    [theScore reportScoreWithCompletionHandler:^(NSError *error) 
    {
        if (error)
        {
            NSData *archivedScore = [NSKeyedArchiver 
                                     archivedDataWithRootObject:theScore];
            [self archiveScoreToSendLater:archivedScore];
        }
    }];
}

-(void)showLeaderboardToVC:(UIViewController*)displayWithVC 
               forCategory:(NSString*)cat;
{
    GKLeaderboardViewController *vcLeaderboard = 
        [[GKLeaderboardViewController alloc] init]; 
    vcLeaderboard.timeScope = GKLeaderboardTimeScopeAllTime;
    vcLeaderboard.leaderboardDelegate = self;
    vcLeaderboard.category = cat;
    [displayWithVC 
        presentModalViewController:vcLeaderboard animated:YES];
}

- (void)leaderboardViewControllerDidFinish:
            (GKLeaderboardViewController *)viewController
{
    [viewController.parentViewController 
        dismissModalViewControllerAnimated:YES];
}

-(void)reportPercentage:(int)percentage ofAchievement:(NSString*)achievementID;
{
    GKAchievement *theAch = [[GKAchievement alloc] 
                              initWithIdentifier:achievementID];
    theAch.percentComplete = percentage;
    [theAch reportAchievementWithCompletionHandler:^(NSError *error) {
        if (error)
        {
            NSData *archiveAch = [NSKeyedArchiver 
                                  archivedDataWithRootObject:theAch];
            [self archiveAchievementToSendLater:archiveAch];
        } else {
            // NOTE: successful - will unhide it
        }
    }];
}

-(void)showAchievementsToVC:(UIViewController*)displayWithVC;
{
    GKAchievementViewController *vcAchievements = [[GKAchievementViewController alloc] init];
    vcAchievements.achievementDelegate = self;
    [displayWithVC presentModalViewController:vcAchievements animated:YES];
}

- (void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
    [viewController.parentViewController dismissModalViewControllerAnimated:YES];
}

static NSObject *matchDel;
-(void)fetchMatchWithMatchDelegate:(id)del;
{
    GKMatchRequest *req = [[GKMatchRequest alloc] init];
    req.minPlayers = 2;
    req.maxPlayers = 2;
    req.playerGroup = 1;
    
    matchDel = del;
    
    GKMatchmaker *mmaker = [[GKMatchmaker alloc] init];
    [mmaker findMatchForRequest:req withCompletionHandler:^(GKMatch *match, NSError *error) 
     {
         if (!error)
         {
             gameMatch = match;
             [gameMatch setDelegate:(id)matchDel];
         }
         else
         {
             // handle error
         }
     }];
}

-(void)inviteMatchWithMatchDelegate:(id)del;
{
    GKMatchRequest *req = [[GKMatchRequest alloc] init];
    req.minPlayers = 2;
    req.maxPlayers = 2;
    req.playerGroup = 1;
    
    GKMatchmakerViewController *vcMMaker = [[GKMatchmakerViewController alloc] initWithMatchRequest:req];
    [vcMMaker setMatchmakerDelegate:del];
    [del presentModalViewController:vcMMaker animated:YES];
}


- (id)init {
    if ((self = [super init])) {
        [self authenticate];
    }
    
    return self;
}


@end
