#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <cstrike>
#include <eItems>
#include <smlib>
#include <navmesh>
#include <dhooks>
#include <botmimic>
#include <PTaH>
#include <ripext>

char g_szMap[128];
char g_szCrosshairCode[MAXPLAYERS+1][35], g_szPreviousBuy[MAXPLAYERS+1][128];
bool g_bIsBombScenario, g_bIsHostageScenario, g_bFreezetimeEnd, g_bBombPlanted, g_bEveryoneDead, g_bHalftimeSwitch, g_bIsCompetitive;
bool g_bUseCZ75[MAXPLAYERS+1], g_bUseUSP[MAXPLAYERS+1], g_bUseM4A1S[MAXPLAYERS+1], g_bDontSwitch[MAXPLAYERS+1], g_bDropWeapon[MAXPLAYERS+1], g_bHasGottenDrop[MAXPLAYERS+1];
bool g_bIsProBot[MAXPLAYERS+1], g_bThrowGrenade[MAXPLAYERS+1], g_bUncrouch[MAXPLAYERS+1];
int g_iProfileRank[MAXPLAYERS+1], g_iPlayerColor[MAXPLAYERS+1], g_iTarget[MAXPLAYERS+1], g_iPrevTarget[MAXPLAYERS+1], g_iDoingSmokeNum[MAXPLAYERS+1], g_iActiveWeapon[MAXPLAYERS+1];
int g_iCurrentRound, g_iRoundsPlayed, g_iCTScore, g_iTScore, g_iMaxNades;
int g_iProfileRankOffset, g_iPlayerColorOffset;
int g_iBotTargetSpotOffset, g_iBotNearbyEnemiesOffset, g_iFireWeaponOffset, g_iEnemyVisibleOffset, g_iBotProfileOffset, g_iBotSafeTimeOffset, g_iBotEnemyOffset, g_iBotLookAtSpotStateOffset, g_iBotMoraleOffset, g_iBotTaskOffset, g_iBotDispositionOffset;
float g_fBotOrigin[MAXPLAYERS+1][3], g_fTargetPos[MAXPLAYERS+1][3], g_fNadeTarget[MAXPLAYERS+1][3];
float g_fRoundStart, g_fFreezeTimeEnd;
float g_fLookAngleMaxAccel[MAXPLAYERS+1], g_fReactionTime[MAXPLAYERS+1], g_fAggression[MAXPLAYERS+1], g_fShootTimestamp[MAXPLAYERS+1], g_fThrowNadeTimestamp[MAXPLAYERS+1], g_fCrouchTimestamp[MAXPLAYERS+1];
ConVar g_cvBotEcoLimit;
Handle g_hBotMoveTo;
Handle g_hLookupBone;
Handle g_hGetBonePosition;
Handle g_hBotIsVisible;
Handle g_hBotIsHiding;
Handle g_hBotEquipBestWeapon;
Handle g_hBotSetLookAt;
Handle g_hSetCrosshairCode;
Handle g_hSwitchWeaponCall;
Handle g_hIsLineBlockedBySmoke;
Handle g_hBotBendLineOfSight;
Handle g_hBotThrowGrenade;
Address g_pTheBots;
CNavArea g_pCurrArea[MAXPLAYERS+1];

//BOT Nades Variables
float g_fNadePos[128][3], g_fNadeLook[128][3];
int g_iNadeDefIndex[128];
char g_szReplay[128][128];
float g_fNadeTimestamp[128];
int g_iNadeTeam[128];

static char g_szBoneNames[][] =  {
	"neck_0", 
	"pelvis", 
	"spine_0", 
	"spine_1", 
	"spine_2", 
	"spine_3", 
	"clavicle_l",
	"clavicle_r",
	"arm_upper_L", 
	"arm_lower_L", 
	"hand_L", 
	"arm_upper_R", 
	"arm_lower_R", 
	"hand_R", 
	"leg_upper_L",  
	"leg_lower_L", 
	"ankle_L",
	"leg_upper_R", 
	"leg_lower_R",
	"ankle_R"
};

enum RouteType
{
	DEFAULT_ROUTE = 0, 
	FASTEST_ROUTE, 
	SAFEST_ROUTE, 
	RETREAT_ROUTE
}

enum PriorityType
{
	PRIORITY_LOWEST = -1,
	PRIORITY_LOW, 
	PRIORITY_MEDIUM, 
	PRIORITY_HIGH, 
	PRIORITY_UNINTERRUPTABLE
}

enum LookAtSpotState
{
	NOT_LOOKING_AT_SPOT,			///< not currently looking at a point in space
	LOOK_TOWARDS_SPOT,				///< in the process of aiming at m_lookAtSpot
	LOOK_AT_SPOT,					///< looking at m_lookAtSpot
	NUM_LOOK_AT_SPOT_STATES
}

enum GrenadeTossState
{
	NOT_THROWING,				///< not yet throwing
	START_THROW,				///< lining up throw
	THROW_LINED_UP,				///< pause for a moment when on-line
	FINISH_THROW				///< throwing
}

enum TaskType
{
	SEEK_AND_DESTROY,
	PLANT_BOMB,
	FIND_TICKING_BOMB,
	DEFUSE_BOMB,
	GUARD_TICKING_BOMB,
	GUARD_BOMB_DEFUSER,
	GUARD_LOOSE_BOMB,
	GUARD_BOMB_ZONE,
	GUARD_INITIAL_ENCOUNTER,
	ESCAPE_FROM_BOMB,
	HOLD_POSITION,
	FOLLOW,
	VIP_ESCAPE,
	GUARD_VIP_ESCAPE_ZONE,
	COLLECT_HOSTAGES,
	RESCUE_HOSTAGES,
	GUARD_HOSTAGES,
	GUARD_HOSTAGE_RESCUE_ZONE,
	MOVE_TO_LAST_KNOWN_ENEMY_POSITION,
	MOVE_TO_SNIPER_SPOT,
	SNIPING,
	ESCAPE_FROM_FLAMES,
	NUM_TASKS
}

enum DispositionType
{
	ENGAGE_AND_INVESTIGATE,								///< engage enemies on sight and investigate enemy noises
	OPPORTUNITY_FIRE,									///< engage enemies on sight, but only look towards enemy noises, dont investigate
	SELF_DEFENSE,										///< only engage if fired on, or very close to enemy
	IGNORE_ENEMIES,										///< ignore all enemies - useful for ducking around corners, running away, etc
	NUM_DISPOSITIONS
}

enum GamePhase
{
	GAMEPHASE_WARMUP_ROUND,
	GAMEPHASE_PLAYING_STANDARD,	
	GAMEPHASE_PLAYING_FIRST_HALF,
	GAMEPHASE_PLAYING_SECOND_HALF,
	GAMEPHASE_HALFTIME,
	GAMEPHASE_MATCH_ENDED,    
	GAMEPHASE_MAX
}

public Plugin myinfo = 
{
	name = "BOT Improvement", 
	author = "manico", 
	description = "Improves bots and does other things.", 
	version = "1.0.7", 
	url = "http://steamcommunity.com/id/manico001"
};

public void OnPluginStart()
{	
	g_bIsCompetitive = FindConVar("game_mode").IntValue == 1 && FindConVar("game_type").IntValue == 0 ? true : false;

	HookEventEx("player_spawn", OnPlayerSpawn);
	HookEventEx("round_prestart", OnRoundPreStart);
	HookEventEx("round_start", OnRoundStart);
	HookEventEx("round_end", OnRoundEnd);
	HookEventEx("round_freeze_end", OnFreezetimeEnd);
	HookEventEx("weapon_zoom", OnWeaponZoom);
	HookEventEx("weapon_fire", OnWeaponFire);
	
	LoadSDK();
	LoadDetours();
	
	g_cvBotEcoLimit = FindConVar("bot_eco_limit");
	
	RegConsoleCmd("team", Command_Team);
}

public Action Command_Team(int client, int iArgs)
{
	char szTeamArg[12], szSideArg[12];
	GetCmdArg(1, szTeamArg, sizeof(szTeamArg));
	GetCmdArg(2, szSideArg, sizeof(szSideArg));
	
	if(strcmp(szTeamArg, "NiP", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "r1nkle");
			ServerCommand("bot_add_ct %s", "arrozdoce");
			ServerCommand("bot_add_ct %s", "ewjerkz");
			ServerCommand("bot_add_ct %s", "sjuush");
			ServerCommand("bot_add_ct %s", "Snappi");
			ServerCommand("mp_teamlogo_1 nip");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "r1nkle");
			ServerCommand("bot_add_t %s", "arrozdoce");
			ServerCommand("bot_add_t %s", "ewjerkz");
			ServerCommand("bot_add_t %s", "sjuush");
			ServerCommand("bot_add_t %s", "Snappi");
			ServerCommand("mp_teamlogo_2 nip");
		}
	}
	
	if(strcmp(szTeamArg, "MIBR", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Lucaozy");
			ServerCommand("bot_add_ct %s", "saffee");
			ServerCommand("bot_add_ct %s", "brnz4n");
			ServerCommand("bot_add_ct %s", "insani");
			ServerCommand("bot_add_ct %s", "exit");
			ServerCommand("mp_teamlogo_1 mibr");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Lucaozy");
			ServerCommand("bot_add_t %s", "saffee");
			ServerCommand("bot_add_t %s", "brnz4n");
			ServerCommand("bot_add_t %s", "insani");
			ServerCommand("bot_add_t %s", "exit");
			ServerCommand("mp_teamlogo_2 mibr");
		}
	}
	
	if(strcmp(szTeamArg, "FaZe", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "frozen");
			ServerCommand("bot_add_ct %s", "broky");
			ServerCommand("bot_add_ct %s", "karrigan");
			ServerCommand("bot_add_ct %s", "rain");
			ServerCommand("bot_add_ct %s", "EliGE");
			ServerCommand("mp_teamlogo_1 faze");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "frozen");
			ServerCommand("bot_add_t %s", "broky");
			ServerCommand("bot_add_t %s", "karrigan");
			ServerCommand("bot_add_t %s", "rain");
			ServerCommand("bot_add_t %s", "EliGE");
			ServerCommand("mp_teamlogo_2 faze");
		}
	}
	
	if(strcmp(szTeamArg, "Astralis", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "stavn");
			ServerCommand("bot_add_ct %s", "dev1ce");
			ServerCommand("bot_add_ct %s", "Staehr");
			ServerCommand("bot_add_ct %s", "jabbi");
			ServerCommand("bot_add_ct %s", "cadiaN");
			ServerCommand("mp_teamlogo_1 astr");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "stavn");
			ServerCommand("bot_add_t %s", "dev1ce");
			ServerCommand("bot_add_t %s", "Staehr");
			ServerCommand("bot_add_t %s", "jabbi");
			ServerCommand("bot_add_t %s", "cadiaN");
			ServerCommand("mp_teamlogo_2 astr");
		}
	}
	
	if(strcmp(szTeamArg, "MASONIC", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Froslev");
			ServerCommand("bot_add_ct %s", "Botman");
			ServerCommand("bot_add_ct %s", "grumpMonk");
			ServerCommand("bot_add_ct %s", "Noruyp");
			ServerCommand("bot_add_ct %s", "Bukhavez");
			ServerCommand("mp_teamlogo_1 maso");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Froslev");
			ServerCommand("bot_add_t %s", "Botman");
			ServerCommand("bot_add_t %s", "grumpMonk");
			ServerCommand("bot_add_t %s", "Noruyp");
			ServerCommand("bot_add_t %s", "Bukhavez");
			ServerCommand("mp_teamlogo_2 maso");
		}
	}
	
	if(strcmp(szTeamArg, "G2", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "huNter-");
			ServerCommand("bot_add_ct %s", "m0NESY");
			ServerCommand("bot_add_ct %s", "malbsMd");
			ServerCommand("bot_add_ct %s", "Snax");
			ServerCommand("bot_add_ct %s", "HeavyGod");
			ServerCommand("mp_teamlogo_1 g2");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "huNter-");
			ServerCommand("bot_add_t %s", "m0NESY");
			ServerCommand("bot_add_t %s", "malbsMd");
			ServerCommand("bot_add_t %s", "Snax");
			ServerCommand("bot_add_t %s", "HeavyGod");
			ServerCommand("mp_teamlogo_2 g2");
		}
	}
	
	if(strcmp(szTeamArg, "fnatic", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "matys");
			ServerCommand("bot_add_ct %s", "fear");
			ServerCommand("bot_add_ct %s", "KRIMZ");
			ServerCommand("bot_add_ct %s", "blameF");
			ServerCommand("bot_add_ct %s", "Burmylov");
			ServerCommand("mp_teamlogo_1 fntc");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "matys");
			ServerCommand("bot_add_t %s", "fear");
			ServerCommand("bot_add_t %s", "KRIMZ");
			ServerCommand("bot_add_t %s", "blameF");
			ServerCommand("bot_add_t %s", "Burmylov");
			ServerCommand("mp_teamlogo_2 fntc");
		}
	}
	
	if(strcmp(szTeamArg, "Dynamo", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "M1key");
			ServerCommand("bot_add_ct %s", "forsyy");
			ServerCommand("bot_add_ct %s", "Dytor");
			ServerCommand("bot_add_ct %s", "\"The eLiVe\"");
			ServerCommand("bot_add_ct %s", "nbqq");
			ServerCommand("mp_teamlogo_1 dyna");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "M1key");
			ServerCommand("bot_add_t %s", "forsyy");
			ServerCommand("bot_add_t %s", "Dytor");
			ServerCommand("bot_add_t %s", "\"The eLiVe\"");
			ServerCommand("bot_add_t %s", "nbqq");
			ServerCommand("mp_teamlogo_2 dyna");
		}
	}
	
	if(strcmp(szTeamArg, "mouz", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Spinx");
			ServerCommand("bot_add_ct %s", "torzsi");
			ServerCommand("bot_add_ct %s", "xertioN");
			ServerCommand("bot_add_ct %s", "Brollan");
			ServerCommand("bot_add_ct %s", "Jimpphat");
			ServerCommand("mp_teamlogo_1 mouz");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Spinx");
			ServerCommand("bot_add_t %s", "torzsi");
			ServerCommand("bot_add_t %s", "xertioN");
			ServerCommand("bot_add_t %s", "Brollan");
			ServerCommand("bot_add_t %s", "Jimpphat");
			ServerCommand("mp_teamlogo_2 mouz");
		}
	}
	
	if(strcmp(szTeamArg, "TYLOO", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "advent");
			ServerCommand("bot_add_ct %s", "Mercury");
			ServerCommand("bot_add_ct %s", "JamYoung");
			ServerCommand("bot_add_ct %s", "Moseyuh");
			ServerCommand("bot_add_ct %s", "Jee");
			ServerCommand("mp_teamlogo_1 tyl");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "advent");
			ServerCommand("bot_add_t %s", "Mercury");
			ServerCommand("bot_add_t %s", "JamYoung");
			ServerCommand("bot_add_t %s", "Moseyuh");
			ServerCommand("bot_add_t %s", "Jee");
			ServerCommand("mp_teamlogo_2 tyl");
		}
	}
	
	if(strcmp(szTeamArg, "NaVi", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Aleksib");
			ServerCommand("bot_add_ct %s", "w0nderful");
			ServerCommand("bot_add_ct %s", "B1T");
			ServerCommand("bot_add_ct %s", "jL");
			ServerCommand("bot_add_ct %s", "iM");
			ServerCommand("mp_teamlogo_1 navi");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Aleksib");
			ServerCommand("bot_add_t %s", "w0nderful");
			ServerCommand("bot_add_t %s", "B1T");
			ServerCommand("bot_add_t %s", "jL");
			ServerCommand("bot_add_t %s", "iM");
			ServerCommand("mp_teamlogo_2 navi");
		}
	}
	
	if(strcmp(szTeamArg, "Liquid", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "ultimate");
			ServerCommand("bot_add_ct %s", "jks");
			ServerCommand("bot_add_ct %s", "Twistzz");
			ServerCommand("bot_add_ct %s", "NertZ");
			ServerCommand("bot_add_ct %s", "NAF");
			ServerCommand("mp_teamlogo_1 liq");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "ultimate");
			ServerCommand("bot_add_t %s", "jks");
			ServerCommand("bot_add_t %s", "Twistzz");
			ServerCommand("bot_add_t %s", "NertZ");
			ServerCommand("bot_add_t %s", "NAF");
			ServerCommand("mp_teamlogo_2 liq");
		}
	}
	
	if(strcmp(szTeamArg, "ENCE", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "gla1ve");
			ServerCommand("bot_add_ct %s", "sdy");
			ServerCommand("bot_add_ct %s", "podi");
			ServerCommand("bot_add_ct %s", "xKacpersky");
			ServerCommand("bot_add_ct %s", "Neityu");
			ServerCommand("mp_teamlogo_1 ence");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "gla1ve");
			ServerCommand("bot_add_t %s", "sdy");
			ServerCommand("bot_add_t %s", "podi");
			ServerCommand("bot_add_t %s", "xKacpersky");
			ServerCommand("bot_add_t %s", "Neityu");
			ServerCommand("mp_teamlogo_2 ence");
		}
	}
	
	if(strcmp(szTeamArg, "Vitality", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "flameZ");
			ServerCommand("bot_add_ct %s", "ZywOo");
			ServerCommand("bot_add_ct %s", "apEX");
			ServerCommand("bot_add_ct %s", "mezii");
			ServerCommand("bot_add_ct %s", "ropz");
			ServerCommand("mp_teamlogo_1 vita");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "flameZ");
			ServerCommand("bot_add_t %s", "ZywOo");
			ServerCommand("bot_add_t %s", "apEX");
			ServerCommand("bot_add_t %s", "mezii");
			ServerCommand("bot_add_t %s", "ropz");
			ServerCommand("mp_teamlogo_2 vita");
		}
	}
	
	if(strcmp(szTeamArg, "BIG", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "hyped");
			ServerCommand("bot_add_ct %s", "kyuubii");
			ServerCommand("bot_add_ct %s", "JDC");
			ServerCommand("bot_add_ct %s", "tabseN");
			ServerCommand("bot_add_ct %s", "Krimbo");
			ServerCommand("mp_teamlogo_1 big");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "hyped");
			ServerCommand("bot_add_t %s", "kyuubii");
			ServerCommand("bot_add_t %s", "JDC");
			ServerCommand("bot_add_t %s", "tabseN");
			ServerCommand("bot_add_t %s", "Krimbo");
			ServerCommand("mp_teamlogo_2 big");
		}
	}
	
	if(strcmp(szTeamArg, "FURIA", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "yuurih");
			ServerCommand("bot_add_ct %s", "FalleN");
			ServerCommand("bot_add_ct %s", "chelo");
			ServerCommand("bot_add_ct %s", "KSCERATO");
			ServerCommand("bot_add_ct %s", "skullz");
			ServerCommand("mp_teamlogo_1 furi");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "yuurih");
			ServerCommand("bot_add_t %s", "FalleN");
			ServerCommand("bot_add_t %s", "chelo");
			ServerCommand("bot_add_t %s", "KSCERATO");
			ServerCommand("bot_add_t %s", "skullz");
			ServerCommand("mp_teamlogo_2 furi");
		}
	}
	
	if(strcmp(szTeamArg, "coL", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "JT");
			ServerCommand("bot_add_ct %s", "hallzerk");
			ServerCommand("bot_add_ct %s", "cxzi");
			ServerCommand("bot_add_ct %s", "nicx");
			ServerCommand("bot_add_ct %s", "Grim");
			ServerCommand("mp_teamlogo_1 comp");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "JT");
			ServerCommand("bot_add_t %s", "hallzerk");
			ServerCommand("bot_add_t %s", "cxzi");
			ServerCommand("bot_add_t %s", "nicx");
			ServerCommand("bot_add_t %s", "Grim");
			ServerCommand("mp_teamlogo_2 comp");
		}
	}
	
	if(strcmp(szTeamArg, "B8", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "headtr1ck");
			ServerCommand("bot_add_ct %s", "alex666");
			ServerCommand("bot_add_ct %s", "kensizor");
			ServerCommand("bot_add_ct %s", "npl");
			ServerCommand("bot_add_ct %s", "esenthial");
			ServerCommand("mp_teamlogo_1 b8");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "headtr1ck");
			ServerCommand("bot_add_t %s", "alex666");
			ServerCommand("bot_add_t %s", "kensizor");
			ServerCommand("bot_add_t %s", "npl");
			ServerCommand("bot_add_t %s", "esenthial");
			ServerCommand("mp_teamlogo_2 b8");
		}
	}
	
	if(strcmp(szTeamArg, "Heroic", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "SunPayus");
			ServerCommand("bot_add_ct %s", "LNZ");
			ServerCommand("bot_add_ct %s", "yxngstxr");
			ServerCommand("bot_add_ct %s", "xfl0ud");
			ServerCommand("bot_add_ct %s", "tN1R");
			ServerCommand("mp_teamlogo_1 heroi");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "SunPayus");
			ServerCommand("bot_add_t %s", "LNZ");
			ServerCommand("bot_add_t %s", "yxngstxr");
			ServerCommand("bot_add_t %s", "xfl0ud");
			ServerCommand("bot_add_t %s", "tN1R");
			ServerCommand("mp_teamlogo_2 heroi");
		}
	}
	
	if(strcmp(szTeamArg, "VP", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "electroNic");
			ServerCommand("bot_add_ct %s", "FL4MUS");
			ServerCommand("bot_add_ct %s", "ICY");
			ServerCommand("bot_add_ct %s", "FL1T");
			ServerCommand("bot_add_ct %s", "fame");
			ServerCommand("mp_teamlogo_1 vp");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "electroNic");
			ServerCommand("bot_add_t %s", "FL4MUS");
			ServerCommand("bot_add_t %s", "ICY");
			ServerCommand("bot_add_t %s", "FL1T");
			ServerCommand("bot_add_t %s", "fame");
			ServerCommand("mp_teamlogo_2 vp");
		}
	}
	
	if(strcmp(szTeamArg, "HAVU", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "ottob");
			ServerCommand("bot_add_ct %s", "p3kko");
			ServerCommand("bot_add_ct %s", "uli");
			ServerCommand("bot_add_ct %s", "puuha");
			ServerCommand("bot_add_ct %s", "Alxc");
			ServerCommand("mp_teamlogo_1 havu");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "ottob");
			ServerCommand("bot_add_t %s", "p3kko");
			ServerCommand("bot_add_t %s", "uli");
			ServerCommand("bot_add_t %s", "puuha");
			ServerCommand("bot_add_t %s", "Alxc");
			ServerCommand("mp_teamlogo_2 havu");
		}
	}
	
	if(strcmp(szTeamArg, "ECSTATIC", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "kristou");
			ServerCommand("bot_add_ct %s", "Anlelele");
			ServerCommand("bot_add_ct %s", "\"nut nut\"");
			ServerCommand("bot_add_ct %s", "TMB");
			ServerCommand("bot_add_ct %s", "sirah");
			ServerCommand("mp_teamlogo_1 ecs");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "kristou");
			ServerCommand("bot_add_t %s", "Anlelele");
			ServerCommand("bot_add_t %s", "\"nut nut\"");
			ServerCommand("bot_add_t %s", "TMB");
			ServerCommand("bot_add_t %s", "sirah");
			ServerCommand("mp_teamlogo_2 ecs");
		}
	}
	
	if(strcmp(szTeamArg, "Nexus", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "BTN");
			ServerCommand("bot_add_ct %s", "XELLOW");
			ServerCommand("bot_add_ct %s", "ragga");
			ServerCommand("bot_add_ct %s", "s0und");
			ServerCommand("bot_add_ct %s", "lauNX");
			ServerCommand("mp_teamlogo_1 nex");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "BTN");
			ServerCommand("bot_add_t %s", "XELLOW");
			ServerCommand("bot_add_t %s", "ragga");
			ServerCommand("bot_add_t %s", "s0und");
			ServerCommand("bot_add_t %s", "lauNX");
			ServerCommand("mp_teamlogo_2 nex");
		}
	}
	
	if(strcmp(szTeamArg, "MongolZ", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Techno4K");
			ServerCommand("bot_add_ct %s", "bLitz");
			ServerCommand("bot_add_ct %s", "Senzu");
			ServerCommand("bot_add_ct %s", "mzinho");
			ServerCommand("bot_add_ct %s", "910");
			ServerCommand("mp_teamlogo_1 mngz");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Techno4K");
			ServerCommand("bot_add_t %s", "bLitz");
			ServerCommand("bot_add_t %s", "Senzu");
			ServerCommand("bot_add_t %s", "mzinho");
			ServerCommand("bot_add_t %s", "910");
			ServerCommand("mp_teamlogo_2 mngz");
		}
	}
	
	if(strcmp(szTeamArg, "aTTaX", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "FoG");
			ServerCommand("bot_add_ct %s", "OneLion");
			ServerCommand("bot_add_ct %s", "Askan");
			ServerCommand("bot_add_ct %s", "hayanh");
			ServerCommand("bot_add_ct %s", "Cl34v3rs");
			ServerCommand("mp_teamlogo_1 attax");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "FoG");
			ServerCommand("bot_add_t %s", "OneLion");
			ServerCommand("bot_add_t %s", "Askan");
			ServerCommand("bot_add_t %s", "hayanh");
			ServerCommand("bot_add_t %s", "Cl34v3rs");
			ServerCommand("mp_teamlogo_2 attax");
		}
	}
	
	if(strcmp(szTeamArg, "paiN", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "nqz");
			ServerCommand("bot_add_ct %s", "Snowzin");
			ServerCommand("bot_add_ct %s", "dav1deuS");
			ServerCommand("bot_add_ct %s", "biguzera");
			ServerCommand("bot_add_ct %s", "kauez");
			ServerCommand("mp_teamlogo_1 pain");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "nqz");
			ServerCommand("bot_add_t %s", "Snowzin");
			ServerCommand("bot_add_t %s", "dav1deuS");
			ServerCommand("bot_add_t %s", "biguzera");
			ServerCommand("bot_add_t %s", "kauez");
			ServerCommand("mp_teamlogo_2 pain");
		}
	}
	
	if(strcmp(szTeamArg, "Sharks", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "doczin");
			ServerCommand("bot_add_ct %s", "gafolo");
			ServerCommand("bot_add_ct %s", "rdnzao");
			ServerCommand("bot_add_ct %s", "koala");
			ServerCommand("bot_add_ct %s", "Nicks");
			ServerCommand("mp_teamlogo_1 shark");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "doczin");
			ServerCommand("bot_add_t %s", "gafolo");
			ServerCommand("bot_add_t %s", "rdnzao");
			ServerCommand("bot_add_t %s", "koala");
			ServerCommand("bot_add_t %s", "Nicks");
			ServerCommand("mp_teamlogo_2 shark");
		}
	}
	
	if(strcmp(szTeamArg, "9ine", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "raalz");
			ServerCommand("bot_add_ct %s", "mantuu");
			ServerCommand("bot_add_ct %s", "faveN");
			ServerCommand("bot_add_ct %s", "bobeksde");
			ServerCommand("bot_add_ct %s", "kraghen");
			ServerCommand("mp_teamlogo_1 nein");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "raalz");
			ServerCommand("bot_add_t %s", "mantuu");
			ServerCommand("bot_add_t %s", "faveN");
			ServerCommand("bot_add_t %s", "bobeksde");
			ServerCommand("bot_add_t %s", "kraghen");
			ServerCommand("mp_teamlogo_2 nein");
		}
	}
	
	if(strcmp(szTeamArg, "GamerLegion", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "sl3nd");
			ServerCommand("bot_add_ct %s", "ztr");
			ServerCommand("bot_add_ct %s", "Tauson");
			ServerCommand("bot_add_ct %s", "PR");
			ServerCommand("bot_add_ct %s", "REZ");
			ServerCommand("mp_teamlogo_1 gl");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "sl3nd");
			ServerCommand("bot_add_t %s", "ztr");
			ServerCommand("bot_add_t %s", "Tauson");
			ServerCommand("bot_add_t %s", "PR");
			ServerCommand("bot_add_t %s", "REZ");
			ServerCommand("mp_teamlogo_2 gl");
		}
	}
	
	if(strcmp(szTeamArg, "w7m", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "t9rnay");
			ServerCommand("bot_add_ct %s", "shz");
			ServerCommand("bot_add_ct %s", "JOTA");
			ServerCommand("bot_add_ct %s", "levi");
			ServerCommand("bot_add_ct %s", "fokiu");
			ServerCommand("mp_teamlogo_1 w7m");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "t9rnay");
			ServerCommand("bot_add_t %s", "shz");
			ServerCommand("bot_add_t %s", "JOTA");
			ServerCommand("bot_add_t %s", "levi");
			ServerCommand("bot_add_t %s", "fokiu");
			ServerCommand("mp_teamlogo_2 w7m");
		}
	}
	
	if(strcmp(szTeamArg, "Bravado", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Doru");
			ServerCommand("bot_add_ct %s", "FROZ3N");
			ServerCommand("bot_add_ct %s", "Triton");
			ServerCommand("bot_add_ct %s", "March");
			ServerCommand("bot_add_ct %s", "wilj");
			ServerCommand("mp_teamlogo_1 bravg");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Doru");
			ServerCommand("bot_add_t %s", "FROZ3N");
			ServerCommand("bot_add_t %s", "Triton");
			ServerCommand("bot_add_t %s", "March");
			ServerCommand("bot_add_t %s", "wilj");
			ServerCommand("mp_teamlogo_2 bravg");
		}
	}
	
	if(strcmp(szTeamArg, "SH", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "captainMo");
			ServerCommand("bot_add_ct %s", "AE");
			ServerCommand("bot_add_ct %s", "18yM");
			ServerCommand("bot_add_ct %s", "XiaosaGe");
			ServerCommand("bot_add_ct %s", "DD");
			ServerCommand("mp_teamlogo_1 sh");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "captainMo");
			ServerCommand("bot_add_t %s", "AE");
			ServerCommand("bot_add_t %s", "18yM");
			ServerCommand("bot_add_t %s", "XiaosaGe");
			ServerCommand("bot_add_t %s", "DD");
			ServerCommand("mp_teamlogo_2 sh");
		}
	}
	
	if(strcmp(szTeamArg, "Eternal", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "XANTARES");
			ServerCommand("bot_add_ct %s", "woxic");
			ServerCommand("bot_add_ct %s", "MAJ3R");
			ServerCommand("bot_add_ct %s", "jottAAA");
			ServerCommand("bot_add_ct %s", "Wicadia");
			ServerCommand("mp_teamlogo_1 eter");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "XANTARES");
			ServerCommand("bot_add_t %s", "woxic");
			ServerCommand("bot_add_t %s", "MAJ3R");
			ServerCommand("bot_add_t %s", "jottAAA");
			ServerCommand("bot_add_t %s", "Wicadia");
			ServerCommand("mp_teamlogo_2 eter");
		}
	}
	
	if(strcmp(szTeamArg, "BRUTE", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "vANO");
			ServerCommand("bot_add_ct %s", "w4rden");
			ServerCommand("bot_add_ct %s", "SiKO");
			ServerCommand("bot_add_ct %s", "realzen");
			ServerCommand("bot_add_ct %s", "N1KOLAJ");
			ServerCommand("mp_teamlogo_1 brut");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "vANO");
			ServerCommand("bot_add_t %s", "w4rden");
			ServerCommand("bot_add_t %s", "SiKO");
			ServerCommand("bot_add_t %s", "realzen");
			ServerCommand("bot_add_t %s", "N1KOLAJ");
			ServerCommand("mp_teamlogo_2 brut");
		}
	}
	
	if(strcmp(szTeamArg, "Nemiga", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "1eeR");
			ServerCommand("bot_add_ct %s", "khaN");
			ServerCommand("bot_add_ct %s", "zweih");
			ServerCommand("bot_add_ct %s", "riskyb0b");
			ServerCommand("bot_add_ct %s", "Xant3r");
			ServerCommand("mp_teamlogo_1 nem");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "1eeR");
			ServerCommand("bot_add_t %s", "khaN");
			ServerCommand("bot_add_t %s", "zweih");
			ServerCommand("bot_add_t %s", "riskyb0b");
			ServerCommand("bot_add_t %s", "Xant3r");
			ServerCommand("mp_teamlogo_2 nem");
		}
	}
	
	if(strcmp(szTeamArg, "Lynn", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "westmelon");
			ServerCommand("bot_add_ct %s", "z4kr");
			ServerCommand("bot_add_ct %s", "Starry");
			ServerCommand("bot_add_ct %s", "Emilia");
			ServerCommand("bot_add_ct %s", "C4LLM3SU3");
			ServerCommand("mp_teamlogo_1 lynn");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "westmelon");
			ServerCommand("bot_add_t %s", "z4kr");
			ServerCommand("bot_add_t %s", "Starry");
			ServerCommand("bot_add_t %s", "Emilia");
			ServerCommand("bot_add_t %s", "C4LLM3SU3");
			ServerCommand("mp_teamlogo_2 lynn");
		}
	}
	
	if(strcmp(szTeamArg, "Rhyno", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "aragornN");
			ServerCommand("bot_add_ct %s", "krazy");
			ServerCommand("bot_add_ct %s", "Icarus");
			ServerCommand("bot_add_ct %s", "seabraez");
			ServerCommand("bot_add_ct %s", "P3R3IIRA");
			ServerCommand("mp_teamlogo_1 rhy");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "aragornN");
			ServerCommand("bot_add_t %s", "krazy");
			ServerCommand("bot_add_t %s", "Icarus");
			ServerCommand("bot_add_t %s", "seabraez");
			ServerCommand("bot_add_t %s", "P3R3IIRA");
			ServerCommand("mp_teamlogo_2 rhy");
		}
	}
	
	if(strcmp(szTeamArg, "OG", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "MoDo");
			ServerCommand("bot_add_ct %s", "Chr1zN");
			ServerCommand("bot_add_ct %s", "Buzz");
			ServerCommand("bot_add_ct %s", "F1KU");
			ServerCommand("bot_add_ct %s", "spooke");
			ServerCommand("mp_teamlogo_1 og");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "MoDo");
			ServerCommand("bot_add_t %s", "Chr1zN");
			ServerCommand("bot_add_t %s", "Buzz");
			ServerCommand("bot_add_t %s", "F1KU");
			ServerCommand("bot_add_t %s", "spooke");
			ServerCommand("mp_teamlogo_2 og");
		}
	}
	
	if(strcmp(szTeamArg, "Endpoint", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Surreal");
			ServerCommand("bot_add_ct %s", "CRUC1AL");
			ServerCommand("bot_add_ct %s", "MiGHTYMAX");
			ServerCommand("bot_add_ct %s", "cej0t");
			ServerCommand("bot_add_ct %s", "AZUWU");
			ServerCommand("mp_teamlogo_1 endp");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Surreal");
			ServerCommand("bot_add_t %s", "CRUC1AL");
			ServerCommand("bot_add_t %s", "MiGHTYMAX");
			ServerCommand("bot_add_t %s", "cej0t");
			ServerCommand("bot_add_t %s", "AZUWU");
			ServerCommand("mp_teamlogo_2 endp");
		}
	}
	
	if(strcmp(szTeamArg, "sAw", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Ag1l");
			ServerCommand("bot_add_ct %s", "story");
			ServerCommand("bot_add_ct %s", "cej0t");
			ServerCommand("bot_add_ct %s", "MUTiRiS");
			ServerCommand("bot_add_ct %s", "AZUWU");
			ServerCommand("mp_teamlogo_1 saw");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Ag1l");
			ServerCommand("bot_add_t %s", "story");
			ServerCommand("bot_add_t %s", "cej0t");
			ServerCommand("bot_add_t %s", "MUTiRiS");
			ServerCommand("bot_add_t %s", "AZUWU");
			ServerCommand("mp_teamlogo_2 saw");
		}
	}
	
	if(strcmp(szTeamArg, "Alliance", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "PlesseN");
			ServerCommand("bot_add_ct %s", "upE");
			ServerCommand("bot_add_ct %s", "eraa");
			ServerCommand("bot_add_ct %s", "avid");
			ServerCommand("bot_add_ct %s", "twist");
			ServerCommand("mp_teamlogo_1 alli");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "PlesseN");
			ServerCommand("bot_add_t %s", "upE");
			ServerCommand("bot_add_t %s", "eraa");
			ServerCommand("bot_add_t %s", "avid");
			ServerCommand("bot_add_t %s", "twist");
			ServerCommand("mp_teamlogo_2 alli");
		}
	}
	
	if(strcmp(szTeamArg, "Metiz", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "adamb");
			ServerCommand("bot_add_ct %s", "Plopski");
			ServerCommand("bot_add_ct %s", "L00m1");
			ServerCommand("bot_add_ct %s", "isak");
			ServerCommand("bot_add_ct %s", "hampus");
			ServerCommand("mp_teamlogo_1 metiz");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "adamb");
			ServerCommand("bot_add_t %s", "Plopski");
			ServerCommand("bot_add_t %s", "L00m1");
			ServerCommand("bot_add_t %s", "isak");
			ServerCommand("bot_add_t %s", "hampus");
			ServerCommand("mp_teamlogo_2 metiz");
		}
	}
	
	if(strcmp(szTeamArg, "unity", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "LeviRen");
			ServerCommand("bot_add_ct %s", "NEOFRAG");
			ServerCommand("bot_add_ct %s", "Pechyn");
			ServerCommand("bot_add_ct %s", "woozzzi");
			ServerCommand("bot_add_ct %s", "K1-FiDa");
			ServerCommand("mp_teamlogo_1 unit");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "LeviRen");
			ServerCommand("bot_add_t %s", "NEOFRAG");
			ServerCommand("bot_add_t %s", "Pechyn");
			ServerCommand("bot_add_t %s", "woozzzi");
			ServerCommand("bot_add_t %s", "K1-FiDa");
			ServerCommand("mp_teamlogo_2 unit");
		}
	}
	
	if(strcmp(szTeamArg, "9z", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "adamS");
			ServerCommand("bot_add_ct %s", "Martinez");
			ServerCommand("bot_add_ct %s", "maxujas");
			ServerCommand("bot_add_ct %s", "HUASOPEEK");
			ServerCommand("bot_add_ct %s", "Luken");
			ServerCommand("mp_teamlogo_1 nine");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "adamS");
			ServerCommand("bot_add_t %s", "Martinez");
			ServerCommand("bot_add_t %s", "maxujas");
			ServerCommand("bot_add_t %s", "HUASOPEEK");
			ServerCommand("bot_add_t %s", "Luken");
			ServerCommand("mp_teamlogo_2 nine");
		}
	}
	
	if(strcmp(szTeamArg, "SINNERS", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "MoriiSko");
			ServerCommand("bot_add_ct %s", "ZEDKO");
			ServerCommand("bot_add_ct %s", "SHOCK");
			ServerCommand("bot_add_ct %s", "beastik");
			ServerCommand("bot_add_ct %s", "Pepo");
			ServerCommand("mp_teamlogo_1 sinn");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "MoriiSko");
			ServerCommand("bot_add_t %s", "ZEDKO");
			ServerCommand("bot_add_t %s", "SHOCK");
			ServerCommand("bot_add_t %s", "beastik");
			ServerCommand("bot_add_t %s", "Pepo");
			ServerCommand("mp_teamlogo_2 sinn");
		}
	}
	
	if(strcmp(szTeamArg, "BESTIA", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "leo_drk");
			ServerCommand("bot_add_ct %s", "Noktse");
			ServerCommand("bot_add_ct %s", "cass1n");
			ServerCommand("bot_add_ct %s", "luchov");
			ServerCommand("bot_add_ct %s", "tomaszin");
			ServerCommand("mp_teamlogo_1 best");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "leo_drk");
			ServerCommand("bot_add_t %s", "Noktse");
			ServerCommand("bot_add_t %s", "cass1n");
			ServerCommand("bot_add_t %s", "luchov");
			ServerCommand("bot_add_t %s", "tomaszin");
			ServerCommand("mp_teamlogo_2 best");
		}
	}
	
	if(strcmp(szTeamArg, "Nouns", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "RUSH");
			ServerCommand("bot_add_ct %s", "junior");
			ServerCommand("bot_add_ct %s", "Peeping");
			ServerCommand("bot_add_ct %s", "Cryptic");
			ServerCommand("bot_add_ct %s", "CLASIA");
			ServerCommand("mp_teamlogo_1 nouns");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "RUSH");
			ServerCommand("bot_add_t %s", "junior");
			ServerCommand("bot_add_t %s", "Peeping");
			ServerCommand("bot_add_t %s", "Cryptic");
			ServerCommand("bot_add_t %s", "CLASIA");
			ServerCommand("mp_teamlogo_2 nouns");
		}
	}
	
	if(strcmp(szTeamArg, "Spirit", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "chopper");
			ServerCommand("bot_add_ct %s", "sh1ro");
			ServerCommand("bot_add_ct %s", "magixx");
			ServerCommand("bot_add_ct %s", "donk");
			ServerCommand("bot_add_ct %s", "zont1x");
			ServerCommand("mp_teamlogo_1 spir");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "chopper");
			ServerCommand("bot_add_t %s", "sh1ro");
			ServerCommand("bot_add_t %s", "magixx");
			ServerCommand("bot_add_t %s", "donk");
			ServerCommand("bot_add_t %s", "zont1x");
			ServerCommand("mp_teamlogo_2 spir");
		}
	}
	
	if(strcmp(szTeamArg, "Viperio", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "zodi");
			ServerCommand("bot_add_ct %s", "Skrimo");
			ServerCommand("bot_add_ct %s", "dezt");
			ServerCommand("bot_add_ct %s", "swicher");
			ServerCommand("bot_add_ct %s", "Junyme");
			ServerCommand("mp_teamlogo_1 viper");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "zodi");
			ServerCommand("bot_add_t %s", "Skrimo");
			ServerCommand("bot_add_t %s", "dezt");
			ServerCommand("bot_add_t %s", "swicher");
			ServerCommand("bot_add_t %s", "Junyme");
			ServerCommand("mp_teamlogo_2 viper");
		}
	}
	
	if(strcmp(szTeamArg, "CW", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Tapewaare");
			ServerCommand("bot_add_ct %s", "aNdu");
			ServerCommand("bot_add_ct %s", "szejn");
			ServerCommand("bot_add_ct %s", "b1elany");
			ServerCommand("bot_add_ct %s", "Jackinho");
			ServerCommand("mp_teamlogo_1 cw");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Tapewaare");
			ServerCommand("bot_add_t %s", "aNdu");
			ServerCommand("bot_add_t %s", "szejn");
			ServerCommand("bot_add_t %s", "b1elany");
			ServerCommand("bot_add_t %s", "Jackinho");
			ServerCommand("mp_teamlogo_2 cw");
		}
	}
	
	if(strcmp(szTeamArg, "WC", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "stanislaw");
			ServerCommand("bot_add_ct %s", "Sonic");
			ServerCommand("bot_add_ct %s", "JBa");
			ServerCommand("bot_add_ct %s", "susp");
			ServerCommand("bot_add_ct %s", "phzy");
			ServerCommand("mp_teamlogo_1 wc");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "stanislaw");
			ServerCommand("bot_add_t %s", "Sonic");
			ServerCommand("bot_add_t %s", "JBa");
			ServerCommand("bot_add_t %s", "susp");
			ServerCommand("bot_add_t %s", "phzy");
			ServerCommand("mp_teamlogo_2 wc");
		}
	}
	
	if(strcmp(szTeamArg, "Permitta", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Twiksar");
			ServerCommand("bot_add_ct %s", "Kre1N");
			ServerCommand("bot_add_ct %s", "Tionix");
			ServerCommand("bot_add_ct %s", "Orbit");
			ServerCommand("bot_add_ct %s", "fostar");
			ServerCommand("mp_teamlogo_1 perm");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Twiksar");
			ServerCommand("bot_add_t %s", "Kre1N");
			ServerCommand("bot_add_t %s", "Tionix");
			ServerCommand("bot_add_t %s", "Orbit");
			ServerCommand("bot_add_t %s", "fostar");
			ServerCommand("mp_teamlogo_2 perm");
		}
	}
	
	if(strcmp(szTeamArg, "777", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Viktha");
			ServerCommand("bot_add_ct %s", "qzr");
			ServerCommand("bot_add_ct %s", "Affava");
			ServerCommand("bot_add_ct %s", "MadeInRed");
			ServerCommand("bot_add_ct %s", "Hagmeister");
			ServerCommand("mp_teamlogo_1 777");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Viktha");
			ServerCommand("bot_add_t %s", "qzr");
			ServerCommand("bot_add_t %s", "Affava");
			ServerCommand("bot_add_t %s", "MadeInRed");
			ServerCommand("bot_add_t %s", "Hagmeister");
			ServerCommand("mp_teamlogo_2 777");
		}
	}
	
	if(strcmp(szTeamArg, "HOTU", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "lampada");
			ServerCommand("bot_add_ct %s", "Re1GN");
			ServerCommand("bot_add_ct %s", "kade0");
			ServerCommand("bot_add_ct %s", "mizu");
			ServerCommand("bot_add_ct %s", "youka");
			ServerCommand("mp_teamlogo_1 hotu");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "lampada");
			ServerCommand("bot_add_t %s", "Re1GN");
			ServerCommand("bot_add_t %s", "kade0");
			ServerCommand("bot_add_t %s", "mizu");
			ServerCommand("bot_add_t %s", "youka");
			ServerCommand("mp_teamlogo_2 hotu");
		}
	}
	
	if(strcmp(szTeamArg, "Falcons", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Magisk");
			ServerCommand("bot_add_ct %s", "NiKo");
			ServerCommand("bot_add_ct %s", "TeSeS");
			ServerCommand("bot_add_ct %s", "kyxsan");
			ServerCommand("bot_add_ct %s", "degster");
			ServerCommand("mp_teamlogo_1 fal");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Magisk");
			ServerCommand("bot_add_t %s", "NiKo");
			ServerCommand("bot_add_t %s", "TeSeS");
			ServerCommand("bot_add_t %s", "kyxsan");
			ServerCommand("bot_add_t %s", "degster");
			ServerCommand("mp_teamlogo_2 fal");
		}
	}
	
	if(strcmp(szTeamArg, "500", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Oxygen");
			ServerCommand("bot_add_ct %s", "CeRq");
			ServerCommand("bot_add_ct %s", "SHiPZ");
			ServerCommand("bot_add_ct %s", "Rainwaker");
			ServerCommand("bot_add_ct %s", "SPELLAN");
			ServerCommand("mp_teamlogo_1 500");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Oxygen");
			ServerCommand("bot_add_t %s", "CeRq");
			ServerCommand("bot_add_t %s", "SHiPZ");
			ServerCommand("bot_add_t %s", "Rainwaker");
			ServerCommand("bot_add_t %s", "SPELLAN");
			ServerCommand("mp_teamlogo_2 500");
		}
	}
	
	if(strcmp(szTeamArg, "Aurora", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "clax");
			ServerCommand("bot_add_ct %s", "gr1ks");
			ServerCommand("bot_add_ct %s", "Norwi");
			ServerCommand("bot_add_ct %s", "KENSI");
			ServerCommand("bot_add_ct %s", "Patsi");
			ServerCommand("mp_teamlogo_1 aur");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "clax");
			ServerCommand("bot_add_t %s", "gr1ks");
			ServerCommand("bot_add_t %s", "Norwi");
			ServerCommand("bot_add_t %s", "KENSI");
			ServerCommand("bot_add_t %s", "Patsi");
			ServerCommand("mp_teamlogo_2 aur");
		}
	}
	
	if(strcmp(szTeamArg, "ARCRED", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Ryujin");
			ServerCommand("bot_add_ct %s", "DSSj");
			ServerCommand("bot_add_ct %s", "1NVISIBLEE");
			ServerCommand("bot_add_ct %s", "Get_Jeka");
			ServerCommand("bot_add_ct %s", "shg");
			ServerCommand("mp_teamlogo_1 arc");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Ryujin");
			ServerCommand("bot_add_t %s", "DSSj");
			ServerCommand("bot_add_t %s", "1NVISIBLEE");
			ServerCommand("bot_add_t %s", "Get_Jeka");
			ServerCommand("bot_add_t %s", "shg");
			ServerCommand("mp_teamlogo_2 arc");
		}
	}
	
	if(strcmp(szTeamArg, "Imperial", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "noway");
			ServerCommand("bot_add_ct %s", "try");
			ServerCommand("bot_add_ct %s", "chay");
			ServerCommand("bot_add_ct %s", "decenty");
			ServerCommand("bot_add_ct %s", "VINI");
			ServerCommand("mp_teamlogo_1 imp");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "noway");
			ServerCommand("bot_add_t %s", "try");
			ServerCommand("bot_add_t %s", "chay");
			ServerCommand("bot_add_t %s", "decenty");
			ServerCommand("bot_add_t %s", "VINI");
			ServerCommand("mp_teamlogo_2 imp");
		}
	}
	
	if(strcmp(szTeamArg, "EYEBALLERS", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "HEAP");
			ServerCommand("bot_add_ct %s", "JW");
			ServerCommand("bot_add_ct %s", "poiii");
			ServerCommand("bot_add_ct %s", "dex");
			ServerCommand("bot_add_ct %s", "delle");
			ServerCommand("mp_teamlogo_1 eye");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "HEAP");
			ServerCommand("bot_add_t %s", "JW");
			ServerCommand("bot_add_t %s", "poiii");
			ServerCommand("bot_add_t %s", "dex");
			ServerCommand("bot_add_t %s", "delle");
			ServerCommand("mp_teamlogo_2 eye");
		}
	}
	
	if(strcmp(szTeamArg, "Monte", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "leen");
			ServerCommand("bot_add_ct %s", "hades");
			ServerCommand("bot_add_ct %s", "DemQQ");
			ServerCommand("bot_add_ct %s", "Gizmy");
			ServerCommand("bot_add_ct %s", "ryu");
			ServerCommand("mp_teamlogo_1 mont");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "leen");
			ServerCommand("bot_add_t %s", "hades");
			ServerCommand("bot_add_t %s", "DemQQ");
			ServerCommand("bot_add_t %s", "Gizmy");
			ServerCommand("bot_add_t %s", "ryu");
			ServerCommand("mp_teamlogo_2 mont");
		}
	}
	
	if(strcmp(szTeamArg, "M80", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Swisher");
			ServerCommand("bot_add_ct %s", "slaxz-");
			ServerCommand("bot_add_ct %s", "reck");
			ServerCommand("bot_add_ct %s", "Lake");
			ServerCommand("bot_add_ct %s", "s1n");
			ServerCommand("mp_teamlogo_1 m80");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Swisher");
			ServerCommand("bot_add_t %s", "slaxz-");
			ServerCommand("bot_add_t %s", "reck");
			ServerCommand("bot_add_t %s", "Lake");
			ServerCommand("bot_add_t %s", "s1n");
			ServerCommand("mp_teamlogo_2 m80");
		}
	}
	
	if(strcmp(szTeamArg, "Legacy", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "latto");
			ServerCommand("bot_add_ct %s", "saadzin");
			ServerCommand("bot_add_ct %s", "dumau");
			ServerCommand("bot_add_ct %s", "n1ssim");
			ServerCommand("bot_add_ct %s", "lux");
			ServerCommand("mp_teamlogo_1 leg");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "latto");
			ServerCommand("bot_add_t %s", "saadzin");
			ServerCommand("bot_add_t %s", "dumau");
			ServerCommand("bot_add_t %s", "n1ssim");
			ServerCommand("bot_add_t %s", "lux");
			ServerCommand("mp_teamlogo_2 leg");
		}
	}
	
	if(strcmp(szTeamArg, "BetBoom", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Ax1Le");
			ServerCommand("bot_add_ct %s", "zorte");
			ServerCommand("bot_add_ct %s", "Boombl4");
			ServerCommand("bot_add_ct %s", "s1ren");
			ServerCommand("bot_add_ct %s", "Magnojez");
			ServerCommand("mp_teamlogo_1 bet");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Ax1Le");
			ServerCommand("bot_add_t %s", "zorte");
			ServerCommand("bot_add_t %s", "Boombl4");
			ServerCommand("bot_add_t %s", "s1ren");
			ServerCommand("bot_add_t %s", "Magnojez");
			ServerCommand("mp_teamlogo_2 bet");
		}
	}
	
	if(strcmp(szTeamArg, "Fluxo", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "history");
			ServerCommand("bot_add_ct %s", "arT");
			ServerCommand("bot_add_ct %s", "mlhzin");
			ServerCommand("bot_add_ct %s", "kye");
			ServerCommand("bot_add_ct %s", "piriajr");
			ServerCommand("mp_teamlogo_1 flux");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "history");
			ServerCommand("bot_add_t %s", "arT");
			ServerCommand("bot_add_t %s", "mlhzin");
			ServerCommand("bot_add_t %s", "kye");
			ServerCommand("bot_add_t %s", "piriajr");
			ServerCommand("mp_teamlogo_2 flux");
		}
	}
	
	if(strcmp(szTeamArg, "DUSTY", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Midgard");
			ServerCommand("bot_add_ct %s", "TH0R");
			ServerCommand("bot_add_ct %s", "brnr");
			ServerCommand("bot_add_ct %s", "PANDAZ");
			ServerCommand("bot_add_ct %s", "StebbiC0C0");
			ServerCommand("mp_teamlogo_1 dust");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Midgard");
			ServerCommand("bot_add_t %s", "TH0R");
			ServerCommand("bot_add_t %s", "brnr");
			ServerCommand("bot_add_t %s", "PANDAZ");
			ServerCommand("bot_add_t %s", "StebbiC0C0");
			ServerCommand("mp_teamlogo_2 dust");
		}
	}
	
	if(strcmp(szTeamArg, "ODDIK", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "naitte");
			ServerCommand("bot_add_ct %s", "WOOD7");
			ServerCommand("bot_add_ct %s", "matios");
			ServerCommand("bot_add_ct %s", "pancc");
			ServerCommand("bot_add_ct %s", "ksloks");
			ServerCommand("mp_teamlogo_1 odd");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "naitte");
			ServerCommand("bot_add_t %s", "WOOD7");
			ServerCommand("bot_add_t %s", "matios");
			ServerCommand("bot_add_t %s", "pancc");
			ServerCommand("bot_add_t %s", "ksloks");
			ServerCommand("mp_teamlogo_2 odd");
		}
	}
	
	if(strcmp(szTeamArg, "Sashi", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "IceBerg");
			ServerCommand("bot_add_ct %s", "LuckyV1");
			ServerCommand("bot_add_ct %s", "Cabbi");
			ServerCommand("bot_add_ct %s", "Altekz");
			ServerCommand("bot_add_ct %s", "Zyphon");
			ServerCommand("mp_teamlogo_1 sas");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "PR1mE");
			ServerCommand("bot_add_t %s", "LuckyV1");
			ServerCommand("bot_add_t %s", "Cabbi");
			ServerCommand("bot_add_t %s", "Altekz");
			ServerCommand("bot_add_t %s", "Zyphon");
			ServerCommand("mp_teamlogo_2 sas");
		}
	}
	
	if(strcmp(szTeamArg, "Insilio", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "kelieN");
			ServerCommand("bot_add_ct %s", "dwushka");
			ServerCommand("bot_add_ct %s", "mag1k3Y");
			ServerCommand("bot_add_ct %s", "faydett");
			ServerCommand("bot_add_ct %s", "sugaR");
			ServerCommand("mp_teamlogo_1 ins");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "kelieN");
			ServerCommand("bot_add_t %s", "dwushka");
			ServerCommand("bot_add_t %s", "mag1k3Y");
			ServerCommand("bot_add_t %s", "faydett");
			ServerCommand("bot_add_t %s", "sugaR");
			ServerCommand("mp_teamlogo_2 ins");
		}
	}
	
	if(strcmp(szTeamArg, "Zero", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "simke");
			ServerCommand("bot_add_ct %s", "brutmonster");
			ServerCommand("bot_add_ct %s", "nEMANHA");
			ServerCommand("bot_add_ct %s", "Cjoffo");
			ServerCommand("bot_add_ct %s", "aVN");
			ServerCommand("mp_teamlogo_1 zero");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "simke");
			ServerCommand("bot_add_t %s", "brutmonster");
			ServerCommand("bot_add_t %s", "nEMANHA");
			ServerCommand("bot_add_t %s", "Cjoffo");
			ServerCommand("bot_add_t %s", "aVN");
			ServerCommand("mp_teamlogo_2 zero");
		}
	}
	
	if(strcmp(szTeamArg, "Solid", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "gbb");
			ServerCommand("bot_add_ct %s", "DeStiNy");
			ServerCommand("bot_add_ct %s", "drg");
			ServerCommand("bot_add_ct %s", "nython");
			ServerCommand("bot_add_ct %s", "tomate");
			ServerCommand("mp_teamlogo_1 sol");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "gbb");
			ServerCommand("bot_add_t %s", "DeStiNy");
			ServerCommand("bot_add_t %s", "drg");
			ServerCommand("bot_add_t %s", "nython");
			ServerCommand("bot_add_t %s", "tomate");
			ServerCommand("mp_teamlogo_2 sol");
		}
	}
	
	if(strcmp(szTeamArg, "JANO", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Aerial");
			ServerCommand("bot_add_ct %s", "allu");
			ServerCommand("bot_add_ct %s", "HENU");
			ServerCommand("bot_add_ct %s", "Sm1llee");
			ServerCommand("bot_add_ct %s", "jelo");
			ServerCommand("mp_teamlogo_1 jano");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Aerial");
			ServerCommand("bot_add_t %s", "allu");
			ServerCommand("bot_add_t %s", "HENU");
			ServerCommand("bot_add_t %s", "Sm1llee");
			ServerCommand("bot_add_t %s", "jelo");
			ServerCommand("mp_teamlogo_2 jano");
		}
	}
	
	if(strcmp(szTeamArg, "SNOGARD", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "kinQ");
			ServerCommand("bot_add_ct %s", "LapeX");
			ServerCommand("bot_add_ct %s", "ND");
			ServerCommand("bot_add_ct %s", "Pictrucz");
			ServerCommand("bot_add_ct %s", "Shairoe");
			ServerCommand("mp_teamlogo_1 snog");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "kinQ");
			ServerCommand("bot_add_t %s", "LapeX");
			ServerCommand("bot_add_t %s", "ND");
			ServerCommand("bot_add_t %s", "Pictrucz");
			ServerCommand("bot_add_t %s", "Shairoe");
			ServerCommand("mp_teamlogo_2 snog");
		}
	}
	
	if(strcmp(szTeamArg, "9Pandas", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "shalfey");
			ServerCommand("bot_add_ct %s", "r3salt");
			ServerCommand("bot_add_ct %s", "d1Ledez");
			ServerCommand("bot_add_ct %s", "Alv");
			ServerCommand("bot_add_ct %s", "Krad");
			ServerCommand("mp_teamlogo_1 pand");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "shalfey");
			ServerCommand("bot_add_t %s", "r3salt");
			ServerCommand("bot_add_t %s", "d1Ledez");
			ServerCommand("bot_add_t %s", "Alv");
			ServerCommand("bot_add_t %s", "Krad");
			ServerCommand("mp_teamlogo_2 pand");
		}
	}
	
	if(strcmp(szTeamArg, "Flyte", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Crisp");
			ServerCommand("bot_add_ct %s", "Sharpie");
			ServerCommand("bot_add_ct %s", "huncho");
			ServerCommand("bot_add_ct %s", "Panic");
			ServerCommand("bot_add_ct %s", "REKMEISTER");
			ServerCommand("mp_teamlogo_1 flyte");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Crisp");
			ServerCommand("bot_add_t %s", "Sharpie");
			ServerCommand("bot_add_t %s", "huncho");
			ServerCommand("bot_add_t %s", "Panic");
			ServerCommand("bot_add_t %s", "REKMEISTER");
			ServerCommand("mp_teamlogo_2 flyte");
		}
	}
	
	if(strcmp(szTeamArg, "Rare", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "somebody");
			ServerCommand("bot_add_ct %s", "L1haNg");
			ServerCommand("bot_add_ct %s", "Summer");
			ServerCommand("bot_add_ct %s", "ChildKing");
			ServerCommand("bot_add_ct %s", "kaze");
			ServerCommand("mp_teamlogo_1 rar");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "somebody");
			ServerCommand("bot_add_t %s", "L1haNg");
			ServerCommand("bot_add_t %s", "Summer");
			ServerCommand("bot_add_t %s", "ChildKing");
			ServerCommand("bot_add_t %s", "kaze");
			ServerCommand("mp_teamlogo_2 rar");
		}
	}
	
	if(strcmp(szTeamArg, "GTZ", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "snapy");
			ServerCommand("bot_add_ct %s", "rafaxF");
			ServerCommand("bot_add_ct %s", "NOPEEj");
			ServerCommand("bot_add_ct %s", "Linko");
			ServerCommand("bot_add_ct %s", "DDias");
			ServerCommand("mp_teamlogo_1 gtz");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "snapy");
			ServerCommand("bot_add_t %s", "rafaxF");
			ServerCommand("bot_add_t %s", "NOPEEj");
			ServerCommand("bot_add_t %s", "Linko");
			ServerCommand("bot_add_t %s", "DDias");
			ServerCommand("mp_teamlogo_2 gtz");
		}
	}
	
	if(strcmp(szTeamArg, "ATOX", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "dobu");
			ServerCommand("bot_add_ct %s", "AccuracyTG");
			ServerCommand("bot_add_ct %s", "kabal");
			ServerCommand("bot_add_ct %s", "MiQ");
			ServerCommand("bot_add_ct %s", "zesta");
			ServerCommand("mp_teamlogo_1 ato");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "dobu");
			ServerCommand("bot_add_t %s", "AccuracyTG");
			ServerCommand("bot_add_t %s", "kabal");
			ServerCommand("bot_add_t %s", "MiQ");
			ServerCommand("bot_add_t %s", "zesta");
			ServerCommand("mp_teamlogo_2 ato");
		}
	}
	
	if(strcmp(szTeamArg, "Reign", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Ph1NNN");
			ServerCommand("bot_add_ct %s", "f1redup");
			ServerCommand("bot_add_ct %s", "Bhavi");
			ServerCommand("bot_add_ct %s", "R2B2");
			ServerCommand("bot_add_ct %s", "Rossi");
			ServerCommand("mp_teamlogo_1 rei");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Ph1NNN");
			ServerCommand("bot_add_t %s", "f1redup");
			ServerCommand("bot_add_t %s", "Bhavi");
			ServerCommand("bot_add_t %s", "R2B2");
			ServerCommand("bot_add_t %s", "Rossi");
			ServerCommand("mp_teamlogo_2 rei");
		}
	}
	
	if(strcmp(szTeamArg, "JJH", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "m1N1");
			ServerCommand("bot_add_ct %s", "dennyslaw");
			ServerCommand("bot_add_ct %s", "Aaron");
			ServerCommand("bot_add_ct %s", "BOROS");
			ServerCommand("bot_add_ct %s", "bibu");
			ServerCommand("mp_teamlogo_1 jjh");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "m1N1");
			ServerCommand("bot_add_t %s", "dennyslaw");
			ServerCommand("bot_add_t %s", "Aaron");
			ServerCommand("bot_add_t %s", "BOROS");
			ServerCommand("bot_add_t %s", "bibu");
			ServerCommand("mp_teamlogo_2 jjh");
		}
	}
	
	if(strcmp(szTeamArg, "PDucks", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Trudo");
			ServerCommand("bot_add_ct %s", "astra");
			ServerCommand("bot_add_ct %s", "RapTo");
			ServerCommand("bot_add_ct %s", "MoR");
			ServerCommand("bot_add_ct %s", "monZat");
			ServerCommand("mp_teamlogo_1 pduc");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Trudo");
			ServerCommand("bot_add_t %s", "astra");
			ServerCommand("bot_add_t %s", "RapTo");
			ServerCommand("bot_add_t %s", "MoR");
			ServerCommand("bot_add_t %s", "monZat");
			ServerCommand("mp_teamlogo_2 pduc");
		}
	}
	
	if(strcmp(szTeamArg, "3DMAX", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Lucky");
			ServerCommand("bot_add_ct %s", "Maka");
			ServerCommand("bot_add_ct %s", "bodyy");
			ServerCommand("bot_add_ct %s", "Ex3rcice");
			ServerCommand("bot_add_ct %s", "Graviti");
			ServerCommand("mp_teamlogo_1 3dm");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Lucky");
			ServerCommand("bot_add_t %s", "Maka");
			ServerCommand("bot_add_t %s", "bodyy");
			ServerCommand("bot_add_t %s", "Ex3rcice");
			ServerCommand("bot_add_t %s", "Graviti");
			ServerCommand("mp_teamlogo_2 3dm");
		}
	}
	
	if(strcmp(szTeamArg, "Elevate", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "short");
			ServerCommand("bot_add_ct %s", "zede");
			ServerCommand("bot_add_ct %s", "diozera");
			ServerCommand("bot_add_ct %s", "lash");
			ServerCommand("bot_add_ct %s", "Skr");
			ServerCommand("mp_teamlogo_1 ele");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "short");
			ServerCommand("bot_add_t %s", "zede");
			ServerCommand("bot_add_t %s", "diozera");
			ServerCommand("bot_add_t %s", "lash");
			ServerCommand("bot_add_t %s", "Skr");
			ServerCommand("mp_teamlogo_2 ele");
		}
	}
	
	if(strcmp(szTeamArg, "GenOne", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "devoduvek");
			ServerCommand("bot_add_ct %s", "drac");
			ServerCommand("bot_add_ct %s", "Kursy");
			ServerCommand("bot_add_ct %s", "Brooxsy");
			ServerCommand("bot_add_ct %s", "JACKZ");
			ServerCommand("mp_teamlogo_1 gen");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "devoduvek");
			ServerCommand("bot_add_t %s", "drac");
			ServerCommand("bot_add_t %s", "Kursy");
			ServerCommand("bot_add_t %s", "Brooxsy");
			ServerCommand("bot_add_t %s", "JACKZ");
			ServerCommand("mp_teamlogo_2 gen");
		}
	}
	
	if(strcmp(szTeamArg, "Lemondogs", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "xelos");
			ServerCommand("bot_add_ct %s", "hemzk9");
			ServerCommand("bot_add_ct %s", "dZ");
			ServerCommand("bot_add_ct %s", "zeak");
			ServerCommand("bot_add_ct %s", "hechtikal");
			ServerCommand("mp_teamlogo_1 lemon");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "xelos");
			ServerCommand("bot_add_t %s", "hemzk9");
			ServerCommand("bot_add_t %s", "dZ");
			ServerCommand("bot_add_t %s", "zeak");
			ServerCommand("bot_add_t %s", "hechtikal");
			ServerCommand("mp_teamlogo_2 lemon");
		}
	}
	
	if(strcmp(szTeamArg, "Reason", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "m1she4ka");
			ServerCommand("bot_add_ct %s", "v1ze");
			ServerCommand("bot_add_ct %s", "FincHY");
			ServerCommand("bot_add_ct %s", "CJE");
			ServerCommand("bot_add_ct %s", "Flicky");
			ServerCommand("mp_teamlogo_1 r");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "m1she4ka");
			ServerCommand("bot_add_t %s", "v1ze");
			ServerCommand("bot_add_t %s", "FincHY");
			ServerCommand("bot_add_t %s", "CJE");
			ServerCommand("bot_add_t %s", "Flicky");
			ServerCommand("mp_teamlogo_2 r");
		}
	}
	
	if(strcmp(szTeamArg, "Preasy", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "AcilioN");
			ServerCommand("bot_add_ct %s", "Viggo");
			ServerCommand("bot_add_ct %s", "Griller");
			ServerCommand("bot_add_ct %s", "Beccie");
			ServerCommand("bot_add_ct %s", "Patti");
			ServerCommand("mp_teamlogo_1 pre");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "AcilioN");
			ServerCommand("bot_add_t %s", "Viggo");
			ServerCommand("bot_add_t %s", "Griller");
			ServerCommand("bot_add_t %s", "Beccie");
			ServerCommand("bot_add_t %s", "Patti");
			ServerCommand("mp_teamlogo_2 pre");
		}
	}
	
	if(strcmp(szTeamArg, "NRG", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "nitr0");
			ServerCommand("bot_add_ct %s", "oSee");
			ServerCommand("bot_add_ct %s", "Jeorge");
			ServerCommand("bot_add_ct %s", "HexT");
			ServerCommand("bot_add_ct %s", "br0");
			ServerCommand("mp_teamlogo_1 nr");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "nitr0");
			ServerCommand("bot_add_t %s", "oSee");
			ServerCommand("bot_add_t %s", "Jeorge");
			ServerCommand("bot_add_t %s", "HexT");
			ServerCommand("bot_add_t %s", "br0");
			ServerCommand("mp_teamlogo_2 nr");
		}
	}
	
	if(strcmp(szTeamArg, "Canids", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "coldzera");
			ServerCommand("bot_add_ct %s", "HEN1");
			ServerCommand("bot_add_ct %s", "venomzera");
			ServerCommand("bot_add_ct %s", "felps");
			ServerCommand("bot_add_ct %s", "nyezin");
			ServerCommand("mp_teamlogo_1 cani");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "coldzera");
			ServerCommand("bot_add_t %s", "HEN1");
			ServerCommand("bot_add_t %s", "venomzera");
			ServerCommand("bot_add_t %s", "felps");
			ServerCommand("bot_add_t %s", "nyezin");
			ServerCommand("mp_teamlogo_2 cani");
		}
	}
	
	if(strcmp(szTeamArg, "Mindfreak", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "tucks");
			ServerCommand("bot_add_ct %s", "Texta");
			ServerCommand("bot_add_ct %s", "gump");
			ServerCommand("bot_add_ct %s", "Rickeh");
			ServerCommand("bot_add_ct %s", "pain");
			ServerCommand("mp_teamlogo_1 mind");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "tucks");
			ServerCommand("bot_add_t %s", "Texta");
			ServerCommand("bot_add_t %s", "gump");
			ServerCommand("bot_add_t %s", "Rickeh");
			ServerCommand("bot_add_t %s", "pain");
			ServerCommand("mp_teamlogo_2 mind");
		}
	}
	
	if(strcmp(szTeamArg, "LEISURE", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "BischeR");
			ServerCommand("bot_add_ct %s", "Pulzfire");
			ServerCommand("bot_add_ct %s", "Fayte");
			ServerCommand("bot_add_ct %s", "Maxje");
			ServerCommand("bot_add_ct %s", "NZyyy");
			ServerCommand("mp_teamlogo_1 leis");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "BischeR");
			ServerCommand("bot_add_t %s", "Pulzfire");
			ServerCommand("bot_add_t %s", "Fayte");
			ServerCommand("bot_add_t %s", "Maxje");
			ServerCommand("bot_add_t %s", "NZyyy");
			ServerCommand("mp_teamlogo_2 leis");
		}
	}
	
	if(strcmp(szTeamArg, "WOPA", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Gnøffe");
			ServerCommand("bot_add_ct %s", "Vster");
			ServerCommand("bot_add_ct %s", "sL1m3");
			ServerCommand("bot_add_ct %s", "PR1mE");
			ServerCommand("bot_add_ct %s", "n1Xen");
			ServerCommand("mp_teamlogo_1 wop");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Gnøffe");
			ServerCommand("bot_add_t %s", "Vster");
			ServerCommand("bot_add_t %s", "sL1m3");
			ServerCommand("bot_add_t %s", "PR1mE");
			ServerCommand("bot_add_t %s", "n1Xen");
			ServerCommand("mp_teamlogo_2 wop");
		}
	}
	
	if(strcmp(szTeamArg, "devils", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "suonko");
			ServerCommand("bot_add_ct %s", "PeTeRoOo");
			ServerCommand("bot_add_ct %s", "Frontsiderr");
			ServerCommand("bot_add_ct %s", "fanatyk");
			ServerCommand("bot_add_ct %s", "FENIX");
			ServerCommand("mp_teamlogo_1 devi");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "suonko");
			ServerCommand("bot_add_t %s", "PeTeRoOo");
			ServerCommand("bot_add_t %s", "Frontsiderr");
			ServerCommand("bot_add_t %s", "fanatyk");
			ServerCommand("bot_add_t %s", "FENIX");
			ServerCommand("mp_teamlogo_2 devi");
		}
	}
	
	if(strcmp(szTeamArg, "ESC", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "maaryy");
			ServerCommand("bot_add_ct %s", "mASKED");
			ServerCommand("bot_add_ct %s", "reiko");
			ServerCommand("bot_add_ct %s", "bajmi");
			ServerCommand("bot_add_ct %s", "SaMey");
			ServerCommand("mp_teamlogo_1 escg");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "maaryy");
			ServerCommand("bot_add_t %s", "mASKED");
			ServerCommand("bot_add_t %s", "reiko");
			ServerCommand("bot_add_t %s", "bajmi");
			ServerCommand("bot_add_t %s", "SaMey");
			ServerCommand("mp_teamlogo_2 escg");
		}
	}
	
	if(strcmp(szTeamArg, "FAVBET", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "bondik");
			ServerCommand("bot_add_ct %s", "Smash");
			ServerCommand("bot_add_ct %s", "t3ns1on");
			ServerCommand("bot_add_ct %s", "j3kie");
			ServerCommand("bot_add_ct %s", "Marix");
			ServerCommand("mp_teamlogo_1 fav");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "bondik");
			ServerCommand("bot_add_t %s", "Smash");
			ServerCommand("bot_add_t %s", "t3ns1on");
			ServerCommand("bot_add_t %s", "j3kie");
			ServerCommand("bot_add_t %s", "Marix");
			ServerCommand("mp_teamlogo_2 fav");
		}
	}
	
	if(strcmp(szTeamArg, "Honved", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "er9k");
			ServerCommand("bot_add_ct %s", "vincso");
			ServerCommand("bot_add_ct %s", "s1cklxrd");
			ServerCommand("bot_add_ct %s", "noleN");
			ServerCommand("bot_add_ct %s", "kewS");
			ServerCommand("mp_teamlogo_1 hon");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "er9k");
			ServerCommand("bot_add_t %s", "vincso");
			ServerCommand("bot_add_t %s", "s1cklxrd");
			ServerCommand("bot_add_t %s", "noleN");
			ServerCommand("bot_add_t %s", "kewS");
			ServerCommand("mp_teamlogo_2 hon");
		}
	}
	
	if(strcmp(szTeamArg, "kONO", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "s4ltovsk1yy");
			ServerCommand("bot_add_ct %s", "amster");
			ServerCommand("bot_add_ct %s", "cptkurtka023");
			ServerCommand("bot_add_ct %s", "Sijeyy");
			ServerCommand("bot_add_ct %s", "zogeN");
			ServerCommand("mp_teamlogo_1 kon");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "s4ltovsk1yy");
			ServerCommand("bot_add_t %s", "amster");
			ServerCommand("bot_add_t %s", "cptkurtka023");
			ServerCommand("bot_add_t %s", "Sijeyy");
			ServerCommand("bot_add_t %s", "zogeN");
			ServerCommand("mp_teamlogo_2 kon");
		}
	}
	
	if(strcmp(szTeamArg, "Kubix", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "v1w");
			ServerCommand("bot_add_ct %s", "ammar");
			ServerCommand("bot_add_ct %s", "gejmzilla");
			ServerCommand("bot_add_ct %s", "tripey");
			ServerCommand("bot_add_ct %s", "Caleyy");
			ServerCommand("mp_teamlogo_1 kub");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "v1w");
			ServerCommand("bot_add_t %s", "ammar");
			ServerCommand("bot_add_t %s", "gejmzilla");
			ServerCommand("bot_add_t %s", "tripey");
			ServerCommand("bot_add_t %s", "Caleyy");
			ServerCommand("mp_teamlogo_2 kub");
		}
	}
	
	if(strcmp(szTeamArg, "Leo", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Malkiss");
			ServerCommand("bot_add_ct %s", "kr1vda");
			ServerCommand("bot_add_ct %s", "OneUn1que");
			ServerCommand("bot_add_ct %s", "marat2k");
			ServerCommand("bot_add_ct %s", "kL1o");
			ServerCommand("mp_teamlogo_1 leo");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Malkiss");
			ServerCommand("bot_add_t %s", "kr1vda");
			ServerCommand("bot_add_t %s", "OneUn1que");
			ServerCommand("bot_add_t %s", "marat2k");
			ServerCommand("bot_add_t %s", "kL1o");
			ServerCommand("mp_teamlogo_2 leo");
		}
	}
	
	if(strcmp(szTeamArg, "LSE", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "xReal");
			ServerCommand("bot_add_ct %s", "dan1");
			ServerCommand("bot_add_ct %s", "AwaykeN");
			ServerCommand("bot_add_ct %s", "xavi");
			ServerCommand("bot_add_ct %s", "d1maje");
			ServerCommand("mp_teamlogo_1 lse");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "xReal");
			ServerCommand("bot_add_t %s", "dan1");
			ServerCommand("bot_add_t %s", "AwaykeN");
			ServerCommand("bot_add_t %s", "xavi");
			ServerCommand("bot_add_t %s", "d1maje");
			ServerCommand("mp_teamlogo_2 lse");
		}
	}
	
	if(strcmp(szTeamArg, "Tricked", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "valde");
			ServerCommand("bot_add_ct %s", "Leakz");
			ServerCommand("bot_add_ct %s", "Queenix");
			ServerCommand("bot_add_ct %s", "Nodios");
			ServerCommand("bot_add_ct %s", "salazar");
			ServerCommand("mp_teamlogo_1 trick");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "valde");
			ServerCommand("bot_add_t %s", "Leakz");
			ServerCommand("bot_add_t %s", "Queenix");
			ServerCommand("bot_add_t %s", "Nodios");
			ServerCommand("bot_add_t %s", "salazar");
			ServerCommand("mp_teamlogo_2 trick");
		}
	}
	
	if(strcmp(szTeamArg, "BNE", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "SENER1");
			ServerCommand("bot_add_ct %s", "gxx-");
			ServerCommand("bot_add_ct %s", "juanflatroo");
			ServerCommand("bot_add_ct %s", "sinnopsyy");
			ServerCommand("bot_add_ct %s", "rigoN");
			ServerCommand("mp_teamlogo_1 bne");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "SENER1");
			ServerCommand("bot_add_t %s", "gxx-");
			ServerCommand("bot_add_t %s", "juanflatroo");
			ServerCommand("bot_add_t %s", "sinnopsyy");
			ServerCommand("bot_add_t %s", "rigoN");
			ServerCommand("mp_teamlogo_2 bne");
		}
	}
	
	if(strcmp(szTeamArg, "Speeds", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "draken");
			ServerCommand("bot_add_ct %s", "Ro1f");
			ServerCommand("bot_add_ct %s", "SHiNE");
			ServerCommand("bot_add_ct %s", "Sapec");
			ServerCommand("bot_add_ct %s", "MaiL09");
			ServerCommand("mp_teamlogo_1 speed");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "draken");
			ServerCommand("bot_add_t %s", "Ro1f");
			ServerCommand("bot_add_t %s", "SHiNE");
			ServerCommand("bot_add_t %s", "Sapec");
			ServerCommand("bot_add_t %s", "MaiL09");
			ServerCommand("mp_teamlogo_2 speed");
		}
	}
	
	if(strcmp(szTeamArg, "TNE", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "onic");
			ServerCommand("bot_add_ct %s", "cairne");
			ServerCommand("bot_add_ct %s", "Flierax");
			ServerCommand("bot_add_ct %s", "nifee");
			ServerCommand("bot_add_ct %s", "Dawy");
			ServerCommand("mp_teamlogo_1 tne");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "onic");
			ServerCommand("bot_add_t %s", "cairne");
			ServerCommand("bot_add_t %s", "Flierax");
			ServerCommand("bot_add_t %s", "nifee");
			ServerCommand("bot_add_t %s", "Dawy");
			ServerCommand("mp_teamlogo_2 tne");
		}
	}
	
	if(strcmp(szTeamArg, "Partizan", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Dragon");
			ServerCommand("bot_add_ct %s", "emi");
			ServerCommand("bot_add_ct %s", "c0llins");
			ServerCommand("bot_add_ct %s", "Kind0");
			ServerCommand("bot_add_ct %s", "VLDN");
			ServerCommand("mp_teamlogo_1 parti");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Dragon");
			ServerCommand("bot_add_t %s", "emi");
			ServerCommand("bot_add_t %s", "c0llins");
			ServerCommand("bot_add_t %s", "Kind0");
			ServerCommand("bot_add_t %s", "VLDN");
			ServerCommand("mp_teamlogo_2 parti");
		}
	}
	
	if(strcmp(szTeamArg, "Passion", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "jambo");
			ServerCommand("bot_add_ct %s", "jackasmo");
			ServerCommand("bot_add_ct %s", "zeRRoFIX");
			ServerCommand("bot_add_ct %s", "Topa");
			ServerCommand("bot_add_ct %s", "Kvem");
			ServerCommand("mp_teamlogo_1 pass");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "jambo");
			ServerCommand("bot_add_t %s", "jackasmo");
			ServerCommand("bot_add_t %s", "zeRRoFIX");
			ServerCommand("bot_add_t %s", "Topa");
			ServerCommand("bot_add_t %s", "Kvem");
			ServerCommand("mp_teamlogo_2 pass");
		}
	}
	
	if(strcmp(szTeamArg, "Rebels", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Flayy");
			ServerCommand("bot_add_ct %s", "kisserek");
			ServerCommand("bot_add_ct %s", "innocent");
			ServerCommand("bot_add_ct %s", "tomiko");
			ServerCommand("bot_add_ct %s", "Sobol");
			ServerCommand("mp_teamlogo_1 reb");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Flayy");
			ServerCommand("bot_add_t %s", "kisserek");
			ServerCommand("bot_add_t %s", "innocent");
			ServerCommand("bot_add_t %s", "tomiko");
			ServerCommand("bot_add_t %s", "Sobol");
			ServerCommand("mp_teamlogo_2 reb");
		}
	}
	
	if(strcmp(szTeamArg, "Sangal", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "kreaz");
			ServerCommand("bot_add_ct %s", "bnox");
			ServerCommand("bot_add_ct %s", "Blytz");
			ServerCommand("bot_add_ct %s", "danistzz");
			ServerCommand("bot_add_ct %s", "Calyx");
			ServerCommand("mp_teamlogo_1 sang");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "kreaz");
			ServerCommand("bot_add_t %s", "bnox");
			ServerCommand("bot_add_t %s", "Blytz");
			ServerCommand("bot_add_t %s", "danistzz");
			ServerCommand("bot_add_t %s", "Calyx");
			ServerCommand("mp_teamlogo_2 sang");
		}
	}
	
	if(strcmp(szTeamArg, "AMKAL", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "sFade8");
			ServerCommand("bot_add_ct %s", "AW");
			ServerCommand("bot_add_ct %s", "kAlash");
			ServerCommand("bot_add_ct %s", "sstiNiX");
			ServerCommand("bot_add_ct %s", "molodoy");
			ServerCommand("mp_teamlogo_1 amk");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "sFade8");
			ServerCommand("bot_add_t %s", "AW");
			ServerCommand("bot_add_t %s", "kAlash");
			ServerCommand("bot_add_t %s", "sstiNiX");
			ServerCommand("bot_add_t %s", "molodoy");
			ServerCommand("mp_teamlogo_2 amk");
		}
	}
	
	if(strcmp(szTeamArg, "FLG", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "takanashi");
			ServerCommand("bot_add_ct %s", "h1ghnesS");
			ServerCommand("bot_add_ct %s", "Djon8");
			ServerCommand("bot_add_ct %s", "SoLb");
			ServerCommand("bot_add_ct %s", "yuramyata");
			ServerCommand("mp_teamlogo_1 fluf");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "takanashi");
			ServerCommand("bot_add_t %s", "h1ghnesS");
			ServerCommand("bot_add_t %s", "Djon8");
			ServerCommand("bot_add_t %s", "SoLb");
			ServerCommand("bot_add_t %s", "yuramyata");
			ServerCommand("mp_teamlogo_2 fluf");
		}
	}
	
	if(strcmp(szTeamArg, "PARIVISION", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "BELCHONOKK");
			ServerCommand("bot_add_ct %s", "Qikert");
			ServerCommand("bot_add_ct %s", "Jame");
			ServerCommand("bot_add_ct %s", "TRAVIS");
			ServerCommand("bot_add_ct %s", "nota");
			ServerCommand("mp_teamlogo_1 pari");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "BELCHONOKK");
			ServerCommand("bot_add_t %s", "Qikert");
			ServerCommand("bot_add_t %s", "Jame");
			ServerCommand("bot_add_t %s", "TRAVIS");
			ServerCommand("bot_add_t %s", "nota");
			ServerCommand("mp_teamlogo_2 pari");
		}
	}
	
	if(strcmp(szTeamArg, "QUAZAR", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "N4mb3r5");
			ServerCommand("bot_add_ct %s", "tommy171");
			ServerCommand("bot_add_ct %s", "gehji");
			ServerCommand("bot_add_ct %s", "whisper");
			ServerCommand("bot_add_ct %s", "WebSun");
			ServerCommand("mp_teamlogo_1 qua");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "N4mb3r5");
			ServerCommand("bot_add_t %s", "tommy171");
			ServerCommand("bot_add_t %s", "gehji");
			ServerCommand("bot_add_t %s", "whisper");
			ServerCommand("bot_add_t %s", "WebSun");
			ServerCommand("mp_teamlogo_2 qua");
		}
	}
	
	if(strcmp(szTeamArg, "RUSH", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "kinqie");
			ServerCommand("bot_add_ct %s", "executor");
			ServerCommand("bot_add_ct %s", "tex1y");
			ServerCommand("bot_add_ct %s", "KIRO");
			ServerCommand("bot_add_ct %s", "z1Nny");
			ServerCommand("mp_teamlogo_1 rush");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "kinqie");
			ServerCommand("bot_add_t %s", "executor");
			ServerCommand("bot_add_t %s", "tex1y");
			ServerCommand("bot_add_t %s", "KIRO");
			ServerCommand("bot_add_t %s", "z1Nny");
			ServerCommand("mp_teamlogo_2 rush");
		}
	}
	
	if(strcmp(szTeamArg, "BLUEJAYS", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "freshie");
			ServerCommand("bot_add_ct %s", "SLIGHT");
			ServerCommand("bot_add_ct %s", "Fruitcupx");
			ServerCommand("bot_add_ct %s", "snav");
			ServerCommand("bot_add_ct %s", "Wolffe");
			ServerCommand("mp_teamlogo_1 blue");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "freshie");
			ServerCommand("bot_add_t %s", "SLIGHT");
			ServerCommand("bot_add_t %s", "Fruitcupx");
			ServerCommand("bot_add_t %s", "snav");
			ServerCommand("bot_add_t %s", "Wolffe");
			ServerCommand("mp_teamlogo_2 blue");
		}
	}
	
	if(strcmp(szTeamArg, "InControl", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "DYLAN");
			ServerCommand("bot_add_ct %s", "milo");
			ServerCommand("bot_add_ct %s", "TyRa");
			ServerCommand("bot_add_ct %s", "jsfeltner");
			ServerCommand("bot_add_ct %s", "Beast");
			ServerCommand("mp_teamlogo_1 inc");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "DYLAN");
			ServerCommand("bot_add_t %s", "milo");
			ServerCommand("bot_add_t %s", "TyRa");
			ServerCommand("bot_add_t %s", "jsfeltner");
			ServerCommand("bot_add_t %s", "Beast");
			ServerCommand("mp_teamlogo_2 inc");
		}
	}
	
	if(strcmp(szTeamArg, "Mythic", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "fl0m");
			ServerCommand("bot_add_ct %s", "Cooper");
			ServerCommand("bot_add_ct %s", "Trucklover86");
			ServerCommand("bot_add_ct %s", "Austin");
			ServerCommand("bot_add_ct %s", "hyza");
			ServerCommand("mp_teamlogo_1 myth");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "fl0m");
			ServerCommand("bot_add_t %s", "Cooper");
			ServerCommand("bot_add_t %s", "Trucklover86");
			ServerCommand("bot_add_t %s", "Austin");
			ServerCommand("bot_add_t %s", "hyza");
			ServerCommand("mp_teamlogo_2 myth");
		}
	}
	
	if(strcmp(szTeamArg, "Vireo", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Enfohip");
			ServerCommand("bot_add_ct %s", "Beaniehut");
			ServerCommand("bot_add_ct %s", "celery");
			ServerCommand("bot_add_ct %s", "luckyx");
			ServerCommand("bot_add_ct %s", "kiss");
			ServerCommand("mp_teamlogo_1 vire");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Enfohip");
			ServerCommand("bot_add_t %s", "Beaniehut");
			ServerCommand("bot_add_t %s", "celery");
			ServerCommand("bot_add_t %s", "luckyx");
			ServerCommand("bot_add_t %s", "kiss");
			ServerCommand("mp_teamlogo_2 vire");
		}
	}
	
	if(strcmp(szTeamArg, "BHE", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "KAISER");
			ServerCommand("bot_add_ct %s", "Bruninho");
			ServerCommand("bot_add_ct %s", "meyern");
			ServerCommand("bot_add_ct %s", "zock");
			ServerCommand("bot_add_ct %s", "Tuurtle");
			ServerCommand("mp_teamlogo_1 bhe");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "KAISER");
			ServerCommand("bot_add_t %s", "Bruninho");
			ServerCommand("bot_add_t %s", "meyern");
			ServerCommand("bot_add_t %s", "zock");
			ServerCommand("bot_add_t %s", "Tuurtle");
			ServerCommand("mp_teamlogo_2 bhe");
		}
	}
	
	if(strcmp(szTeamArg, "Galorys", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Kadzz");
			ServerCommand("bot_add_ct %s", "bacc");
			ServerCommand("bot_add_ct %s", "pepe");
			ServerCommand("bot_add_ct %s", "divine");
			ServerCommand("bot_add_ct %s", "Alisson");
			ServerCommand("mp_teamlogo_1 galo");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Kadzz");
			ServerCommand("bot_add_t %s", "bacc");
			ServerCommand("bot_add_t %s", "pepe");
			ServerCommand("bot_add_t %s", "divine");
			ServerCommand("bot_add_t %s", "Alisson");
			ServerCommand("mp_teamlogo_2 galo");
		}
	}
	
	if(strcmp(szTeamArg, "KRU", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "atarax1a");
			ServerCommand("bot_add_ct %s", "chshekin");
			ServerCommand("bot_add_ct %s", "reversive");
			ServerCommand("bot_add_ct %s", "righi");
			ServerCommand("bot_add_ct %s", "deco");
			ServerCommand("mp_teamlogo_1 kru");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "atarax1a");
			ServerCommand("bot_add_t %s", "chshekin");
			ServerCommand("bot_add_t %s", "reversive");
			ServerCommand("bot_add_t %s", "righi");
			ServerCommand("bot_add_t %s", "deco");
			ServerCommand("mp_teamlogo_2 kru");
		}
	}
	
	if(strcmp(szTeamArg, "FlyQuest", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "INS");
			ServerCommand("bot_add_ct %s", "Liazz");
			ServerCommand("bot_add_ct %s", "Vexite");
			ServerCommand("bot_add_ct %s", "nettik");
			ServerCommand("bot_add_ct %s", "regali");
			ServerCommand("mp_teamlogo_1 flyq");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "INS");
			ServerCommand("bot_add_t %s", "Liazz");
			ServerCommand("bot_add_t %s", "Vexite");
			ServerCommand("bot_add_t %s", "nettik");
			ServerCommand("bot_add_t %s", "regali");
			ServerCommand("mp_teamlogo_2 flyq");
		}
	}
	
	if(strcmp(szTeamArg, "E9", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "neverland");
			ServerCommand("bot_add_ct %s", "Tikkkkk");
			ServerCommand("bot_add_ct %s", "Yolo267");
			ServerCommand("bot_add_ct %s", "YellowpandaYC");
			ServerCommand("bot_add_ct %s", "1230");
			ServerCommand("mp_teamlogo_1 e9");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "neverland");
			ServerCommand("bot_add_t %s", "Tikkkkk");
			ServerCommand("bot_add_t %s", "Yolo267");
			ServerCommand("bot_add_t %s", "YellowpandaYC");
			ServerCommand("bot_add_t %s", "1230");
			ServerCommand("mp_teamlogo_2 e9");
		}
	}
	
	if(strcmp(szTeamArg, "Eruption", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "MagnumZ");
			ServerCommand("bot_add_ct %s", "xenization");
			ServerCommand("bot_add_ct %s", "fury5k");
			ServerCommand("bot_add_ct %s", "sk0R");
			ServerCommand("bot_add_ct %s", "sideffect");
			ServerCommand("mp_teamlogo_1 erup");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "MagnumZ");
			ServerCommand("bot_add_t %s", "xenization");
			ServerCommand("bot_add_t %s", "fury5k");
			ServerCommand("bot_add_t %s", "sk0R");
			ServerCommand("bot_add_t %s", "sideffect");
			ServerCommand("mp_teamlogo_2 erup");
		}
	}
	
	if(strcmp(szTeamArg, "IHC", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "rate");
			ServerCommand("bot_add_ct %s", "yAmi");
			ServerCommand("bot_add_ct %s", "cool4st");
			ServerCommand("bot_add_ct %s", "clouden");
			ServerCommand("bot_add_ct %s", "me1o");
			ServerCommand("mp_teamlogo_1 ihc");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "rate");
			ServerCommand("bot_add_t %s", "yAmi");
			ServerCommand("bot_add_t %s", "cool4st");
			ServerCommand("bot_add_t %s", "clouden");
			ServerCommand("bot_add_t %s", "me1o");
			ServerCommand("mp_teamlogo_2 ihc");
		}
	}
	
	if(strcmp(szTeamArg, "Huns", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "nin9");
			ServerCommand("bot_add_ct %s", "Bart4k");
			ServerCommand("bot_add_ct %s", "cobrazera");
			ServerCommand("bot_add_ct %s", "xerolte");
			ServerCommand("bot_add_ct %s", "Veccil");
			ServerCommand("mp_teamlogo_1 hun");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "nin9");
			ServerCommand("bot_add_t %s", "Bart4k");
			ServerCommand("bot_add_t %s", "cobrazera");
			ServerCommand("bot_add_t %s", "xerolte");
			ServerCommand("bot_add_t %s", "Veccil");
			ServerCommand("mp_teamlogo_2 hun");
		}
	}
	
	if(strcmp(szTeamArg, "BC", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "pr1metapz");
			ServerCommand("bot_add_ct %s", "jkaem");
			ServerCommand("bot_add_ct %s", "nawwk");
			ServerCommand("bot_add_ct %s", "nexa");
			ServerCommand("bot_add_ct %s", "CYPHER");
			ServerCommand("mp_teamlogo_1 bc");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "pr1metapz");
			ServerCommand("bot_add_t %s", "jkaem");
			ServerCommand("bot_add_t %s", "nawwk");
			ServerCommand("bot_add_t %s", "nexa");
			ServerCommand("bot_add_t %s", "CYPHER");
			ServerCommand("mp_teamlogo_2 bc");
		}
	}
	
	if(strcmp(szTeamArg, "Betclic", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Prism");
			ServerCommand("bot_add_ct %s", "hypex");
			ServerCommand("bot_add_ct %s", "Demho");
			ServerCommand("bot_add_ct %s", "hfah");
			ServerCommand("bot_add_ct %s", "jcobbb");
			ServerCommand("mp_teamlogo_1 bae");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Prism");
			ServerCommand("bot_add_t %s", "hypex");
			ServerCommand("bot_add_t %s", "Demho");
			ServerCommand("bot_add_t %s", "hfah");
			ServerCommand("bot_add_t %s", "jcobbb");
			ServerCommand("mp_teamlogo_2 bae");
		}
	}
	
	if(strcmp(szTeamArg, "ROYALS", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "addi");
			ServerCommand("bot_add_ct %s", "Timothybtw");
			ServerCommand("bot_add_ct %s", "hampz");
			ServerCommand("bot_add_ct %s", "looky");
			ServerCommand("bot_add_ct %s", "lindeen");
			ServerCommand("mp_teamlogo_1 roya");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "addi");
			ServerCommand("bot_add_t %s", "Timothybtw");
			ServerCommand("bot_add_t %s", "hampz");
			ServerCommand("bot_add_t %s", "looky");
			ServerCommand("bot_add_t %s", "lindeen");
			ServerCommand("mp_teamlogo_2 roya");
		}
	}
	
	if(strcmp(szTeamArg, "Nixuh", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "adaro");
			ServerCommand("bot_add_ct %s", "ELUSIVE");
			ServerCommand("bot_add_ct %s", "zerOchaNce");
			ServerCommand("bot_add_ct %s", "Lord");
			ServerCommand("bot_add_ct %s", "Syned");
			ServerCommand("mp_teamlogo_1 nix");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "adaro");
			ServerCommand("bot_add_t %s", "ELUSIVE");
			ServerCommand("bot_add_t %s", "zerOchaNce");
			ServerCommand("bot_add_t %s", "Lord");
			ServerCommand("bot_add_t %s", "Syned");
			ServerCommand("mp_teamlogo_2 nix");
		}
	}
	
	return Plugin_Handled;
}

public void OnMapStart()
{
	g_iProfileRankOffset = FindSendPropInfo("CCSPlayerResource", "m_nPersonaDataPublicLevel");
	g_iPlayerColorOffset = FindSendPropInfo("CCSPlayerResource", "m_iCompTeammateColor");
	
	GetCurrentMap(g_szMap, sizeof(g_szMap));
	GetMapDisplayName(g_szMap, g_szMap, sizeof(g_szMap));
	
	ParseMapNades(g_szMap);
	
	g_bIsBombScenario = IsValidEntity(FindEntityByClassname(-1, "func_bomb_target"));
	g_bIsHostageScenario = IsValidEntity(FindEntityByClassname(-1, "func_hostage_rescue"));
	
	CreateTimer(1.0, Timer_CheckPlayer, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(0.1, Timer_MoveToBomb, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	SDKHook(GetPlayerResourceEntity(), SDKHook_ThinkPost, OnThinkPost);
	
	for (int i = 1; i <= MaxClients; i++)
		g_iPlayerColor[i] = -1;
}

public Action Timer_CheckPlayer(Handle hTimer, any data)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && IsFakeClient(i) && IsPlayerAlive(i))
		{
			int iAccount = GetEntProp(i, Prop_Send, "m_iAccount");
			bool bInBuyZone = !!GetEntProp(i, Prop_Send, "m_bInBuyZone");
			int iTeam = GetClientTeam(i);
			bool bHasDefuser = !!GetEntProp(i, Prop_Send, "m_bHasDefuser");
			int iPrimary = GetPlayerWeaponSlot(i, CS_SLOT_PRIMARY);
			char szDefaultPrimary[64];
			GetClientWeapon(i, szDefaultPrimary, sizeof(szDefaultPrimary));
			
			if (IsItMyChance(2.0))
			{
				FakeClientCommand(i, "+lookatweapon");
				FakeClientCommand(i, "-lookatweapon");
			}
			
			if(!bInBuyZone)
				continue;
			
			if (IsValidEntity(iPrimary) || (GetFriendsWithPrimary(i) >= 1 && strcmp(szDefaultPrimary, "weapon_hkp2000") != 0 && strcmp(szDefaultPrimary, "weapon_usp_silencer") != 0 && strcmp(szDefaultPrimary, "weapon_glock") != 0))
			{
				if (GetEntProp(i, Prop_Data, "m_ArmorValue") < 50 || GetEntProp(i, Prop_Send, "m_bHasHelmet") == 0)
					FakeClientCommand(i, "buy vesthelm");
				
				if (iTeam == CS_TEAM_CT && !bHasDefuser)
					FakeClientCommand(i, "buy defuser");
				
				if(GetGameTime() - g_fRoundStart > 6.0 && !g_bFreezetimeEnd)
				{
					int iRndNadeSet = Math_GetRandomInt(1,3);
					
					switch(iRndNadeSet)
					{
						case 1:
						{
							FakeClientCommand(i, "buy smokegrenade");
							FakeClientCommand(i, "buy flashbang");
							FakeClientCommand(i, "buy flashbang");
							FakeClientCommand(i, "buy hegrenade");
						}
						case 2:
						{
							FakeClientCommand(i, "buy smokegrenade");
							FakeClientCommand(i, "buy flashbang");
							FakeClientCommand(i, "buy flashbang");
							FakeClientCommand(i, "buy molotov");
						}
						case 3:
						{
							FakeClientCommand(i, "buy smokegrenade");
							FakeClientCommand(i, "buy flashbang");
							FakeClientCommand(i, "buy hegrenade");
							FakeClientCommand(i, "buy molotov");
						}
					}
				}
			}
			
			if ((iAccount < g_cvBotEcoLimit.IntValue && iAccount > 2000 && !IsValidEntity(iPrimary)) || GetFriendsWithPrimary(i) >= 1)
			{
				if(strcmp(szDefaultPrimary, "weapon_hkp2000") == 0 || strcmp(szDefaultPrimary, "weapon_usp_silencer") == 0 || strcmp(szDefaultPrimary, "weapon_glock") == 0)
				{
					int iRndPistol = Math_GetRandomInt(1, 5);
					
					switch (iRndPistol)
					{
						case 1: FakeClientCommand(i, "buy p250");
						case 2: FakeClientCommand(i, "buy tec9");
						case 3: FakeClientCommand(i, "buy deagle");
					}
				}
				else
				{
					switch (Math_GetRandomInt(1,15))
					{
						case 1: FakeClientCommand(i, "buy vest");
						case 10: FakeClientCommand(i, "buy %s", (iTeam == CS_TEAM_CT && !bHasDefuser) ? "defuser" : "vest");
					}
				}
				
			}
			
			if (g_iCurrentRound == 0 || g_iCurrentRound == 12)
			{
				if(IsItMyChance(2.0))
					FakeClientCommand(i, "buy %s", (iTeam == CS_TEAM_CT) ? "elite" : "vest");
				else if(IsItMyChance(30.0))
					FakeClientCommand(i, "buy %s", (iTeam == CS_TEAM_CT) ? "defuser" : "p250");
				else if(IsItMyChance(60.0))
					FakeClientCommand(i, "buy vest");
			}
		}
	}
	
	return Plugin_Continue;
}

public Action Timer_MoveToBomb(Handle hTimer, any data)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && IsFakeClient(i) && IsPlayerAlive(i))
		{
			if(g_bBombPlanted)
			{
				int iPlantedC4 = -1;
				iPlantedC4 = FindEntityByClassname(iPlantedC4, "planted_c4");
				
				if (IsValidEntity(iPlantedC4) && GetClientTeam(i) == CS_TEAM_CT)
				{
					float fPlantedC4Location[3];
					GetEntPropVector(iPlantedC4, Prop_Send, "m_vecOrigin", fPlantedC4Location);
					
					float fPlantedC4Distance;
					
					fPlantedC4Distance = GetVectorDistance(g_fBotOrigin[i], fPlantedC4Location);
					
					if (((GetAliveTeamCount(CS_TEAM_T) == 0 && GetAliveTeamCount(CS_TEAM_CT) == 1 && fPlantedC4Distance > 30.0 && GetTask(i) != ESCAPE_FROM_BOMB) || fPlantedC4Distance > 2000.0) && GetEntData(i, g_iBotNearbyEnemiesOffset) == 0 && !g_bDontSwitch[i])
					{
						SDKCall(g_hSwitchWeaponCall, i, GetPlayerWeaponSlot(i, CS_SLOT_KNIFE), 0);
						BotMoveTo(i, fPlantedC4Location, FASTEST_ROUTE);
					}
				}
			}
		}
	}
	
	return Plugin_Continue;
}

public Action Timer_DropWeapons(Handle hTimer, any data)
{
	if(GetGameTime() - g_fRoundStart > 3.0)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!g_bHasGottenDrop[i] && IsValidClient(i) && IsPlayerAlive(i))
			{
				int iAccount = GetEntProp(i, Prop_Send, "m_iAccount");
				bool bInBuyZone = !!GetEntProp(i, Prop_Send, "m_bInBuyZone");
				int iTeam = GetClientTeam(i);
				
				if(!g_bFreezetimeEnd && bInBuyZone)
				{
					int iPrimary = GetPlayerWeaponSlot(i, CS_SLOT_PRIMARY);
					
					if(!IsValidEntity(iPrimary) && iAccount < g_cvBotEcoLimit.IntValue)
					{
						for (int j = 1; j <= MaxClients; j++)
						{
							if (!g_bDropWeapon[j] && IsValidClient(j) && IsFakeClient(j) && IsPlayerAlive(j) && GetClientTeam(j) == iTeam)
							{
								int iOtherPrimary = GetPlayerWeaponSlot(j, CS_SLOT_PRIMARY);
								int iMoney = GetEntProp(j, Prop_Send, "m_iAccount");
								
								if(IsValidEntity(iOtherPrimary))
								{
									int iDefIndex = GetEntProp(iOtherPrimary, Prop_Send, "m_iItemDefinitionIndex");
									GetEntityClassname(iOtherPrimary, g_szPreviousBuy[j], 128);
									ReplaceString(g_szPreviousBuy[j], 128, "weapon_", "");
									CSWeaponID pWeaponID = CS_ItemDefIndexToID(iDefIndex);
									
									if(pWeaponID != CSWeapon_NONE && iMoney >= CS_GetWeaponPrice(j, pWeaponID))
									{
										float fEyes[3];
										
										GetClientEyePosition(i, fEyes);
										BotSetLookAt(j, "Use entity", fEyes, PRIORITY_HIGH, 3.0, false, 5.0, false);
										g_bDropWeapon[j] = true;
										g_bHasGottenDrop[i] = true;
										break;
									}
								}
							}
						}
					}
				}
			}
		}
	}
	
	return g_bFreezetimeEnd ? Plugin_Stop : Plugin_Continue;
}

public void OnMapEnd()
{
	SDKUnhook(GetPlayerResourceEntity(), SDKHook_ThinkPost, OnThinkPost);
}

public void OnClientPostAdminCheck(int client)
{
	g_iProfileRank[client] = Math_GetRandomInt(1, 40);
	
	if(!IsFakeClient(client))
	{
		char szColor[64];
		GetClientInfo(client, "cl_color", szColor, sizeof(szColor));
		g_iPlayerColor[client] = StringToInt(szColor);
	}
	
	if (IsValidClient(client) && IsFakeClient(client))
	{
		char szBotName[MAX_NAME_LENGTH];
		
		GetClientName(client, szBotName, sizeof(szBotName));
		g_bIsProBot[client] = false;
		SDKHook(client, SDKHook_WeaponDrop, OnWeaponDrop);
		
		if(IsProBot(szBotName, g_szCrosshairCode[client], 35))
		{
			if(strcmp(szBotName, "s1mple") == 0 || strcmp(szBotName, "ZywOo") == 0 || strcmp(szBotName, "NiKo") == 0 || strcmp(szBotName, "sh1ro") == 0 || strcmp(szBotName, "jL") == 0 || strcmp(szBotName, "donk") == 0)
			{
				g_fLookAngleMaxAccel[client] = 20000.0;
				g_fReactionTime[client] = 0.0;
			}
			else
			{
				g_fLookAngleMaxAccel[client] = Math_GetRandomFloat(4000.0, 7000.0);
				g_fReactionTime[client] = Math_GetRandomFloat(0.165, 0.325);
			}
			g_fAggression[client] = Math_GetRandomFloat(0.0, 1.0);
			g_bIsProBot[client] = true;
		}
		
		g_bUseUSP[client] = IsItMyChance(75.0) ? true : false;
		g_bUseM4A1S[client] = IsItMyChance(50.0) ? true : false;
		g_bUseCZ75[client] = IsItMyChance(20.0) ? true : false;
		g_pCurrArea[client] = INVALID_NAV_AREA;
	}
}

public void OnRoundPreStart(Event eEvent, char[] szName, bool bDontBroadcast)
{
	g_iCurrentRound = GameRules_GetProp("m_totalRoundsPlayed");

	if(ShouldForce())
		g_cvBotEcoLimit.IntValue = 0;
	else
		g_cvBotEcoLimit.IntValue = 3000;
}

public void OnRoundStart(Event eEvent, char[] szName, bool bDontBroadcast)
{
	int iTeam = g_bIsBombScenario ? CS_TEAM_CT : CS_TEAM_T;
	int iOppositeTeam = g_bIsBombScenario ? CS_TEAM_T : CS_TEAM_CT;
	
	g_bFreezetimeEnd = false;
	g_bEveryoneDead = false;
	g_fRoundStart = GetGameTime();
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && IsFakeClient(i) && IsPlayerAlive(i))
		{	
			g_bUncrouch[i] = IsItMyChance(50.0) ? true : false;
			g_bDontSwitch[i] = false;
			g_bDropWeapon[i] = false;
			g_bHasGottenDrop[i] = false;
			g_bThrowGrenade[i] = false;
			g_iTarget[i] = -1;
			g_iPrevTarget[i] = -1;
			g_iDoingSmokeNum[i] = -1;
			g_fShootTimestamp[i] = 0.0;				
			g_fThrowNadeTimestamp[i] = 0.0;				
			g_fCrouchTimestamp[i] = 0.0;									
			
			if(g_bIsBombScenario || g_bIsHostageScenario)
			{
				if(GetClientTeam(i) == iTeam)
					SetEntData(i, g_iBotMoraleOffset, -3);
				if(g_bHalftimeSwitch && GetClientTeam(i) == iOppositeTeam)
					SetEntData(i, g_iBotMoraleOffset, 1);
			}
		}
	}
	
	g_bHalftimeSwitch = false;
	if(g_bIsCompetitive)
		CreateTimer(0.2, Timer_DropWeapons, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

public void OnRoundEnd(Event eEvent, char[] szName, bool bDontBroadcast)
{
	int iTeamNum, iEnt = -1;
	while((iEnt = FindEntityByClassname(iEnt, "cs_team_manager")) != -1 )
	{
		iTeamNum = GetEntProp(iEnt, Prop_Send, "m_iTeamNum");        
		if(iTeamNum == CS_TEAM_CT)
			g_iCTScore = GetEntProp(iEnt, Prop_Send, "m_scoreTotal");
		else if(iTeamNum == CS_TEAM_T)
			g_iTScore = GetEntProp(iEnt, Prop_Send, "m_scoreTotal");
	}
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && IsFakeClient(i) && BotMimic_IsPlayerMimicing(i))
			BotMimic_StopPlayerMimic(i);
	}
	
	g_iRoundsPlayed = g_iCTScore + g_iTScore;
	
	for(int i = 0; i < g_iMaxNades; i++)
	{			
		g_fNadeTimestamp[i] = 0.0;
	}
}

public void OnFreezetimeEnd(Event eEvent, char[] szName, bool bDontBroadcast)
{
	g_bFreezetimeEnd = true;
	g_fFreezeTimeEnd = GetGameTime();
}

public void OnWeaponZoom(Event eEvent, const char[] szName, bool bDontBroadcast)
{
	int client = GetClientOfUserId(eEvent.GetInt("userid"));
	
	if (IsValidClient(client) && IsFakeClient(client) && IsPlayerAlive(client))
		g_fShootTimestamp[client] = GetGameTime();
}

public void OnWeaponFire(Event eEvent, const char[] szName, bool bDontBroadcast)
{
	int client = GetClientOfUserId(eEvent.GetInt("userid"));
	if(IsValidClient(client) && IsFakeClient(client) && IsPlayerAlive(client))
	{
		char szWeaponName[64];
		eEvent.GetString("weapon", szWeaponName, sizeof(szWeaponName));
		
		if(IsValidClient(g_iTarget[client]))
		{
			float fTargetLoc[3];
			
			GetClientAbsOrigin(g_iTarget[client], fTargetLoc);
			
			float fRangeToEnemy = GetVectorDistance(g_fBotOrigin[client], fTargetLoc);
			
			if (strcmp(szWeaponName, "weapon_deagle") == 0 && fRangeToEnemy > 100.0)
				SetEntDataFloat(client, g_iFireWeaponOffset, GetEntDataFloat(client, g_iFireWeaponOffset) + Math_GetRandomFloat(0.20, 0.40));
		}
		
		if ((strcmp(szWeaponName, "weapon_awp") == 0 || strcmp(szWeaponName, "weapon_ssg08") == 0) && IsItMyChance(50.0))
			RequestFrame(BeginQuickSwitch, GetClientUserId(client));
	}
}

public void OnThinkPost(int iEnt)
{
	SetEntDataArray(iEnt, g_iProfileRankOffset, g_iProfileRank, MAXPLAYERS + 1);
	SetEntDataArray(iEnt, g_iPlayerColorOffset, g_iPlayerColor, MAXPLAYERS + 1);
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && IsFakeClient(i))
			SetCrosshairCode(GetEntityAddress(iEnt), i, g_szCrosshairCode[i]);
	}
}

public Action OnWeaponDrop(int client, int iWeapon)
{
	if(!IsValidEntity(iWeapon))
		return Plugin_Continue;

	if(eItems_GetWeaponSlotByWeapon(iWeapon) != CS_SLOT_PRIMARY)
		return Plugin_Continue;

	int iDroppedWeapon = GetNearestEntity(client, "weapon_*");
	if(!IsValidEntity(iDroppedWeapon))
		return Plugin_Continue;
	
	float fWeaponOrigin[3];
	GetEntPropVector(iDroppedWeapon, Prop_Send, "m_vecOrigin", fWeaponOrigin);
	
	if(GetVectorDistance(g_fBotOrigin[client], fWeaponOrigin) > 75.0)
		return Plugin_Continue;
	
	int iDefIndex = GetEntProp(iWeapon, Prop_Send, "m_iItemDefinitionIndex");
	int iDroppedDefIndex = GetEntProp(iDroppedWeapon, Prop_Send, "m_iItemDefinitionIndex");
	
	if(iDefIndex == 9 || (iDefIndex == 60 && (iDroppedDefIndex != 9 && iDroppedDefIndex != 7)))
		return Plugin_Handled; 
	
	return Plugin_Continue;
}

public Action CS_OnBuyCommand(int client, const char[] szWeapon)
{
	if (IsValidClient(client) && IsFakeClient(client) && IsPlayerAlive(client))
	{
		if (strcmp(szWeapon, "molotov") == 0 || strcmp(szWeapon, "incgrenade") == 0 || strcmp(szWeapon, "decoy") == 0 || strcmp(szWeapon, "flashbang") == 0 || strcmp(szWeapon, "hegrenade") == 0
			 || strcmp(szWeapon, "smokegrenade") == 0 || strcmp(szWeapon, "vest") == 0 || strcmp(szWeapon, "vesthelm") == 0 || strcmp(szWeapon, "defuser") == 0)
			return Plugin_Continue;
		else if (GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY) != -1 && (strcmp(szWeapon, "galilar") == 0 || strcmp(szWeapon, "famas") == 0 || strcmp(szWeapon, "ak47") == 0
				 || strcmp(szWeapon, "m4a1") == 0 || strcmp(szWeapon, "ssg08") == 0 || strcmp(szWeapon, "aug") == 0 || strcmp(szWeapon, "sg556") == 0 || strcmp(szWeapon, "awp") == 0
				 || strcmp(szWeapon, "scar20") == 0 || strcmp(szWeapon, "g3sg1") == 0 || strcmp(szWeapon, "nova") == 0 || strcmp(szWeapon, "xm1014") == 0 || strcmp(szWeapon, "mag7") == 0
				 || strcmp(szWeapon, "m249") == 0 || strcmp(szWeapon, "negev") == 0 || strcmp(szWeapon, "mac10") == 0 || strcmp(szWeapon, "mp9") == 0 || strcmp(szWeapon, "mp7") == 0
				 || strcmp(szWeapon, "ump45") == 0 || strcmp(szWeapon, "p90") == 0 || strcmp(szWeapon, "bizon") == 0))
			return Plugin_Handled;
		
		int iAccount = GetEntProp(client, Prop_Send, "m_iAccount");
		
		if (strcmp(szWeapon, "m4a1") == 0)
		{
			if (g_bUseM4A1S[client] && iAccount >= CS_GetWeaponPrice(client, CSWeapon_M4A1_SILENCER))
			{
				CSGO_SetMoney(client, iAccount - CS_GetWeaponPrice(client, CSWeapon_M4A1_SILENCER));
				CSGO_ReplaceWeapon(client, CS_SLOT_PRIMARY, "weapon_m4a1_silencer");
				
				return Plugin_Changed;
			}
			
			if (IsItMyChance(5.0) && iAccount >= CS_GetWeaponPrice(client, CSWeapon_AUG))
			{
				CSGO_SetMoney(client, iAccount - CS_GetWeaponPrice(client, CSWeapon_AUG));
				CSGO_ReplaceWeapon(client, CS_SLOT_PRIMARY, "weapon_aug");
				
				return Plugin_Changed;
			}
		}
		else if (strcmp(szWeapon, "mac10") == 0)
		{
			if (IsItMyChance(40.0) && iAccount >= CS_GetWeaponPrice(client, CSWeapon_GALILAR))
			{
				CSGO_SetMoney(client, iAccount - CS_GetWeaponPrice(client, CSWeapon_GALILAR));
				CSGO_ReplaceWeapon(client, CS_SLOT_PRIMARY, "weapon_galilar");
				
				return Plugin_Changed;
			}
		}
		else if (strcmp(szWeapon, "mp9") == 0)
		{
			if (IsItMyChance(40.0) && iAccount >= CS_GetWeaponPrice(client, CSWeapon_FAMAS))
			{
				CSGO_SetMoney(client, iAccount - CS_GetWeaponPrice(client, CSWeapon_FAMAS));
				CSGO_ReplaceWeapon(client, CS_SLOT_PRIMARY, "weapon_famas");
				
				return Plugin_Changed;
			}
			else if (IsItMyChance(15.0) && iAccount >= CS_GetWeaponPrice(client, CSWeapon_UMP45))
			{
				CSGO_SetMoney(client, iAccount - CS_GetWeaponPrice(client, CSWeapon_UMP45));
				CSGO_ReplaceWeapon(client, CS_SLOT_PRIMARY, "weapon_ump45");
				
				return Plugin_Changed;
			}
		}
		else if (strcmp(szWeapon, "tec9") == 0 || strcmp(szWeapon, "fiveseven") == 0)
		{
			if (g_bUseCZ75[client])
			{
				CSGO_SetMoney(client, iAccount - CS_GetWeaponPrice(client, CSWeapon_CZ75A));
				CSGO_ReplaceWeapon(client, CS_SLOT_PRIMARY, "weapon_cz75a");
				
				return Plugin_Changed;
			}
		}
	}
	return Plugin_Continue;
}

public MRESReturn BotCOS(DHookReturn hReturn)
{
	hReturn.Value = 0;
	return MRES_Supercede;
}

public MRESReturn BotSIN(DHookReturn hReturn)
{
	hReturn.Value = 0;
	return MRES_Supercede;
}

public MRESReturn CCSBot_GetPartPosition(DHookReturn hReturn, DHookParam hParams)
{
	int iPlayer = hParams.Get(1);
	int iPart = hParams.Get(2);
	
	if(iPart == 2)
	{
		int iBone = LookupBone(iPlayer, "head_0");
		if (iBone < 0)
			return MRES_Ignored;
		
		float fHead[3], fBad[3];
		GetBonePosition(iPlayer, iBone, fHead, fBad);
		
		fHead[2] += 4.0;
		
		hReturn.SetVector(fHead);
		
		return MRES_Override;
	}
	
	return MRES_Ignored;
}

public MRESReturn CCSBot_SetLookAt(int client, DHookParam hParams)
{
	char szDesc[64];
	
	DHookGetParamString(hParams, 1, szDesc, sizeof(szDesc));
	
	if (strcmp(szDesc, "Defuse bomb") == 0 || strcmp(szDesc, "Use entity") == 0 || strcmp(szDesc, "Open door") == 0 || strcmp(szDesc, "Hostage") == 0)
		return MRES_Ignored;
	else if (strcmp(szDesc, "Avoid Flashbang") == 0)
	{
		DHookSetParam(hParams, 3, PRIORITY_HIGH);
		
		return MRES_ChangedHandled;
	}
	else if (strcmp(szDesc, "Blind") == 0 || strcmp(szDesc, "Face outward") == 0)
		return MRES_Supercede;
	else if (strcmp(szDesc, "Breakable") == 0 || strcmp(szDesc, "Plant bomb on floor") == 0)
	{
		g_bDontSwitch[client] = true;
		CreateTimer(5.0, Timer_EnableSwitch, GetClientUserId(client));
		
		return strcmp(szDesc, "Plant bomb on floor") == 0 ? MRES_Supercede : MRES_Ignored;
	}
	else if(strcmp(szDesc, "GrenadeThrowBend") == 0)
	{
		float fEyePos[3];
		GetClientEyePosition(client, fEyePos);
		hParams.GetVector(2, g_fNadeTarget[client]);
		BotBendLineOfSight(client, fEyePos, g_fNadeTarget[client], g_fNadeTarget[client], 135.0);
		hParams.SetVector(2, g_fNadeTarget[client]);
		hParams.Set(4, 8.0);
		hParams.Set(6, 1.5);
		
		return MRES_ChangedHandled;
	}
	else if(strcmp(szDesc, "Noise") == 0)
	{
		bool bIsWalking = !!GetEntProp(client, Prop_Send, "m_bIsWalking");
		float fClientEyes[3], fNoisePosition[3];
		
		GetClientEyePosition(client, fClientEyes);
		if(IsItMyChance(35.0) && IsPointVisible(fClientEyes, fNoisePosition) && LineGoesThroughSmoke(fClientEyes, fNoisePosition) && !bIsWalking)
			DHookSetParam(hParams, 7, true);
			
		DHookGetParamVector(hParams, 2, fNoisePosition);
		
		if(GetGameTime() - g_fThrowNadeTimestamp[client] > 5.0 && IsValidEntity(GetPlayerWeaponSlot(client, CS_SLOT_GRENADE)) && IsItMyChance(1.0) && GetTask(client) != ESCAPE_FROM_BOMB && GetTask(client) != ESCAPE_FROM_FLAMES && GetEntityMoveType(client) != MOVETYPE_LADDER)
		{
			ProcessGrenadeThrow(client, fNoisePosition);
			return MRES_Supercede;
		}
		
		if(eItems_GetWeaponSlotByWeapon(g_iActiveWeapon[client]) == CS_SLOT_KNIFE && GetTask(client) != ESCAPE_FROM_BOMB && GetTask(client) != ESCAPE_FROM_FLAMES)
			BotEquipBestWeapon(client, true);
		
		g_bDontSwitch[client] = true;
		CreateTimer(5.0, Timer_EnableSwitch, GetClientUserId(client));
		
		fNoisePosition[2] += 25.0;
		DHookSetParamVector(hParams, 2, fNoisePosition);
		
		return MRES_ChangedHandled;
	}
	else if(strcmp(szDesc, "Nearby enemy gunfire") == 0)
	{
		float fPos[3], fClientEyes[3];
		GetClientEyePosition(client, fClientEyes);
		DHookGetParamVector(hParams, 2, fPos);
		
		if(GetGameTime() - g_fThrowNadeTimestamp[client] > 5.0 && IsValidEntity(GetPlayerWeaponSlot(client, CS_SLOT_GRENADE)) && IsItMyChance(20.0) && BotBendLineOfSight(client, fClientEyes, fPos, fPos, 135.0) && GetTask(client) != ESCAPE_FROM_BOMB && GetTask(client) != ESCAPE_FROM_FLAMES && GetEntityMoveType(client) != MOVETYPE_LADDER)
		{
			ProcessGrenadeThrow(client, fPos);
			return MRES_Supercede;
		}
		
		fPos[2] += 25.0;
		DHookSetParamVector(hParams, 2, fPos);
		
		return MRES_ChangedHandled;
	}
	else
	{
		float fPos[3];
		
		DHookGetParamVector(hParams, 2, fPos);
		fPos[2] += 25.0;
		DHookSetParamVector(hParams, 2, fPos);
		
		return MRES_ChangedHandled;
	}
}

public MRESReturn CCSBot_PickNewAimSpot(int client, DHookParam hParams)
{
	if (g_bIsProBot[client])
	{
		SelectBestTargetPos(client, g_fTargetPos[client]);
		
		if (!IsValidClient(g_iTarget[client]) || !IsPlayerAlive(g_iTarget[client]) || g_fTargetPos[client][2] == 0)
			return MRES_Ignored;
		
		SetEntDataVector(client, g_iBotTargetSpotOffset, g_fTargetPos[client]);
	}
	
	return MRES_Ignored;
}

public Action OnPlayerRunCmd(int client, int &iButtons, int &iImpulse, float fVel[3], float fAngles[3], int &iWeapon, int &iSubtype, int &iCmdNum, int &iTickCount, int &iSeed, int iMouse[2])
{
	g_bBombPlanted = !!GameRules_GetProp("m_bBombPlanted");

	if (IsValidClient(client) && IsPlayerAlive(client) && IsFakeClient(client))
	{
		if(!g_bFreezetimeEnd && g_bDropWeapon[client] && view_as<LookAtSpotState>(GetEntData(client, g_iBotLookAtSpotStateOffset)) == LOOK_AT_SPOT)
		{
			CS_DropWeapon(client, GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY), true);
			FakeClientCommand(client, "buy %s", g_szPreviousBuy[client]);
			g_bDropWeapon[client] = false;
		}
		
		GetClientAbsOrigin(client, g_fBotOrigin[client]);
		g_iActiveWeapon[client] = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if (!IsValidEntity(g_iActiveWeapon[client])) return Plugin_Continue;
		
		if(g_bFreezetimeEnd)
		{			
			int iDefIndex = GetEntProp(g_iActiveWeapon[client], Prop_Send, "m_iItemDefinitionIndex");
			float fPlayerVelocity[3], fSpeed;
			GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", fPlayerVelocity);
			fPlayerVelocity[2] = 0.0;
			fSpeed = GetVectorLength(fPlayerVelocity);
			
			g_pCurrArea[client] = NavMesh_GetNearestArea(g_fBotOrigin[client]);
			
			if ((GetAliveTeamCount(CS_TEAM_T) == 0 || GetAliveTeamCount(CS_TEAM_CT) == 0) && !g_bDontSwitch[client])
			{
				SDKCall(g_hSwitchWeaponCall, client, GetPlayerWeaponSlot(client, CS_SLOT_KNIFE), 0);
				g_bEveryoneDead = true;
			}
				
			if(IsItMyChance(0.5) && g_iDoingSmokeNum[client] == -1)
				g_iDoingSmokeNum[client] = GetNearestGrenade(client);
			
			if(GetDisposition(client) == SELF_DEFENSE)
				SetDisposition(client, ENGAGE_AND_INVESTIGATE);
			
			if(g_pCurrArea[client] != INVALID_NAV_AREA)
			{							
				if (g_pCurrArea[client].Attributes & NAV_MESH_WALK)
					iButtons |= IN_SPEED;
				
				if (g_pCurrArea[client].Attributes & NAV_MESH_RUN)
					iButtons &= ~IN_SPEED;
			}
			
			if(g_iDoingSmokeNum[client] != -1 && !BotMimic_IsPlayerMimicing(client))
			{
				g_fNadeTimestamp[g_iDoingSmokeNum[client]] = GetGameTime();
				float fDisToNade = GetVectorDistance(g_fBotOrigin[client], g_fNadePos[g_iDoingSmokeNum[client]]);
				
				BotMoveTo(client, g_fNadePos[g_iDoingSmokeNum[client]], FASTEST_ROUTE);
					
				if(fDisToNade < 25.0)
				{					
					BotSetLookAt(client, "Use entity", g_fNadeLook[g_iDoingSmokeNum[client]], PRIORITY_HIGH, 2.0, false, 3.0, false);
					
					if(view_as<LookAtSpotState>(GetEntData(client, g_iBotLookAtSpotStateOffset)) == LOOK_AT_SPOT && fSpeed == 0.0 && (GetEntityFlags(client) & FL_ONGROUND))
						BotMimic_PlayRecordFromFile(client, g_szReplay[g_iDoingSmokeNum[client]]);
				}
			}
			
			if(g_bThrowGrenade[client] && eItems_GetWeaponSlotByDefIndex(iDefIndex) == CS_SLOT_GRENADE)
			{
				BotThrowGrenade(client, g_fNadeTarget[client]);
				g_fThrowNadeTimestamp[client] = GetGameTime();
			}
			
			if(IsSafe(client) || g_bEveryoneDead)
				iButtons &= ~IN_SPEED;
				
			if (g_bIsProBot[client])
			{
				int iDroppedC4 = GetNearestEntity(client, "weapon_c4");
				
				if ((!g_bBombPlanted && !IsValidEntity(iDroppedC4) && !BotIsHiding(client) && GetTask(client) != COLLECT_HOSTAGES && GetTask(client) != RESCUE_HOSTAGES) || (g_bEveryoneDead && GetTask(client) != DEFUSE_BOMB))
				{
					float fClientEyes[3];
					GetClientEyePosition(client, fClientEyes);
				
					//Rifles
					int iAK47 = GetNearestEntity(client, "weapon_ak47");
					int iM4A1 = GetNearestEntity(client, "weapon_m4a1");
					int iPrimary = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
					int iPrimaryDefIndex;

					if (IsValidEntity(iAK47))
					{
						iPrimaryDefIndex = IsValidEntity(iPrimary) ? GetEntProp(iPrimary, Prop_Send, "m_iItemDefinitionIndex") : 0;
						float fAK47Location[3];
						
						if ((iPrimaryDefIndex != 7 && iPrimaryDefIndex != 9) || iPrimary == -1)
						{
							GetEntPropVector(iAK47, Prop_Send, "m_vecOrigin", fAK47Location);

							if (IsPointVisible(fClientEyes, fAK47Location))
								BotMoveTo(client, fAK47Location, FASTEST_ROUTE);
						}
					}
					else if (IsValidEntity(iM4A1))
					{
						iPrimaryDefIndex = IsValidEntity(iPrimary) ? GetEntProp(iPrimary, Prop_Send, "m_iItemDefinitionIndex") : 0;
						float fM4A1Location[3];

						if (iPrimaryDefIndex != 7 && iPrimaryDefIndex != 9 && iPrimaryDefIndex != 16 && iPrimaryDefIndex != 60)
						{
							GetEntPropVector(iM4A1, Prop_Send, "m_vecOrigin", fM4A1Location);

							if (IsPointVisible(fClientEyes, fM4A1Location))
							{
								BotMoveTo(client, fM4A1Location, FASTEST_ROUTE);
								if (GetVectorDistance(g_fBotOrigin[client], fM4A1Location) < 50.0 && GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY) != -1)
									CS_DropWeapon(client, GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY), false);
							}
						}
						else if (iPrimary == -1)
						{
							GetEntPropVector(iM4A1, Prop_Send, "m_vecOrigin", fM4A1Location);

							if (IsPointVisible(fClientEyes, fM4A1Location))
								BotMoveTo(client, fM4A1Location, FASTEST_ROUTE);
						}
					}
					
					//Pistols
					int iUSP = GetNearestEntity(client, "weapon_hkp2000");
					int iP250 = GetNearestEntity(client, "weapon_p250");
					int iFiveSeven = GetNearestEntity(client, "weapon_fiveseven");
					int iTec9 = GetNearestEntity(client, "weapon_tec9");
					int iDeagle = GetNearestEntity(client, "weapon_deagle");
					int iSecondary = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
					int iSecondaryDefIndex;
					
					if (IsValidEntity(iDeagle))
					{						
						iSecondaryDefIndex = IsValidEntity(iSecondary) ? GetEntProp(iSecondary, Prop_Send, "m_iItemDefinitionIndex") : 0;
						float fDeagleLocation[3];
						
						if (iSecondaryDefIndex == 4 || iSecondaryDefIndex == 32 || iSecondaryDefIndex == 61 || iSecondaryDefIndex == 36 || iSecondaryDefIndex == 30 || iSecondaryDefIndex == 3 || iSecondaryDefIndex == 63)
						{
							GetEntPropVector(iDeagle, Prop_Send, "m_vecOrigin", fDeagleLocation);
							
							if (IsPointVisible(fClientEyes, fDeagleLocation))
							{
								BotMoveTo(client, fDeagleLocation, FASTEST_ROUTE);
								if (GetVectorDistance(g_fBotOrigin[client], fDeagleLocation) < 50.0 && GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY) != -1)
									CS_DropWeapon(client, GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY), false);
							}
						}
					}
					else if (IsValidEntity(iTec9))
					{						
						iSecondaryDefIndex = IsValidEntity(iSecondary) ? GetEntProp(iSecondary, Prop_Send, "m_iItemDefinitionIndex") : 0;
						float fTec9Location[3];
						
						if (iSecondaryDefIndex == 4 || iSecondaryDefIndex == 32 || iSecondaryDefIndex == 61 || iSecondaryDefIndex == 36)
						{
							GetEntPropVector(iTec9, Prop_Send, "m_vecOrigin", fTec9Location);
							
							if (IsPointVisible(fClientEyes, fTec9Location))
							{
								BotMoveTo(client, fTec9Location, FASTEST_ROUTE);
								if (GetVectorDistance(g_fBotOrigin[client], fTec9Location) < 50.0 && GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY) != -1)
									CS_DropWeapon(client, GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY), false);
							}
						}
					}
					else if (IsValidEntity(iFiveSeven))
					{
						iSecondaryDefIndex = IsValidEntity(iSecondary) ? GetEntProp(iSecondary, Prop_Send, "m_iItemDefinitionIndex") : 0;
						float fFiveSevenLocation[3];
						
						if (iSecondaryDefIndex == 4 || iSecondaryDefIndex == 32 || iSecondaryDefIndex == 61 || iSecondaryDefIndex == 36)
						{
							GetEntPropVector(iFiveSeven, Prop_Send, "m_vecOrigin", fFiveSevenLocation);
							
							if (IsPointVisible(fClientEyes, fFiveSevenLocation))
							{
								BotMoveTo(client, fFiveSevenLocation, FASTEST_ROUTE);
								if (GetVectorDistance(g_fBotOrigin[client], fFiveSevenLocation) < 50.0 && GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY) != -1)
									CS_DropWeapon(client, GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY), false);
							}
						}
					}
					else if (IsValidEntity(iP250))
					{
						iSecondaryDefIndex = IsValidEntity(iSecondary) ? GetEntProp(iSecondary, Prop_Send, "m_iItemDefinitionIndex") : 0;
						float fP250Location[3];
						
						if (iSecondaryDefIndex == 4 || iSecondaryDefIndex == 32 || iSecondaryDefIndex == 61)
						{
							GetEntPropVector(iP250, Prop_Send, "m_vecOrigin", fP250Location);
							
							if (IsPointVisible(fClientEyes, fP250Location))
							{
								BotMoveTo(client, fP250Location, FASTEST_ROUTE);
								if (GetVectorDistance(g_fBotOrigin[client], fP250Location) < 50.0 && GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY) != -1)
									CS_DropWeapon(client, GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY), false);
							}
						}
					}
					else if (IsValidEntity(iUSP))
					{
						iSecondaryDefIndex = IsValidEntity(iSecondary) ? GetEntProp(iSecondary, Prop_Send, "m_iItemDefinitionIndex") : 0;
						float fUSPLocation[3];
						
						if (iSecondaryDefIndex == 4)
						{
							GetEntPropVector(iUSP, Prop_Send, "m_vecOrigin", fUSPLocation);
							
							if (IsPointVisible(fClientEyes, fUSPLocation))
							{
								BotMoveTo(client, fUSPLocation, FASTEST_ROUTE);
								if (GetVectorDistance(g_fBotOrigin[client], fUSPLocation) < 50.0 && GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY) != -1)
									CS_DropWeapon(client, GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY), false);
							}
						}
					}
				}
			}
			
			if (g_bIsProBot[client] && GetDisposition(client) != IGNORE_ENEMIES)
			{		
				g_iTarget[client] = BotGetEnemy(client);
				
				float fTargetDistance;
				int iZoomLevel;
				bool bIsEnemyVisible = !!GetEntData(client, g_iEnemyVisibleOffset);
				bool bIsHiding = BotIsHiding(client);
				bool bIsDucking = !!(GetEntityFlags(client) & FL_DUCKING);
				bool bIsReloading = IsPlayerReloading(client);
				bool bResumeZoom = !!GetEntProp(client, Prop_Send, "m_bResumeZoom");
				
				if(bResumeZoom)
					g_fShootTimestamp[client] = GetGameTime();
				
				if(HasEntProp(g_iActiveWeapon[client], Prop_Send, "m_zoomLevel"))
					iZoomLevel = GetEntProp(g_iActiveWeapon[client], Prop_Send, "m_zoomLevel");
				
				if(bIsHiding && (iDefIndex == 8 || iDefIndex == 39) && iZoomLevel == 0)
					iButtons |= IN_ATTACK2;
				else if(!bIsHiding && (iDefIndex == 8 || iDefIndex == 39) && iZoomLevel == 1)
					iButtons |= IN_ATTACK2;
				
				if (bIsHiding && g_bUncrouch[client])
					iButtons &= ~IN_DUCK;
					
				if (!IsValidClient(g_iTarget[client]) || !IsPlayerAlive(g_iTarget[client]) || g_fTargetPos[client][2] == 0)
				{
					g_iPrevTarget[client] = g_iTarget[client];
					return Plugin_Continue;
				}
				
				if ((eItems_GetWeaponSlotByDefIndex(iDefIndex) == CS_SLOT_KNIFE || eItems_GetWeaponSlotByDefIndex(iDefIndex) == CS_SLOT_GRENADE) && GetTask(client) != ESCAPE_FROM_BOMB && GetTask(client) != ESCAPE_FROM_FLAMES)
						BotEquipBestWeapon(client, true);
				
				if (bIsEnemyVisible && GetEntityMoveType(client) != MOVETYPE_LADDER)
				{
					if(g_iPrevTarget[client] == -1)
						g_fCrouchTimestamp[client] = GetGameTime() + Math_GetRandomFloat(0.23, 0.25);
					fTargetDistance = GetVectorDistance(g_fBotOrigin[client], g_fTargetPos[client]);
					
					float fClientEyes[3], fClientAngles[3], fAimPunchAngle[3], fToAimSpot[3], fAimDir[3];
						
					GetClientEyePosition(client, fClientEyes);
					SubtractVectors(g_fTargetPos[client], fClientEyes, fToAimSpot);
					GetClientEyeAngles(client, fClientAngles);
					GetEntPropVector(client, Prop_Send, "m_aimPunchAngle", fAimPunchAngle);
					ScaleVector(fAimPunchAngle, (FindConVar("weapon_recoil_scale").FloatValue));
					AddVectors(fClientAngles, fAimPunchAngle, fClientAngles);
					GetViewVector(fClientAngles, fAimDir);
					
					float fRangeToEnemy = NormalizeVector(fToAimSpot, fToAimSpot);
					float fOnTarget = GetVectorDotProduct(fToAimSpot, fAimDir);
					float fAimTolerance = Cosine(ArcTangent(32.0 / fRangeToEnemy));
					
					if(g_iPrevTarget[client] == -1 && fOnTarget > fAimTolerance)
						g_fCrouchTimestamp[client] = GetGameTime() + Math_GetRandomFloat(0.23, 0.25);
						
					switch(iDefIndex)
					{
						case 7, 8, 10, 13, 14, 16, 17, 19, 23, 24, 25, 26, 28, 33, 34, 39, 60:
						{
							if (fOnTarget > fAimTolerance && !bIsDucking && fTargetDistance < 2000.0 && iDefIndex != 17 && iDefIndex != 19 && iDefIndex != 23 && iDefIndex != 24 && iDefIndex != 25 && iDefIndex != 26 && iDefIndex != 33 && iDefIndex != 34)
								AutoStop(client, fVel, fAngles);
							else if (fTargetDistance > 2000.0 && GetEntDataFloat(client, g_iFireWeaponOffset) == GetGameTime())
								AutoStop(client, fVel, fAngles);
						
							if (fOnTarget > fAimTolerance && fTargetDistance < 2000.0)
							{
								iButtons &= ~IN_ATTACK;
							
								if(!bIsReloading && (fSpeed < 50.0 || bIsDucking || iDefIndex == 17 || iDefIndex == 19 || iDefIndex == 23 || iDefIndex == 24 || iDefIndex == 25 || iDefIndex == 26 || iDefIndex == 33 || iDefIndex == 34))
								{
									iButtons |= IN_ATTACK;
									SetEntDataFloat(client, g_iFireWeaponOffset, GetGameTime());
								}
							}
						}
						case 1:
						{
							if (GetGameTime() - GetEntDataFloat(client, g_iFireWeaponOffset) < 0.15 && !bIsDucking && !bIsReloading)
								AutoStop(client, fVel, fAngles);
						}
						case 9, 40:
						{
							if (fTargetDistance < 2750.0 && !bIsReloading && GetEntProp(client, Prop_Send, "m_bIsScoped") && GetGameTime() - g_fShootTimestamp[client] > 0.4 && GetClientAimTarget(client, true) == g_iTarget[client])
							{
								iButtons |= IN_ATTACK;
								SetEntDataFloat(client, g_iFireWeaponOffset, GetGameTime());
							}	
						}
					}
					
					float fClientLoc[3];
					Array_Copy(g_fBotOrigin[client], fClientLoc, 3);
					fClientLoc[2] += HalfHumanHeight;
					
					if (GetGameTime() >= g_fCrouchTimestamp[client] && !GetEntProp(g_iActiveWeapon[client], Prop_Data, "m_bInReload") && IsPointVisible(fClientLoc, g_fTargetPos[client]) && fOnTarget > fAimTolerance && fTargetDistance < 2000.0 && (iDefIndex == 7 || iDefIndex == 8 || iDefIndex == 10 || iDefIndex == 13 || iDefIndex == 14 || iDefIndex == 16 || iDefIndex == 39 || iDefIndex == 60 || iDefIndex == 28))
						iButtons |= IN_DUCK;
						
					g_iPrevTarget[client] = g_iTarget[client];
				}
			}
			
			return Plugin_Changed;
		}
	}
	
	return Plugin_Continue;
}

public void OnPlayerSpawn(Event eEvent, const char[] szName, bool bDontBroadcast)
{
	int client = GetClientOfUserId(eEvent.GetInt("userid"));
	
	SetPlayerTeammateColor(client);

	if (IsValidClient(client) && IsFakeClient(client))
	{
		if(g_bIsProBot[client])
		{
			Address pLocalProfile = view_as<Address>(GetEntData(client, g_iBotProfileOffset));
			
			//All these offsets are inside BotProfileManager::Init which has strings for every botprofile parameter
			StoreToAddress(pLocalProfile + view_as<Address>(104), view_as<int>(g_fLookAngleMaxAccel[client]), NumberType_Int32);
			StoreToAddress(pLocalProfile + view_as<Address>(116), view_as<int>(g_fLookAngleMaxAccel[client]), NumberType_Int32);
			StoreToAddress(pLocalProfile + view_as<Address>(84), view_as<int>(g_fReactionTime[client]), NumberType_Int32);
			StoreToAddress(pLocalProfile + view_as<Address>(4), view_as<int>(g_fAggression[client]), NumberType_Int32);
		}
		
		if (g_bUseUSP[client] && GetClientTeam(client) == CS_TEAM_CT)
		{
			char szUSP[32];
			
			GetClientWeapon(client, szUSP, sizeof(szUSP));
			
			if (strcmp(szUSP, "weapon_hkp2000") == 0)
				CSGO_ReplaceWeapon(client, CS_SLOT_SECONDARY, "weapon_usp_silencer");
		}
	}
}

public void BotMimic_OnPlayerStopsMimicing(int client, char[] szName, char[] szCategory, char[] szPath)
{
	g_iDoingSmokeNum[client] = -1;
}

public void OnClientDisconnect(int client)
{
	if (IsValidClient(client) && IsFakeClient(client))
	{
		g_iProfileRank[client] = 0;
		SDKUnhook(client, SDKHook_WeaponDrop, OnWeaponDrop);
	}
}

public void eItems_OnItemsSynced()
{
	ServerCommand("changelevel %s", g_szMap);
}

void ParseMapNades(const char[] szMap)
{
	char szPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, szPath, sizeof(szPath), "configs/bot_nades.txt");
	
	if (!FileExists(szPath))
	{
		PrintToServer("Configuration file %s is not found.", szPath);
		return;
	}
	
	KeyValues kv = new KeyValues("Nades");
	
	if (!kv.ImportFromFile(szPath))
	{
		delete kv;
		PrintToServer("Unable to parse Key Values file %s.", szPath);
		return;
	}
	
	if(!kv.JumpToKey(szMap))
	{
		delete kv;
		PrintToServer("No nades found for %s.", szMap);
		return;
	}
	
	if(!kv.GotoFirstSubKey())
	{
		delete kv;
		PrintToServer("Nades are not configured right for %s.", szMap);
		return;
	}
	
	int i = 0;
	do
	{
		char szTeam[4];
		
		kv.GetVector("position", 	g_fNadePos[i]);
		kv.GetVector("lookat", g_fNadeLook[i]);
		g_iNadeDefIndex[i] = kv.GetNum("nadedefindex");
		kv.GetString("replay", g_szReplay[i], 128);
		g_fNadeTimestamp[i] = kv.GetFloat("timestamp");
		kv.GetString("team", szTeam, sizeof(szTeam));
		if(strcmp(szTeam, "CT", false) == 0)
			g_iNadeTeam[i] = CS_TEAM_CT;
		else if(strcmp(szTeam, "T", false) == 0)
			g_iNadeTeam[i] = CS_TEAM_T;
	
		i++;
	} while (kv.GotoNextKey());
	
	delete kv;	
	g_iMaxNades = i;
}

bool IsProBot(const char[] szName, char[] szCrosshairCode, int iSize)
{
	char szPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, szPath, sizeof(szPath), "data/bot_info.json");
	
	if (!FileExists(szPath))
	{
		PrintToServer("Configuration file %s is not found.", szPath);
		return false;
	}
	
	JSONObject jData = JSONObject.FromFile(szPath);
	if(jData.HasKey(szName))
	{
		JSONObject jInfoObj = view_as<JSONObject>(jData.Get(szName));
		jInfoObj.GetString("crosshair_code", szCrosshairCode, iSize);
		delete jInfoObj;
		delete jData;
		return true;
	}
	
	delete jData;
	
	return false;
}

public void LoadSDK()
{
	GameData hGameConfig = new GameData("botstuff.games");
	if (hGameConfig == null)
		SetFailState("Failed to find botstuff.games game config.");
	
	if(!(g_pTheBots = hGameConfig.GetAddress("TheBots")))
		SetFailState("Failed to get TheBots address.");
	
	if ((g_iBotTargetSpotOffset = hGameConfig.GetOffset("CCSBot::m_targetSpot")) == -1)
		SetFailState("Failed to get CCSBot::m_targetSpot offset.");
	
	if ((g_iBotNearbyEnemiesOffset = hGameConfig.GetOffset("CCSBot::m_nearbyEnemyCount")) == -1)
		SetFailState("Failed to get CCSBot::m_nearbyEnemyCount offset.");
	
	if ((g_iFireWeaponOffset = hGameConfig.GetOffset("CCSBot::m_fireWeaponTimestamp")) == -1)
		SetFailState("Failed to get CCSBot::m_fireWeaponTimestamp offset.");
	
	if ((g_iEnemyVisibleOffset = hGameConfig.GetOffset("CCSBot::m_isEnemyVisible")) == -1)
		SetFailState("Failed to get CCSBot::m_isEnemyVisible offset.");
	
	if ((g_iBotProfileOffset = hGameConfig.GetOffset("CCSBot::m_pLocalProfile")) == -1)
		SetFailState("Failed to get CCSBot::m_pLocalProfile offset.");
	
	if ((g_iBotSafeTimeOffset = hGameConfig.GetOffset("CCSBot::m_safeTime")) == -1)
		SetFailState("Failed to get CCSBot::m_safeTime offset.");
	
	if ((g_iBotEnemyOffset = hGameConfig.GetOffset("CCSBot::m_enemy")) == -1)
		SetFailState("Failed to get CCSBot::m_enemy offset.");
	
	if ((g_iBotLookAtSpotStateOffset = hGameConfig.GetOffset("CCSBot::m_lookAtSpotState")) == -1)
		SetFailState("Failed to get CCSBot::m_lookAtSpotState offset.");
	
	if ((g_iBotMoraleOffset = hGameConfig.GetOffset("CCSBot::m_morale")) == -1)
		SetFailState("Failed to get CCSBot::m_morale offset.");
	
	if ((g_iBotTaskOffset = hGameConfig.GetOffset("CCSBot::m_task")) == -1)
		SetFailState("Failed to get CCSBot::m_task offset.");
	
	if ((g_iBotDispositionOffset = hGameConfig.GetOffset("CCSBot::m_disposition")) == -1)
		SetFailState("Failed to get CCSBot::m_disposition offset.");
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConfig, SDKConf_Signature, "CCSBot::MoveTo");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Pointer); // Move Position As Vector, Pointer
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain); // Move Type As Integer
	if ((g_hBotMoveTo = EndPrepSDKCall()) == null)SetFailState("Failed to create SDKCall for CCSBot::MoveTo signature!");
	
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hGameConfig, SDKConf_Signature, "CBaseAnimating::LookupBone");
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	if ((g_hLookupBone = EndPrepSDKCall()) == null)SetFailState("Failed to create SDKCall for CBaseAnimating::LookupBone signature!");
	
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hGameConfig, SDKConf_Signature, "CBaseAnimating::GetBonePosition");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef, _, VENCODE_FLAG_COPYBACK);
	PrepSDKCall_AddParameter(SDKType_QAngle, SDKPass_ByRef, _, VENCODE_FLAG_COPYBACK);
	if ((g_hGetBonePosition = EndPrepSDKCall()) == null)SetFailState("Failed to create SDKCall for CBaseAnimating::GetBonePosition signature!");
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConfig, SDKConf_Signature, "CCSBot::IsVisible");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer, VDECODE_FLAG_ALLOWNULL);
	PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
	if ((g_hBotIsVisible = EndPrepSDKCall()) == null)SetFailState("Failed to create SDKCall for CCSBot::IsVisible signature!");
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConfig, SDKConf_Signature, "CCSBot::IsAtHidingSpot");
	PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
	if ((g_hBotIsHiding = EndPrepSDKCall()) == null)SetFailState("Failed to create SDKCall for CCSBot::IsAtHidingSpot signature!");
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConfig, SDKConf_Signature, "CCSBot::EquipBestWeapon");
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
	if ((g_hBotEquipBestWeapon = EndPrepSDKCall()) == null)SetFailState("Failed to create SDKCall for CCSBot::EquipBestWeapon signature!");
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConfig, SDKConf_Signature, "CCSBot::SetLookAt");
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
	if ((g_hBotSetLookAt = EndPrepSDKCall()) == null)SetFailState("Failed to create SDKCall for CCSBot::SetLookAt signature!");
	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hGameConfig, SDKConf_Signature, "SetCrosshairCode");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	if ((g_hSetCrosshairCode = EndPrepSDKCall()) == null)SetFailState("Failed to create SDKCall for SetCrosshairCode signature!");
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConfig, SDKConf_Virtual, "Weapon_Switch");
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer, VDECODE_FLAG_ALLOWNULL);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	if ((g_hSwitchWeaponCall = EndPrepSDKCall()) == null)SetFailState("Failed to create SDKCall for Weapon_Switch offset!");
	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hGameConfig, SDKConf_Signature, "CBotManager::IsLineBlockedBySmoke");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Pointer);
	PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
	if ((g_hIsLineBlockedBySmoke = EndPrepSDKCall()) == null)SetFailState("Failed to create SDKCall for CBotManager::IsLineBlockedBySmoke offset!");
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConfig, SDKConf_Signature, "CCSBot::BendLineOfSight");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef, _, VENCODE_FLAG_COPYBACK);
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
	if ((g_hBotBendLineOfSight = EndPrepSDKCall()) == null)SetFailState("Failed to create SDKCall for CCSBot::BendLineOfSight signature!");
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConfig, SDKConf_Signature, "CCSBot::ThrowGrenade");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Pointer);
	if ((g_hBotThrowGrenade = EndPrepSDKCall()) == null)SetFailState("Failed to create SDKCall for CCSBot::ThrowGrenade signature!");
	
	delete hGameConfig;
}

public void LoadDetours()
{
	GameData hGameData = new GameData("botstuff.games");   
	if (hGameData == null)
	{
		SetFailState("Failed to load botstuff gamedata.");
		return;
	}
	
	//CCSBot::SetLookAt Detour
	DynamicDetour hBotSetLookAtDetour = DynamicDetour.FromConf(hGameData, "CCSBot::SetLookAt");
	if(!hBotSetLookAtDetour.Enable(Hook_Pre, CCSBot_SetLookAt))
		SetFailState("Failed to setup detour for CCSBot::SetLookAt");
	
	//CCSBot::PickNewAimSpot Detour
	DynamicDetour hBotPickNewAimSpotDetour = DynamicDetour.FromConf(hGameData, "CCSBot::PickNewAimSpot");
	if(!hBotPickNewAimSpotDetour.Enable(Hook_Post, CCSBot_PickNewAimSpot))
		SetFailState("Failed to setup detour for CCSBot::PickNewAimSpot");
	
	//BotCOS Detour
	DynamicDetour hBotCOSDetour = DynamicDetour.FromConf(hGameData, "BotCOS");
	if(!hBotCOSDetour.Enable(Hook_Pre, BotCOS))
		SetFailState("Failed to setup detour for BotCOS");
	
	//BotSIN Detour
	DynamicDetour hBotSINDetour = DynamicDetour.FromConf(hGameData, "BotSIN");
	if(!hBotSINDetour.Enable(Hook_Pre, BotSIN))
		SetFailState("Failed to setup detour for BotSIN");
	
	//CCSBot::GetPartPosition Detour
	DynamicDetour hBotGetPartPosDetour = DynamicDetour.FromConf(hGameData, "CCSBot::GetPartPosition");
	if(!hBotGetPartPosDetour.Enable(Hook_Pre, CCSBot_GetPartPosition))
		SetFailState("Failed to setup detour for CCSBot::GetPartPosition");
	
	delete hGameData;
}

public int LookupBone(int iEntity, const char[] szName)
{
	return SDKCall(g_hLookupBone, iEntity, szName);
}

public void GetBonePosition(int iEntity, int iBone, float fOrigin[3], float fAngles[3])
{
	SDKCall(g_hGetBonePosition, iEntity, iBone, fOrigin, fAngles);
}

public void BotMoveTo(int client, float fOrigin[3], RouteType routeType)
{
	SDKCall(g_hBotMoveTo, client, fOrigin, routeType);
}

bool BotIsVisible(int client, float fPos[3], bool bTestFOV, int iIgnore = -1)
{
	return SDKCall(g_hBotIsVisible, client, fPos, bTestFOV, iIgnore);
}

public bool BotIsHiding(int client)
{
	return SDKCall(g_hBotIsHiding, client);
}

public void BotEquipBestWeapon(int client, bool bMustEquip)
{
	SDKCall(g_hBotEquipBestWeapon, client, bMustEquip);
}

public void BotSetLookAt(int client, const char[] szDesc, const float fPos[3], PriorityType pri, float fDuration, bool bClearIfClose, float fAngleTolerance, bool bAttack)
{
	SDKCall(g_hBotSetLookAt, client, szDesc, fPos, pri, fDuration, bClearIfClose, fAngleTolerance, bAttack);
}

public bool BotBendLineOfSight(int client, const float fEye[3], const float fTarget[3], float fBend[3], float fAngleLimit)
{
	return SDKCall(g_hBotBendLineOfSight, client, fEye, fTarget, fBend, fAngleLimit);
}

public void BotThrowGrenade(int client, const float fTarget[3])
{
	SDKCall(g_hBotThrowGrenade, client, fTarget);
}

public void SetCrosshairCode(Address pCCSPlayerResource, int client, const char[] szCode)
{
	SDKCall(g_hSetCrosshairCode, pCCSPlayerResource, client, szCode);
}

public int BotGetEnemy(int client)
{
	return GetEntDataEnt2(client, g_iBotEnemyOffset);
}

public int GetNearestGrenade(int client)
{
	if(g_bBombPlanted) return -1;

	int iNearestEntity = -1;
	float fVecOrigin[3];
	
	GetClientAbsOrigin(client, fVecOrigin);
	
	//Get the distance between the first entity and client
	float fDistance, fNearestDistance = -1.0;
	
	for(int i = 0; i < g_iMaxNades; i++)
	{		
		if((GetGameTime() - g_fNadeTimestamp[i]) < 25.0)
			continue;
			
		if(!IsValidEntity(eItems_FindWeaponByDefIndex(client, g_iNadeDefIndex[i])))
			continue;
		
		if(GetClientTeam(client) != g_iNadeTeam[i])
			continue;
		
		fDistance = GetVectorDistance(fVecOrigin, g_fNadePos[i]);
		
		if(fDistance > 250.0)
			continue;
		
		if (fDistance < fNearestDistance || fNearestDistance == -1.0)
		{
			iNearestEntity = i;
			fNearestDistance = fDistance;
		}
	}
	
	return iNearestEntity;
} 

stock int GetNearestEntity(int client, char[] szClassname)
{
	int iNearestEntity = -1;
	float fClientOrigin[3], fEntityOrigin[3];
	
	GetClientAbsOrigin(client, fClientOrigin);
	
	//Get the distance between the first entity and client
	float fDistance, fNearestDistance = -1.0;
	
	//Find all the entity and compare the distances
	int iEntity = -1;
	while ((iEntity = FindEntityByClassname(iEntity, szClassname)) != -1)
	{
		GetEntPropVector(iEntity, Prop_Data, "m_vecOrigin", fEntityOrigin); // Line 2610
		fDistance = GetVectorDistance(fClientOrigin, fEntityOrigin);
		
		if (fDistance < fNearestDistance || fNearestDistance == -1.0)
		{
			iNearestEntity = iEntity;
			fNearestDistance = fDistance;
		}
	}
	
	return iNearestEntity;
}

stock void CSGO_SetMoney(int client, int iAmount)
{
	if (iAmount < 0)
		iAmount = 0;
	
	int iMax = FindConVar("mp_maxmoney").IntValue;
	
	if (iAmount > iMax)
		iAmount = iMax;
	
	SetEntProp(client, Prop_Send, "m_iAccount", iAmount);
}

stock int CSGO_ReplaceWeapon(int client, int iSlot, const char[] szClass)
{
	int iWeapon = GetPlayerWeaponSlot(client, iSlot);
	
	if (IsValidEntity(iWeapon))
	{
		if (GetEntPropEnt(iWeapon, Prop_Send, "m_hOwnerEntity") != client)
			SetEntPropEnt(iWeapon, Prop_Send, "m_hOwnerEntity", client);
		
		CS_DropWeapon(client, iWeapon, false, true);
		AcceptEntityInput(iWeapon, "Kill");
	}
	
	iWeapon = GivePlayerItem(client, szClass);
	
	if (IsValidEntity(iWeapon))
		EquipPlayerWeapon(client, iWeapon);
	
	return iWeapon;
}

bool IsPlayerReloading(int client)
{	
	if(!IsValidEntity(g_iActiveWeapon[client]))
		return false;
	
	//Out of ammo?
	if(GetEntProp(g_iActiveWeapon[client], Prop_Data, "m_iClip1") == 0)
		return true;
	
	//Reloading?
	if(GetEntProp(g_iActiveWeapon[client], Prop_Data, "m_bInReload"))
		return true;
	
	//Ready to fire?
	if(GetEntPropFloat(g_iActiveWeapon[client], Prop_Send, "m_flNextPrimaryAttack") <= GetGameTime())
		return false;
	
	return true;
}

public void BeginQuickSwitch(int client)
{
	client = GetClientOfUserId(client);
	
	if(client != 0 && IsClientInGame(client))
	{
		SDKCall(g_hSwitchWeaponCall, client, GetPlayerWeaponSlot(client, CS_SLOT_KNIFE), 0);
		RequestFrame(FinishQuickSwitch, GetClientUserId(client));
	}
}

public void FinishQuickSwitch(int client)
{
	client = GetClientOfUserId(client);
	
	if(client != 0 && IsClientInGame(client))
		SDKCall(g_hSwitchWeaponCall, client, GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY), 0);
}

public Action Timer_EnableSwitch(Handle hTimer, any client)
{
	client = GetClientOfUserId(client);
	
	if(client != 0 && IsClientInGame(client))
		g_bDontSwitch[client] = false;	
	
	return Plugin_Stop;
}

public Action Timer_DontForceThrow(Handle hTimer, any client)
{
	client = GetClientOfUserId(client);
	
	if(client != 0 && IsClientInGame(client))
	{
		g_bThrowGrenade[client] = false;
		BotEquipBestWeapon(client, true);
	}
	
	return Plugin_Stop;
}

public void DelayThrow(any client)
{
	client = GetClientOfUserId(client);
	
	if(client != 0 && IsClientInGame(client))
	{
		g_bThrowGrenade[client] = true;
		CreateTimer(3.0, Timer_DontForceThrow, GetClientUserId(client));
	}
}

public void SelectBestTargetPos(int client, float fTargetPos[3])
{
	if(IsValidClient(g_iTarget[client]) && IsPlayerAlive(g_iTarget[client]))
	{
		int iBone = LookupBone(g_iTarget[client], "head_0");
		int iSpineBone = LookupBone(g_iTarget[client], "spine_3");
		if (iBone < 0 || iSpineBone < 0)
			return;
		
		bool bShootSpine;
		float fHead[3], fBody[3], fBad[3];
		GetBonePosition(g_iTarget[client], iBone, fHead, fBad);
		GetBonePosition(g_iTarget[client], iSpineBone, fBody, fBad);
		
		fHead[2] += 4.0;
		
		if (BotIsVisible(client, fHead, false, -1))
		{
			if (BotIsVisible(client, fBody, false, -1))
			{
				if (!IsValidEntity(g_iActiveWeapon[client])) return;
				
				int iDefIndex = GetEntProp(g_iActiveWeapon[client], Prop_Send, "m_iItemDefinitionIndex");
				
				switch(iDefIndex)
				{
					case 7, 8, 10, 13, 14, 16, 17, 19, 23, 24, 25, 26, 27, 28, 29, 33, 34, 35, 39, 60:
					{
						float fTargetDistance = GetVectorDistance(g_fBotOrigin[client], fHead);
						if (IsItMyChance(80.0) && fTargetDistance < 2000.0)
							bShootSpine = true;
					}
					case 9, 11, 38:
					{
						bShootSpine = true;
					}
				}
			}
		}
		else
		{
			//Head wasn't visible, check other bones.
			for (int b = 0; b <= sizeof(g_szBoneNames) - 1; b++)
			{
				iBone = LookupBone(g_iTarget[client], g_szBoneNames[b]);
				if (iBone < 0)
					return;
				
				GetBonePosition(g_iTarget[client], iBone, fHead, fBad);
				
				if (BotIsVisible(client, fHead, false, -1))
					break;
				else
					fHead[2] = 0.0;
			}
		}
		
		if(bShootSpine)
			fTargetPos = fBody;
		else
			fTargetPos = fHead;
	}
}

stock void GetViewVector(float fVecAngle[3], float fOutPut[3])
{
	fOutPut[0] = Cosine(fVecAngle[1] / (180 / FLOAT_PI));
	fOutPut[1] = Sine(fVecAngle[1] / (180 / FLOAT_PI));
	fOutPut[2] = -Sine(fVecAngle[0] / (180 / FLOAT_PI));
}

stock float AngleNormalize(float fAngle)
{
	fAngle -= RoundToFloor(fAngle / 360.0) * 360.0;
	
	if (fAngle > 180)
		fAngle -= 360;
	
	if (fAngle < -180)
		fAngle += 360;

	return fAngle;
}

stock bool IsPointVisible(float fStart[3], float fEnd[3])
{
	TR_TraceRayFilter(fStart, fEnd, MASK_VISIBLE_AND_NPCS, RayType_EndPoint, TraceEntityFilterStuff);
	return TR_GetFraction() >= 0.9;
}

public bool TraceEntityFilterStuff(int iEntity, int iMask)
{
	return iEntity > MaxClients;
} 

public void ProcessGrenadeThrow(int client, float fTarget[3])
{
	NavMesh_GetGroundHeight(fTarget, fTarget[2]);
	if(!GetGrenadeToss(client, fTarget))
		return;
	
	Array_Copy(fTarget, g_fNadeTarget[client], 3);
	SDKCall(g_hSwitchWeaponCall, client, GetPlayerWeaponSlot(client, CS_SLOT_GRENADE), 0);
	RequestFrame(DelayThrow, GetClientUserId(client));
}

stock bool GetGrenadeToss(int client, float fTossTarget[3])
{
	float fEyePosition[3], fTo[3];
	GetClientEyePosition(client, fEyePosition);
	SubtractVectors(fTossTarget, fEyePosition, fTo);
	float fRange = GetVectorLength(fTo);

	const float fSlope = 0.2; // 0.25f;
	float fTossHeight = fSlope * fRange;

	float fHeightInc = fTossHeight / 10.0;
	float fTarget[3];
	float fSafeSpace = fTossHeight / 2.0;

	// Build a box to sweep along the ray when looking for obstacles
	float fMins[3] = { -16.0, -16.0, 0.0 };
	float fMaxs[3] = { 16.0, 16.0, 72.0 };
	fMins[2] = 0.0;
	fMaxs[2] = fHeightInc;


	// find low and high bounds of toss window
	float fLow = 0.0;
	float fHigh = fTossHeight + fSafeSpace;
	bool bGotLow = false;
	float fLastH = 0.0;
	for(float h = 0.0; h < 3.0 * fTossHeight; h += fHeightInc)
	{
		fTarget[0] = fTossTarget[0];
		fTarget[1] = fTossTarget[1];
		fTarget[2] = fTossTarget[2] + h;

		// make sure toss line is clear
		Handle hTraceResult = TR_TraceHullFilterEx(fEyePosition, fTarget, fMins, fMins, MASK_VISIBLE_AND_NPCS | CONTENTS_GRATE, TraceEntityFilterStuff);
		
		if (TR_GetFraction(hTraceResult) == 1.0)
		{
			// line is clear
			if (!bGotLow)
			{
				fLow = h;
				bGotLow = true;
			}
		}
		else
		{
			// line is blocked
			if (bGotLow)
			{
				fHigh = fLastH;
				break;
			}
		}

		fLastH = h;
		
		delete hTraceResult;
	}

	if (bGotLow)
	{
		// throw grenade into toss window
		if (fTossHeight < fLow)
		{
			if (fLow + fSafeSpace > fHigh)
				// narrow window
				fTossHeight = (fHigh + fLow)/2.0;
			else
				fTossHeight = fLow + fSafeSpace;
		}
		else if (fTossHeight > fHigh - fSafeSpace)
		{
			if (fHigh - fSafeSpace < fLow)
				// narrow window
				fTossHeight = (fHigh + fLow)/2.0;
			else
				fTossHeight = fHigh - fSafeSpace;
		}
		
		fTossTarget[2] += fTossHeight;
		return true;
	}
	
	return false;
}

stock bool LineGoesThroughSmoke(float fFrom[3], float fTo[3])
{	
	return SDKCall(g_hIsLineBlockedBySmoke, g_pTheBots, fFrom, fTo);
} 

stock int GetAliveTeamCount(int iTeam)
{
	int iNumber = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == iTeam)
			iNumber++;
	}
	return iNumber;
}

stock bool IsSafe(int client)
{
	if(!IsFakeClient(client))
		return false;
	
	if((GetGameTime() - g_fFreezeTimeEnd) < GetEntDataFloat(client, g_iBotSafeTimeOffset))
		return true;
	
	return false;
}

stock int GetFriendsWithPrimary(int client)
{
	int iCount = 0;
	int iPrimary;
	for (int i = 1; i <= MaxClients; i++) 
	{
		if(!IsValidClient(i)) 
			continue;	
			
		if(client == i)
			continue;

		if(GetClientTeam(i) != GetClientTeam(client))
			continue;

		iPrimary = GetPlayerWeaponSlot(i, CS_SLOT_PRIMARY);
		if(IsValidEntity(iPrimary))
			iCount++;
	}

	return iCount;
}

stock TaskType GetTask(int client)
{
	if(!IsFakeClient(client))
		return view_as<TaskType>(-1);
		
	return view_as<TaskType>(GetEntData(client, g_iBotTaskOffset));
}

stock DispositionType GetDisposition(int client)
{
	if(!IsFakeClient(client))
		return view_as<DispositionType>(-1);
		
	return view_as<DispositionType>(GetEntData(client, g_iBotDispositionOffset));
}

stock void SetDisposition(int client, DispositionType iDisposition)
{
	if(!IsFakeClient(client))
		return;
		
	SetEntData(client, g_iBotDispositionOffset, iDisposition);
}

stock void SetPlayerTeammateColor(int client)
{
	if(GetClientTeam(client) > CS_TEAM_SPECTATOR)
	{
		if(g_iPlayerColor[client] > -1)
			return;
		
		int nAssignedColor;
		bool bColorInUse = false;
		for (int ii = 0; ii < 5; ii++ )
		{
			nAssignedColor = nAssignedColor % 5;

			bColorInUse = false;
			for ( int j = 1; j <= MaxClients; j++ )
			{
				if (IsValidClient(j) && GetClientTeam(j) == GetClientTeam(client))
				{
					if (nAssignedColor == g_iPlayerColor[j] && j != client)
					{
						bColorInUse = true;
						nAssignedColor++;
						break;
					}
				}
			}

			if (bColorInUse == false )
				break;
		}
		nAssignedColor = bColorInUse == false ? nAssignedColor : -1;
		g_iPlayerColor[client] = nAssignedColor;
	}
}

public void AutoStop(int client, float fVel[3], float fAngles[3])
{
	float fPlayerVelocity[3], fVelAngle[3];
	GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", fPlayerVelocity);
	GetVectorAngles(fPlayerVelocity, fVelAngle);
	float fSpeed = GetVectorLength(fPlayerVelocity);
	
	if(fSpeed < 1.0)
		return;
	
	fVelAngle[1] = fAngles[1] - fVelAngle[1];
	
	float fNegatedDirection[3], fForwardDirection[3];
	GetAngleVectors(fVelAngle, fForwardDirection, NULL_VECTOR, NULL_VECTOR);
	
	fNegatedDirection[0] = fForwardDirection[0] * (-fSpeed);
	fNegatedDirection[1] = fForwardDirection[1] * (-fSpeed);
	fNegatedDirection[2] = fForwardDirection[2] * (-fSpeed);
	
	fVel[0] = fNegatedDirection[0];
	fVel[1] = fNegatedDirection[1];
}

stock bool ShouldForce()
{
	int iOvertimePlaying = GameRules_GetProp("m_nOvertimePlaying");
	GamePhase pGamePhase = view_as<GamePhase>(GameRules_GetProp("m_gamePhase"));

	if (FindConVar("mp_halftime").BoolValue)
	{
		int iRoundsBeforeHalftime = -1;
		if (pGamePhase == GAMEPHASE_PLAYING_FIRST_HALF)
			iRoundsBeforeHalftime = iOvertimePlaying ? ( FindConVar("mp_maxrounds").IntValue + ( 2 * iOvertimePlaying - 1 ) * ( FindConVar("mp_overtime_maxrounds").IntValue / 2 ) ) : ( FindConVar("mp_maxrounds").IntValue / 2 );

		if ((iRoundsBeforeHalftime > 0) && (g_iRoundsPlayed == (iRoundsBeforeHalftime-1)))
		{
			g_bHalftimeSwitch = true;
			return true;
		}
	}
	
	int iNumWinsToClinch = GetNumWinsToClinch();
	bool bMatchPoint = false;
	if (pGamePhase != GAMEPHASE_PLAYING_FIRST_HALF)
		bMatchPoint = (g_iCTScore == iNumWinsToClinch-1 || g_iTScore == iNumWinsToClinch-1);
	if(bMatchPoint)
		return true;
	
	bool bLastRound = FindConVar("mp_maxrounds").IntValue > 0 ? (g_iCurrentRound == (FindConVar("mp_maxrounds").IntValue-1 + iOvertimePlaying * FindConVar("mp_overtime_maxrounds").IntValue)) : false;
	if(bLastRound)
		return true;
		
	return false;
}

stock int GetNumWinsToClinch()
{
	int iOvertimePlaying = GameRules_GetProp("m_nOvertimePlaying");
	int iNumWinsToClinch = (FindConVar("mp_maxrounds").IntValue > 0 && FindConVar("mp_match_can_clinch").BoolValue) ? (FindConVar("mp_maxrounds").IntValue / 2 ) + 1 + iOvertimePlaying * (FindConVar("mp_overtime_maxrounds").IntValue / 2) : -1;
	return iNumWinsToClinch;
}

stock bool IsItMyChance(float fChance = 0.0)
{
	float flRand = Math_GetRandomFloat(0.0, 100.0);
	if( fChance <= 0.0 )
		return false;
	return flRand <= fChance;
}

stock bool IsValidClient(int client)
{
	return client > 0 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && !IsClientSourceTV(client);
}