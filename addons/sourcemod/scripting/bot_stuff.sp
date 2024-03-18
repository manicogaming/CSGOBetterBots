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

char g_szMap[128];
char g_szCrosshairCode[MAXPLAYERS+1][35], g_szPreviousBuy[MAXPLAYERS+1][128];
bool g_bIsBombScenario, g_bIsHostageScenario, g_bFreezetimeEnd, g_bBombPlanted, g_bEveryoneDead, g_bHalftimeSwitch, g_bIsCompetitive;
bool g_bUseCZ75[MAXPLAYERS+1], g_bUseUSP[MAXPLAYERS+1], g_bUseM4A1S[MAXPLAYERS+1], g_bDontSwitch[MAXPLAYERS+1], g_bDropWeapon[MAXPLAYERS+1], g_bHasGottenDrop[MAXPLAYERS+1];
bool g_bIsProBot[MAXPLAYERS+1], g_bThrowGrenade[MAXPLAYERS+1], g_bUncrouch[MAXPLAYERS+1], g_bCanThrowGrenade[MAXPLAYERS+1];
int g_iProfileRank[MAXPLAYERS+1], g_iPlayerColor[MAXPLAYERS+1], g_iTarget[MAXPLAYERS+1], g_iPrevTarget[MAXPLAYERS+1], g_iDoingSmokeNum[MAXPLAYERS+1], g_iActiveWeapon[MAXPLAYERS+1];
int g_iCurrentRound, g_iRoundsPlayed, g_iCTScore, g_iTScore, g_iMaxNades;
int g_iProfileRankOffset, g_iPlayerColorOffset;
int g_iBotTargetSpotOffset, g_iBotNearbyEnemiesOffset, g_iFireWeaponOffset, g_iEnemyVisibleOffset, g_iBotProfileOffset, g_iBotSafeTimeOffset, g_iBotEnemyOffset, g_iBotLookAtSpotStateOffset, g_iBotMoraleOffset, g_iBotTaskOffset;
float g_fBotOrigin[MAXPLAYERS+1][3], g_fTargetPos[MAXPLAYERS+1][3], g_fNadeTarget[MAXPLAYERS+1][3], g_fWeaponPos[MAXPLAYERS+1][3];
float g_fRoundStart, g_fFreezeTimeEnd;
float g_fLookAngleMaxAccel[MAXPLAYERS+1], g_fReactionTime[MAXPLAYERS+1], g_fAggression[MAXPLAYERS+1], g_fShootTimestamp[MAXPLAYERS+1], g_fThrowNadeTimestamp[MAXPLAYERS+1], g_fSearchGunTimestamp[MAXPLAYERS+1], g_fCrouchTimestamp[MAXPLAYERS+1];
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
Handle g_hBotAttack;
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
	name = "BOT Stuff", 
	author = "manico", 
	description = "Improves bots and does other things.", 
	version = "1.0", 
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
			ServerCommand("bot_add_ct %s", "es3tag");
			ServerCommand("bot_add_ct %s", "REZ");
			ServerCommand("bot_add_ct %s", "k0nfig");
			ServerCommand("bot_add_ct %s", "ALEX");
			ServerCommand("bot_add_ct %s", "headtr1ck");
			ServerCommand("mp_teamlogo_1 nip");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "es3tag");
			ServerCommand("bot_add_t %s", "REZ");
			ServerCommand("bot_add_t %s", "k0nfig");
			ServerCommand("bot_add_t %s", "ALEX");
			ServerCommand("bot_add_t %s", "headtr1ck");
			ServerCommand("mp_teamlogo_2 nip");
		}
	}
	
	if(strcmp(szTeamArg, "MIBR", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "brnz4n");
			ServerCommand("bot_add_ct %s", "saffee");
			ServerCommand("bot_add_ct %s", "drop");
			ServerCommand("bot_add_ct %s", "insani");
			ServerCommand("bot_add_ct %s", "exit");
			ServerCommand("mp_teamlogo_1 mibr");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "brnz4n");
			ServerCommand("bot_add_t %s", "saffee");
			ServerCommand("bot_add_t %s", "drop");
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
			ServerCommand("bot_add_ct %s", "ropz");
			ServerCommand("mp_teamlogo_1 faze");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "frozen");
			ServerCommand("bot_add_t %s", "broky");
			ServerCommand("bot_add_t %s", "karrigan");
			ServerCommand("bot_add_t %s", "rain");
			ServerCommand("bot_add_t %s", "ropz");
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
			ServerCommand("bot_add_ct %s", "br0");
			ServerCommand("mp_teamlogo_1 astr");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "stavn");
			ServerCommand("bot_add_t %s", "dev1ce");
			ServerCommand("bot_add_t %s", "Staehr");
			ServerCommand("bot_add_t %s", "jabbi");
			ServerCommand("bot_add_t %s", "br0");
			ServerCommand("mp_teamlogo_2 astr");
		}
	}
	
	if(strcmp(szTeamArg, "MASONIC", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Froslev");
			ServerCommand("bot_add_ct %s", "Zanto");
			ServerCommand("bot_add_ct %s", "Falk");
			ServerCommand("bot_add_ct %s", "Noruyp");
			ServerCommand("bot_add_ct %s", "Ch4se");
			ServerCommand("mp_teamlogo_1 maso");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Froslev");
			ServerCommand("bot_add_t %s", "Zanto");
			ServerCommand("bot_add_t %s", "Falk");
			ServerCommand("bot_add_t %s", "Noruyp");
			ServerCommand("bot_add_t %s", "Ch4se");
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
			ServerCommand("bot_add_ct %s", "HooXi");
			ServerCommand("bot_add_ct %s", "nexa");
			ServerCommand("bot_add_ct %s", "NiKo");
			ServerCommand("mp_teamlogo_1 g2");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "huNter-");
			ServerCommand("bot_add_t %s", "m0NESY");
			ServerCommand("bot_add_t %s", "HooXi");
			ServerCommand("bot_add_t %s", "nexa");
			ServerCommand("bot_add_t %s", "NiKo");
			ServerCommand("mp_teamlogo_2 g2");
		}
	}
	
	if(strcmp(szTeamArg, "fnatic", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "matys");
			ServerCommand("bot_add_ct %s", "afro");
			ServerCommand("bot_add_ct %s", "KRIMZ");
			ServerCommand("bot_add_ct %s", "bodyy");
			ServerCommand("bot_add_ct %s", "kyuubii");
			ServerCommand("mp_teamlogo_1 fntc");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "matys");
			ServerCommand("bot_add_t %s", "afro");
			ServerCommand("bot_add_t %s", "KRIMZ");
			ServerCommand("bot_add_t %s", "bodyy");
			ServerCommand("bot_add_t %s", "kyuubii");
			ServerCommand("mp_teamlogo_2 fntc");
		}
	}
	
	if(strcmp(szTeamArg, "Dynamo", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Blytz");
			ServerCommand("bot_add_ct %s", "forsyy");
			ServerCommand("bot_add_ct %s", "Dytor");
			ServerCommand("bot_add_ct %s", "kreaz");
			ServerCommand("bot_add_ct %s", "nbqq");
			ServerCommand("mp_teamlogo_1 dyna");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Blytz");
			ServerCommand("bot_add_t %s", "forsyy");
			ServerCommand("bot_add_t %s", "Dytor");
			ServerCommand("bot_add_t %s", "kreaz");
			ServerCommand("bot_add_t %s", "nbqq");
			ServerCommand("mp_teamlogo_2 dyna");
		}
	}
	
	if(strcmp(szTeamArg, "mouz", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "siuhy");
			ServerCommand("bot_add_ct %s", "torzsi");
			ServerCommand("bot_add_ct %s", "xertioN");
			ServerCommand("bot_add_ct %s", "Brollan");
			ServerCommand("bot_add_ct %s", "Jimpphat");
			ServerCommand("mp_teamlogo_1 mouz");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "siuhy");
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
			ServerCommand("bot_add_ct %s", "kaze");
			ServerCommand("mp_teamlogo_1 tyl");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "advent");
			ServerCommand("bot_add_t %s", "Mercury");
			ServerCommand("bot_add_t %s", "JamYoung");
			ServerCommand("bot_add_t %s", "Moseyuh");
			ServerCommand("bot_add_t %s", "kaze");
			ServerCommand("mp_teamlogo_2 tyl");
		}
	}
	
	if(strcmp(szTeamArg, "Secret", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "innocent");
			ServerCommand("bot_add_ct %s", "anarkez");
			ServerCommand("bot_add_ct %s", "Maze");
			ServerCommand("bot_add_ct %s", "Kind0");
			ServerCommand("bot_add_ct %s", "Tauson");
			ServerCommand("mp_teamlogo_1 sec");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "innocent");
			ServerCommand("bot_add_t %s", "anarkez");
			ServerCommand("bot_add_t %s", "Maze");
			ServerCommand("bot_add_t %s", "Kind0");
			ServerCommand("bot_add_t %s", "Tauson");
			ServerCommand("mp_teamlogo_2 sec");
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
			ServerCommand("bot_add_ct %s", "YEKINDAR");
			ServerCommand("bot_add_ct %s", "cadiaN");
			ServerCommand("bot_add_ct %s", "Twistzz");
			ServerCommand("bot_add_ct %s", "skullz");
			ServerCommand("bot_add_ct %s", "NAF");
			ServerCommand("mp_teamlogo_1 liq");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "YEKINDAR");
			ServerCommand("bot_add_t %s", "cadiaN");
			ServerCommand("bot_add_t %s", "Twistzz");
			ServerCommand("bot_add_t %s", "skullz");
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
			ServerCommand("bot_add_ct %s", "hades");
			ServerCommand("bot_add_ct %s", "Goofy");
			ServerCommand("bot_add_ct %s", "Kylar");
			ServerCommand("bot_add_ct %s", "dycha");
			ServerCommand("mp_teamlogo_1 ence");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "gla1ve");
			ServerCommand("bot_add_t %s", "hades");
			ServerCommand("bot_add_t %s", "Goofy");
			ServerCommand("bot_add_t %s", "Kylar");
			ServerCommand("bot_add_t %s", "dycha");
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
			ServerCommand("bot_add_ct %s", "Spinx");
			ServerCommand("mp_teamlogo_1 vita");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "flameZ");
			ServerCommand("bot_add_t %s", "ZywOo");
			ServerCommand("bot_add_t %s", "apEX");
			ServerCommand("bot_add_t %s", "mezii");
			ServerCommand("bot_add_t %s", "Spinx");
			ServerCommand("mp_teamlogo_2 vita");
		}
	}
	
	if(strcmp(szTeamArg, "BIG", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "prosus");
			ServerCommand("bot_add_ct %s", "syrsoN");
			ServerCommand("bot_add_ct %s", "JDC");
			ServerCommand("bot_add_ct %s", "tabseN");
			ServerCommand("bot_add_ct %s", "Krimbo");
			ServerCommand("mp_teamlogo_1 big");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "prosus");
			ServerCommand("bot_add_t %s", "syrsoN");
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
			ServerCommand("bot_add_ct %s", "arT");
			ServerCommand("mp_teamlogo_1 furi");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "yuurih");
			ServerCommand("bot_add_t %s", "FalleN");
			ServerCommand("bot_add_t %s", "chelo");
			ServerCommand("bot_add_t %s", "KSCERATO");
			ServerCommand("bot_add_t %s", "arT");
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
			ServerCommand("bot_add_ct %s", "EliGE");
			ServerCommand("bot_add_ct %s", "floppy");
			ServerCommand("bot_add_ct %s", "Grim");
			ServerCommand("mp_teamlogo_1 col");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "JT");
			ServerCommand("bot_add_t %s", "hallzerk");
			ServerCommand("bot_add_t %s", "EliGE");
			ServerCommand("bot_add_t %s", "floppy");
			ServerCommand("bot_add_t %s", "Grim");
			ServerCommand("mp_teamlogo_2 col");
		}
	}
	
	if(strcmp(szTeamArg, "forZe", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "r3salt");
			ServerCommand("bot_add_ct %s", "gokushima");
			ServerCommand("bot_add_ct %s", "sstiNiX");
			ServerCommand("bot_add_ct %s", "shalfey");
			ServerCommand("bot_add_ct %s", "tN1R");
			ServerCommand("mp_teamlogo_1 forz");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "r3salt");
			ServerCommand("bot_add_t %s", "gokushima");
			ServerCommand("bot_add_t %s", "sstiNiX");
			ServerCommand("bot_add_t %s", "shalfey");
			ServerCommand("bot_add_t %s", "tN1R");
			ServerCommand("mp_teamlogo_2 forz");
		}
	}
	
	if(strcmp(szTeamArg, "Sprout", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "reiko");
			ServerCommand("bot_add_ct %s", "cej0t");
			ServerCommand("bot_add_ct %s", "Sdaim");
			ServerCommand("bot_add_ct %s", "raalz");
			ServerCommand("bot_add_ct %s", "podi");
			ServerCommand("mp_teamlogo_1 spr");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "reiko");
			ServerCommand("bot_add_t %s", "cej0t");
			ServerCommand("bot_add_t %s", "Sdaim");
			ServerCommand("bot_add_t %s", "raalz");
			ServerCommand("bot_add_t %s", "podi");
			ServerCommand("mp_teamlogo_2 spr");
		}
	}
	
	if(strcmp(szTeamArg, "Heroic", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "TeSeS");
			ServerCommand("bot_add_ct %s", "NertZ");
			ServerCommand("bot_add_ct %s", "sjuush");
			ServerCommand("bot_add_ct %s", "nicoodoz");
			ServerCommand("bot_add_ct %s", "kyxsan");
			ServerCommand("mp_teamlogo_1 heroi");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "TeSeS");
			ServerCommand("bot_add_t %s", "NertZ");
			ServerCommand("bot_add_t %s", "sjuush");
			ServerCommand("bot_add_t %s", "nicoodoz");
			ServerCommand("bot_add_t %s", "kyxsan");
			ServerCommand("mp_teamlogo_2 heroi");
		}
	}
	
	if(strcmp(szTeamArg, "VP", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "n0rb3r7");
			ServerCommand("bot_add_ct %s", "Jame");
			ServerCommand("bot_add_ct %s", "mir");
			ServerCommand("bot_add_ct %s", "FL1T");
			ServerCommand("bot_add_ct %s", "fame");
			ServerCommand("mp_teamlogo_1 vp");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "n0rb3r7");
			ServerCommand("bot_add_t %s", "Jame");
			ServerCommand("bot_add_t %s", "mir");
			ServerCommand("bot_add_t %s", "FL1T");
			ServerCommand("bot_add_t %s", "fame");
			ServerCommand("mp_teamlogo_2 vp");
		}
	}
	
	if(strcmp(szTeamArg, "Apeks", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "jkaem");
			ServerCommand("bot_add_ct %s", "nawwk");
			ServerCommand("bot_add_ct %s", "STYKO");
			ServerCommand("bot_add_ct %s", "sense");
			ServerCommand("bot_add_ct %s", "CacaNito");
			ServerCommand("mp_teamlogo_1 apex");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "jkaem");
			ServerCommand("bot_add_t %s", "nawwk");
			ServerCommand("bot_add_t %s", "STYKO");
			ServerCommand("bot_add_t %s", "sense");
			ServerCommand("bot_add_t %s", "CacaNito");
			ServerCommand("mp_teamlogo_2 apex");
		}
	}
	
	if(strcmp(szTeamArg, "HAVU", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Banjo");
			ServerCommand("bot_add_ct %s", "ottoNd");
			ServerCommand("bot_add_ct %s", "uli");
			ServerCommand("bot_add_ct %s", "puuha");
			ServerCommand("bot_add_ct %s", "airax");
			ServerCommand("mp_teamlogo_1 havu");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Banjo");
			ServerCommand("bot_add_t %s", "ottoNd");
			ServerCommand("bot_add_t %s", "uli");
			ServerCommand("bot_add_t %s", "puuha");
			ServerCommand("bot_add_t %s", "airax");
			ServerCommand("mp_teamlogo_2 havu");
		}
	}
	
	if(strcmp(szTeamArg, "ECSTATIC", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "kraghen");
			ServerCommand("bot_add_ct %s", "Queenix");
			ServerCommand("bot_add_ct %s", "Patti");
			ServerCommand("bot_add_ct %s", "Nodios");
			ServerCommand("bot_add_ct %s", "salazar");
			ServerCommand("mp_teamlogo_1 ecs");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "kraghen");
			ServerCommand("bot_add_t %s", "Queenix");
			ServerCommand("bot_add_t %s", "Patti");
			ServerCommand("bot_add_t %s", "Nodios");
			ServerCommand("bot_add_t %s", "salazar");
			ServerCommand("mp_teamlogo_2 ecs");
		}
	}
	
	if(strcmp(szTeamArg, "KOI", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "mopoz");
			ServerCommand("bot_add_ct %s", "stadodo");
			ServerCommand("bot_add_ct %s", "JUST");
			ServerCommand("bot_add_ct %s", "adamS");
			ServerCommand("bot_add_ct %s", "dav1g");
			ServerCommand("mp_teamlogo_1 koi");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "mopoz");
			ServerCommand("bot_add_t %s", "stadodo");
			ServerCommand("bot_add_t %s", "JUST");
			ServerCommand("bot_add_t %s", "adamS");
			ServerCommand("bot_add_t %s", "dav1g");
			ServerCommand("mp_teamlogo_2 koi");
		}
	}
	
	if(strcmp(szTeamArg, "AVEZ", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "AntyVirus");
			ServerCommand("bot_add_ct %s", "Yamii");
			ServerCommand("bot_add_ct %s", "przemeklovel");
			ServerCommand("bot_add_ct %s", "SpavaQ");
			ServerCommand("bot_add_ct %s", "smooho");
			ServerCommand("mp_teamlogo_1 avez");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "AntyVirus");
			ServerCommand("bot_add_t %s", "Yamii");
			ServerCommand("bot_add_t %s", "przemeklovel");
			ServerCommand("bot_add_t %s", "SpavaQ");
			ServerCommand("bot_add_t %s", "smooho");
			ServerCommand("mp_teamlogo_2 avez");
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
			ServerCommand("bot_add_ct %s", "ERSIN");
			ServerCommand("mp_teamlogo_1 nex");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "BTN");
			ServerCommand("bot_add_t %s", "XELLOW");
			ServerCommand("bot_add_t %s", "ragga");
			ServerCommand("bot_add_t %s", "s0und");
			ServerCommand("bot_add_t %s", "ERSIN");
			ServerCommand("mp_teamlogo_2 nex");
		}
	}
	
	if(strcmp(szTeamArg, "Genk", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "CrePoW");
			ServerCommand("bot_add_ct %s", "yOOm");
			ServerCommand("bot_add_ct %s", "JuN1");
			ServerCommand("bot_add_ct %s", "Wumbo");
			ServerCommand("bot_add_ct %s", "AyeZ");
			ServerCommand("mp_teamlogo_1 genk");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "CrePoW");
			ServerCommand("bot_add_t %s", "yOOm");
			ServerCommand("bot_add_t %s", "JuN1");
			ServerCommand("bot_add_t %s", "Wumbo");
			ServerCommand("bot_add_t %s", "AyeZ");
			ServerCommand("mp_teamlogo_2 genk");
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
			ServerCommand("bot_add_ct %s", "awzek");
			ServerCommand("bot_add_ct %s", "hyped");
			ServerCommand("bot_add_ct %s", "FreeZe");
			ServerCommand("bot_add_ct %s", "skyye");
			ServerCommand("bot_add_ct %s", "ArroW");
			ServerCommand("mp_teamlogo_1 attax");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "awzek");
			ServerCommand("bot_add_t %s", "hyped");
			ServerCommand("bot_add_t %s", "FreeZe");
			ServerCommand("bot_add_t %s", "skyye");
			ServerCommand("bot_add_t %s", "ArroW");
			ServerCommand("mp_teamlogo_2 attax");
		}
	}
	
	if(strcmp(szTeamArg, "NewHappy", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "SPine");
			ServerCommand("bot_add_ct %s", "TiGeR");
			ServerCommand("bot_add_ct %s", "L1haNg");
			ServerCommand("bot_add_ct %s", "tutu");
			ServerCommand("bot_add_ct %s", "2X2X");
			ServerCommand("mp_teamlogo_1 happy");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "SPine");
			ServerCommand("bot_add_t %s", "TiGeR");
			ServerCommand("bot_add_t %s", "L1haNg");
			ServerCommand("bot_add_t %s", "tutu");
			ServerCommand("bot_add_t %s", "2X2X");
			ServerCommand("mp_teamlogo_2 happy");
		}
	}
	
	if(strcmp(szTeamArg, "paiN", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "nqz");
			ServerCommand("bot_add_ct %s", "lux");
			ServerCommand("bot_add_ct %s", "n1ssim");
			ServerCommand("bot_add_ct %s", "biguzera");
			ServerCommand("bot_add_ct %s", "kauez");
			ServerCommand("mp_teamlogo_1 pain");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "nqz");
			ServerCommand("bot_add_t %s", "lux");
			ServerCommand("bot_add_t %s", "n1ssim");
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
			ServerCommand("bot_add_ct %s", "drg");
			ServerCommand("bot_add_ct %s", "rdnzao");
			ServerCommand("bot_add_ct %s", "supLexN1");
			ServerCommand("bot_add_ct %s", "togs");
			ServerCommand("mp_teamlogo_1 shrk");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "doczin");
			ServerCommand("bot_add_t %s", "drg");
			ServerCommand("bot_add_t %s", "rdnzao");
			ServerCommand("bot_add_t %s", "supLexN1");
			ServerCommand("bot_add_t %s", "togs");
			ServerCommand("mp_teamlogo_2 shrk");
		}
	}
	
	if(strcmp(szTeamArg, "9ine", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "tomiko");
			ServerCommand("bot_add_ct %s", "mhL");
			ServerCommand("bot_add_ct %s", "KEi");
			ServerCommand("bot_add_ct %s", "KukuBambo");
			ServerCommand("bot_add_ct %s", "mynio");
			ServerCommand("mp_teamlogo_1 nein");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "tomiko");
			ServerCommand("bot_add_t %s", "mhL");
			ServerCommand("bot_add_t %s", "KEi");
			ServerCommand("bot_add_t %s", "KukuBambo");
			ServerCommand("bot_add_t %s", "mynio");
			ServerCommand("mp_teamlogo_2 nein");
		}
	}
	
	if(strcmp(szTeamArg, "GamerLegion", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "volt");
			ServerCommand("bot_add_ct %s", "acoR");
			ServerCommand("bot_add_ct %s", "isak");
			ServerCommand("bot_add_ct %s", "Snax");
			ServerCommand("bot_add_ct %s", "Keoz");
			ServerCommand("mp_teamlogo_1 gl");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "volt");
			ServerCommand("bot_add_t %s", "acoR");
			ServerCommand("bot_add_t %s", "isak");
			ServerCommand("bot_add_t %s", "Snax");
			ServerCommand("bot_add_t %s", "Keoz");
			ServerCommand("mp_teamlogo_2 gl");
		}
	}
	
	if(strcmp(szTeamArg, "Strife", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "J0LZ");
			ServerCommand("bot_add_ct %s", "YuZ");
			ServerCommand("bot_add_ct %s", "Melio");
			ServerCommand("bot_add_ct %s", "1FAME");
			ServerCommand("bot_add_ct %s", "tENSKI");
			ServerCommand("mp_teamlogo_1 strif");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "J0LZ");
			ServerCommand("bot_add_t %s", "YuZ");
			ServerCommand("bot_add_t %s", "Melio");
			ServerCommand("bot_add_t %s", "1FAME");
			ServerCommand("bot_add_t %s", "tENSKI");
			ServerCommand("mp_teamlogo_2 strif");
		}
	}
	
	if(strcmp(szTeamArg, "w7m", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "saadzin");
			ServerCommand("bot_add_ct %s", "jz");
			ServerCommand("bot_add_ct %s", "stormzyn");
			ServerCommand("bot_add_ct %s", "zdr");
			ServerCommand("bot_add_ct %s", "fokiu");
			ServerCommand("mp_teamlogo_1 w7m");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "saadzin");
			ServerCommand("bot_add_t %s", "jz");
			ServerCommand("bot_add_t %s", "stormzyn");
			ServerCommand("bot_add_t %s", "zdr");
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
			ServerCommand("bot_add_ct %s", "SloWye");
			ServerCommand("bot_add_ct %s", "Triton");
			ServerCommand("bot_add_ct %s", "March");
			ServerCommand("bot_add_ct %s", "wilj");
			ServerCommand("mp_teamlogo_1 bravg");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Doru");
			ServerCommand("bot_add_t %s", "SloWye");
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
			ServerCommand("bot_add_ct %s", "Calyx");
			ServerCommand("bot_add_ct %s", "MAJ3R");
			ServerCommand("bot_add_ct %s", "woxic");
			ServerCommand("bot_add_ct %s", "Wicadia");
			ServerCommand("mp_teamlogo_1 eter");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "XANTARES");
			ServerCommand("bot_add_t %s", "Calyx");
			ServerCommand("bot_add_t %s", "MAJ3R");
			ServerCommand("bot_add_t %s", "woxic");
			ServerCommand("bot_add_t %s", "Wicadia");
			ServerCommand("mp_teamlogo_2 eter");
		}
	}
	
	if(strcmp(szTeamArg, "BRUTE", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "heikkoL");
			ServerCommand("bot_add_ct %s", "w4rden");
			ServerCommand("bot_add_ct %s", "SiKO");
			ServerCommand("bot_add_ct %s", "realzen");
			ServerCommand("bot_add_ct %s", "m0nsterr");
			ServerCommand("mp_teamlogo_1 brut");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "heikkoL");
			ServerCommand("bot_add_t %s", "w4rden");
			ServerCommand("bot_add_t %s", "SiKO");
			ServerCommand("bot_add_t %s", "realzen");
			ServerCommand("bot_add_t %s", "m0nsterr");
			ServerCommand("mp_teamlogo_2 brut");
		}
	}
	
	if(strcmp(szTeamArg, "C9", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "electroNic");
			ServerCommand("bot_add_ct %s", "Boombl4");
			ServerCommand("bot_add_ct %s", "Perfecto");
			ServerCommand("bot_add_ct %s", "Ax1Le");
			ServerCommand("bot_add_ct %s", "Hobbit");
			ServerCommand("mp_teamlogo_1 c9");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "electroNic");
			ServerCommand("bot_add_t %s", "Boombl4");
			ServerCommand("bot_add_t %s", "Perfecto");
			ServerCommand("bot_add_t %s", "Ax1Le");
			ServerCommand("bot_add_t %s", "Hobbit");
			ServerCommand("mp_teamlogo_2 c9");
		}
	}
	
	if(strcmp(szTeamArg, "Raptors", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "ifan");
			ServerCommand("bot_add_ct %s", "eMy");
			ServerCommand("bot_add_ct %s", "Rhys");
			ServerCommand("bot_add_ct %s", "Ziimzey");
			ServerCommand("bot_add_ct %s", "Yoshwa");
			ServerCommand("mp_teamlogo_1 rap");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "ifan");
			ServerCommand("bot_add_t %s", "eMy");
			ServerCommand("bot_add_t %s", "Rhys");
			ServerCommand("bot_add_t %s", "Ziimzey");
			ServerCommand("bot_add_t %s", "Yoshwa");
			ServerCommand("mp_teamlogo_2 rap");
		}
	}
	
	if(strcmp(szTeamArg, "Nemiga", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "1eeR");
			ServerCommand("bot_add_ct %s", "khaN");
			ServerCommand("bot_add_ct %s", "FL4MUS");
			ServerCommand("bot_add_ct %s", "riskyb0b");
			ServerCommand("bot_add_ct %s", "Xant3r");
			ServerCommand("mp_teamlogo_1 nem");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "1eeR");
			ServerCommand("bot_add_t %s", "khaN");
			ServerCommand("bot_add_t %s", "FL4MUS");
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
			ServerCommand("bot_add_ct %s", "Jee");
			ServerCommand("mp_teamlogo_1 lynn");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "westmelon");
			ServerCommand("bot_add_t %s", "z4kr");
			ServerCommand("bot_add_t %s", "Starry");
			ServerCommand("bot_add_t %s", "Emilia");
			ServerCommand("bot_add_t %s", "Jee");
			ServerCommand("mp_teamlogo_2 lynn");
		}
	}
	
	if(strcmp(szTeamArg, "Rhyno", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "renatoohaxx");
			ServerCommand("bot_add_ct %s", "krazy");
			ServerCommand("bot_add_ct %s", "DDias");
			ServerCommand("bot_add_ct %s", "snapy");
			ServerCommand("bot_add_ct %s", "TMKj");
			ServerCommand("mp_teamlogo_1 rhy");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "renatoohaxx");
			ServerCommand("bot_add_t %s", "krazy");
			ServerCommand("bot_add_t %s", "DDias");
			ServerCommand("bot_add_t %s", "snapy");
			ServerCommand("bot_add_t %s", "TMKj");
			ServerCommand("mp_teamlogo_2 rhy");
		}
	}
	
	if(strcmp(szTeamArg, "OG", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Nexius");
			ServerCommand("bot_add_ct %s", "regali");
			ServerCommand("bot_add_ct %s", "k1to");
			ServerCommand("bot_add_ct %s", "F1KU");
			ServerCommand("bot_add_ct %s", "HeavyGod");
			ServerCommand("mp_teamlogo_1 og");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Nexius");
			ServerCommand("bot_add_t %s", "regali");
			ServerCommand("bot_add_t %s", "k1to");
			ServerCommand("bot_add_t %s", "F1KU");
			ServerCommand("bot_add_t %s", "HeavyGod");
			ServerCommand("mp_teamlogo_2 og");
		}
	}
	
	if(strcmp(szTeamArg, "Guild", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "juanflatroo");
			ServerCommand("bot_add_ct %s", "SENER1");
			ServerCommand("bot_add_ct %s", "sinnopsyy");
			ServerCommand("bot_add_ct %s", "gxx-");
			ServerCommand("bot_add_ct %s", "rigoN");
			ServerCommand("mp_teamlogo_1 gui");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "juanflatroo");
			ServerCommand("bot_add_t %s", "SENER1");
			ServerCommand("bot_add_t %s", "sinnopsyy");
			ServerCommand("bot_add_t %s", "gxx-");
			ServerCommand("bot_add_t %s", "rigoN");
			ServerCommand("mp_teamlogo_2 gui");
		}
	}
	
	if(strcmp(szTeamArg, "Endpoint", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Surreal");
			ServerCommand("bot_add_ct %s", "sl3nd");
			ServerCommand("bot_add_ct %s", "MiGHTYMAX");
			ServerCommand("bot_add_ct %s", "swicher");
			ServerCommand("bot_add_ct %s", "AZUWU");
			ServerCommand("mp_teamlogo_1 endp");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Surreal");
			ServerCommand("bot_add_t %s", "sl3nd");
			ServerCommand("bot_add_t %s", "MiGHTYMAX");
			ServerCommand("bot_add_t %s", "swicher");
			ServerCommand("bot_add_t %s", "AZUWU");
			ServerCommand("mp_teamlogo_2 endp");
		}
	}
	
	if(strcmp(szTeamArg, "sAw", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "ewjerkz");
			ServerCommand("bot_add_ct %s", "story");
			ServerCommand("bot_add_ct %s", "arrozdoce");
			ServerCommand("bot_add_ct %s", "MUTiRiS");
			ServerCommand("bot_add_ct %s", "rmn");
			ServerCommand("mp_teamlogo_1 saw");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "ewjerkz");
			ServerCommand("bot_add_t %s", "story");
			ServerCommand("bot_add_t %s", "arrozdoce");
			ServerCommand("bot_add_t %s", "MUTiRiS");
			ServerCommand("bot_add_t %s", "rmn");
			ServerCommand("mp_teamlogo_2 saw");
		}
	}
	
	if(strcmp(szTeamArg, "Alliance", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "PlesseN");
			ServerCommand("bot_add_ct %s", "b0denmaster");
			ServerCommand("bot_add_ct %s", "robiin");
			ServerCommand("bot_add_ct %s", "avid");
			ServerCommand("bot_add_ct %s", "twist");
			ServerCommand("mp_teamlogo_1 alli");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "PlesseN");
			ServerCommand("bot_add_t %s", "b0denmaster");
			ServerCommand("bot_add_t %s", "robiin");
			ServerCommand("bot_add_t %s", "avid");
			ServerCommand("bot_add_t %s", "twist");
			ServerCommand("mp_teamlogo_2 alli");
		}
	}
	
	if(strcmp(szTeamArg, "SSP", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "farmaG");
			ServerCommand("bot_add_ct %s", "Sw1ft");
			ServerCommand("bot_add_ct %s", "Cl34v3rs");
			ServerCommand("bot_add_ct %s", "cello");
			ServerCommand("bot_add_ct %s", "KraiS");
			ServerCommand("mp_teamlogo_1 ssp");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "farmaG");
			ServerCommand("bot_add_t %s", "Sw1ft");
			ServerCommand("bot_add_t %s", "Cl34v3rs");
			ServerCommand("bot_add_t %s", "cello");
			ServerCommand("bot_add_t %s", "KraiS");
			ServerCommand("mp_teamlogo_2 ssp");
		}
	}
	
	if(strcmp(szTeamArg, "Metiz", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "adamb");
			ServerCommand("bot_add_ct %s", "Jackinho");
			ServerCommand("bot_add_ct %s", "nilo");
			ServerCommand("bot_add_ct %s", "ztr");
			ServerCommand("bot_add_ct %s", "susp");
			ServerCommand("mp_teamlogo_1 metiz");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "adamb");
			ServerCommand("bot_add_t %s", "Jackinho");
			ServerCommand("bot_add_t %s", "nilo");
			ServerCommand("bot_add_t %s", "ztr");
			ServerCommand("bot_add_t %s", "susp");
			ServerCommand("mp_teamlogo_2 metiz");
		}
	}
	
	if(strcmp(szTeamArg, "unity", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Levi");
			ServerCommand("bot_add_ct %s", "NIO");
			ServerCommand("bot_add_ct %s", "Pechyn");
			ServerCommand("bot_add_ct %s", "M1key");
			ServerCommand("bot_add_ct %s", "K1-FiDa");
			ServerCommand("mp_teamlogo_1 unit");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Levi");
			ServerCommand("bot_add_t %s", "NIO");
			ServerCommand("bot_add_t %s", "Pechyn");
			ServerCommand("bot_add_t %s", "M1key");
			ServerCommand("bot_add_t %s", "K1-FiDa");
			ServerCommand("mp_teamlogo_2 unit");
		}
	}
	
	if(strcmp(szTeamArg, "9z", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "dgt");
			ServerCommand("bot_add_ct %s", "Martinez");
			ServerCommand("bot_add_ct %s", "maxujas");
			ServerCommand("bot_add_ct %s", "HUASOPEEK");
			ServerCommand("bot_add_ct %s", "buda");
			ServerCommand("mp_teamlogo_1 nine");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "dgt");
			ServerCommand("bot_add_t %s", "Martinez");
			ServerCommand("bot_add_t %s", "maxujas");
			ServerCommand("bot_add_t %s", "HUASOPEEK");
			ServerCommand("bot_add_t %s", "buda");
			ServerCommand("mp_teamlogo_2 nine");
		}
	}
	
	if(strcmp(szTeamArg, "SINNERS", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "NEOFRAG");
			ServerCommand("bot_add_ct %s", "oskar");
			ServerCommand("bot_add_ct %s", "SHOCK");
			ServerCommand("bot_add_ct %s", "beastik");
			ServerCommand("bot_add_ct %s", "AJTT");
			ServerCommand("mp_teamlogo_1 sinn");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "NEOFRAG");
			ServerCommand("bot_add_t %s", "oskar");
			ServerCommand("bot_add_t %s", "SHOCK");
			ServerCommand("bot_add_t %s", "beastik");
			ServerCommand("bot_add_t %s", "AJTT");
			ServerCommand("mp_teamlogo_2 sinn");
		}
	}
	
	if(strcmp(szTeamArg, "Pera", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "msN");
			ServerCommand("bot_add_ct %s", "DGL");
			ServerCommand("bot_add_ct %s", "Aaron");
			ServerCommand("bot_add_ct %s", "Kamion");
			ServerCommand("bot_add_ct %s", "Porya");
			ServerCommand("mp_teamlogo_1 pera");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "msN");
			ServerCommand("bot_add_t %s", "DGL");
			ServerCommand("bot_add_t %s", "Aaron");
			ServerCommand("bot_add_t %s", "Kamion");
			ServerCommand("bot_add_t %s", "Porya");
			ServerCommand("mp_teamlogo_2 pera");
		}
	}
	
	if(strcmp(szTeamArg, "Sangal", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "LNZ");
			ServerCommand("bot_add_ct %s", "sausol");
			ServerCommand("bot_add_ct %s", "yxngstxr");
			ServerCommand("bot_add_ct %s", "xfl0ud");
			ServerCommand("bot_add_ct %s", "Ganginho");
			ServerCommand("mp_teamlogo_1 sang");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "LNZ");
			ServerCommand("bot_add_t %s", "sausol");
			ServerCommand("bot_add_t %s", "yxngstxr");
			ServerCommand("bot_add_t %s", "xfl0ud");
			ServerCommand("bot_add_t %s", "Ganginho");
			ServerCommand("mp_teamlogo_2 sang");
		}
	}
	
	if(strcmp(szTeamArg, "Nixuh", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "flexeeee");
			ServerCommand("bot_add_ct %s", "FROZ3N");
			ServerCommand("bot_add_ct %s", "Fadey");
			ServerCommand("bot_add_ct %s", "bLazE");
			ServerCommand("bot_add_ct %s", "RustyYG");
			ServerCommand("mp_teamlogo_1 nix");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "flexeeee");
			ServerCommand("bot_add_t %s", "FROZ3N");
			ServerCommand("bot_add_t %s", "Fadey");
			ServerCommand("bot_add_t %s", "bLazE");
			ServerCommand("bot_add_t %s", "RustyYG");
			ServerCommand("mp_teamlogo_2 nix");
		}
	}
	
	if(strcmp(szTeamArg, "BESTIA", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "deco");
			ServerCommand("bot_add_ct %s", "Noktse");
			ServerCommand("bot_add_ct %s", "meyern");
			ServerCommand("bot_add_ct %s", "luchov");
			ServerCommand("bot_add_ct %s", "tomaszin");
			ServerCommand("mp_teamlogo_1 best");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "deco");
			ServerCommand("bot_add_t %s", "Noktse");
			ServerCommand("bot_add_t %s", "meyern");
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
			ServerCommand("bot_add_ct %s", "MarKE");
			ServerCommand("bot_add_ct %s", "junior");
			ServerCommand("bot_add_ct %s", "Jeorge");
			ServerCommand("bot_add_ct %s", "nosraC");
			ServerCommand("bot_add_ct %s", "cJ");
			ServerCommand("mp_teamlogo_1 nouns");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "MarKE");
			ServerCommand("bot_add_t %s", "junior");
			ServerCommand("bot_add_t %s", "Jeorge");
			ServerCommand("bot_add_t %s", "nosraC");
			ServerCommand("bot_add_t %s", "cJ");
			ServerCommand("mp_teamlogo_2 nouns");
		}
	}
	
	if(strcmp(szTeamArg, "Alpha", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "brzer");
			ServerCommand("bot_add_ct %s", "buNNy");
			ServerCommand("bot_add_ct %s", "Gnøffe");
			ServerCommand("bot_add_ct %s", "leakz");
			ServerCommand("bot_add_ct %s", "LUMSEN");
			ServerCommand("mp_teamlogo_1 alp");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "brzer");
			ServerCommand("bot_add_t %s", "buNNy");
			ServerCommand("bot_add_t %s", "Gnøffe");
			ServerCommand("bot_add_t %s", "leakz");
			ServerCommand("bot_add_t %s", "LUMSEN");
			ServerCommand("mp_teamlogo_2 alp");
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
			ServerCommand("bot_add_ct %s", "mAnGo");
			ServerCommand("bot_add_ct %s", "ReegaN");
			ServerCommand("bot_add_ct %s", "MMS");
			ServerCommand("bot_add_ct %s", "pandi7o");
			ServerCommand("mp_teamlogo_1 viper");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "zodi");
			ServerCommand("bot_add_t %s", "mAnGo");
			ServerCommand("bot_add_t %s", "ReegaN");
			ServerCommand("bot_add_t %s", "MMS");
			ServerCommand("bot_add_t %s", "pandi7o");
			ServerCommand("mp_teamlogo_2 viper");
		}
	}
	
	if(strcmp(szTeamArg, "CW", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "vigg0");
			ServerCommand("bot_add_ct %s", "Basso");
			ServerCommand("bot_add_ct %s", "szejn");
			ServerCommand("bot_add_ct %s", "Svedjehed");
			ServerCommand("bot_add_ct %s", "Fessor");
			ServerCommand("mp_teamlogo_1 cw");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "vigg0");
			ServerCommand("bot_add_t %s", "Basso");
			ServerCommand("bot_add_t %s", "szejn");
			ServerCommand("bot_add_t %s", "Svedjehed");
			ServerCommand("bot_add_t %s", "Fessor");
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
			ServerCommand("bot_add_ct %s", "Infinite");
			ServerCommand("bot_add_ct %s", "SLIGHT");
			ServerCommand("mp_teamlogo_1 wc");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "stanislaw");
			ServerCommand("bot_add_t %s", "Sonic");
			ServerCommand("bot_add_t %s", "JBa");
			ServerCommand("bot_add_t %s", "Infinite");
			ServerCommand("bot_add_t %s", "SLIGHT");
			ServerCommand("mp_teamlogo_2 wc");
		}
	}
	
	if(strcmp(szTeamArg, "d13", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "tamir");
			ServerCommand("bot_add_ct %s", "wonderzce");
			ServerCommand("bot_add_ct %s", "sonq");
			ServerCommand("bot_add_ct %s", "kyle");
			ServerCommand("bot_add_ct %s", "Ace4k");
			ServerCommand("mp_teamlogo_1 d13");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "tamir");
			ServerCommand("bot_add_t %s", "wonderzce");
			ServerCommand("bot_add_t %s", "sonq");
			ServerCommand("bot_add_t %s", "kyle");
			ServerCommand("bot_add_t %s", "Ace4k");
			ServerCommand("mp_teamlogo_2 d13");
		}
	}
	
	if(strcmp(szTeamArg, "EP", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "TOAO");
			ServerCommand("bot_add_ct %s", "fr3nd");
			ServerCommand("bot_add_ct %s", "Bajmi");
			ServerCommand("bot_add_ct %s", "Ex1st");
			ServerCommand("bot_add_ct %s", "Demho");
			ServerCommand("mp_teamlogo_1 ente");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "TOAO");
			ServerCommand("bot_add_t %s", "fr3nd");
			ServerCommand("bot_add_t %s", "Bajmi");
			ServerCommand("bot_add_t %s", "Ex1st");
			ServerCommand("bot_add_t %s", "Demho");
			ServerCommand("mp_teamlogo_2 ente");
		}
	}
	
	if(strcmp(szTeamArg, "Entropiq", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "tiziaN");
			ServerCommand("bot_add_ct %s", "mwlky");
			ServerCommand("bot_add_ct %s", "c0llins");
			ServerCommand("bot_add_ct %s", "Oxygen");
			ServerCommand("bot_add_ct %s", "Marix");
			ServerCommand("mp_teamlogo_1 ent");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "tiziaN");
			ServerCommand("bot_add_t %s", "mwlky");
			ServerCommand("bot_add_t %s", "c0llins");
			ServerCommand("bot_add_t %s", "Oxygen");
			ServerCommand("bot_add_t %s", "Marix");
			ServerCommand("mp_teamlogo_2 ent");
		}
	}
	
	if(strcmp(szTeamArg, "AVANGAR", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "TNDKingg");
			ServerCommand("bot_add_ct %s", "tasman");
			ServerCommand("bot_add_ct %s", "def1zer");
			ServerCommand("bot_add_ct %s", "BLVCKM4GIC");
			ServerCommand("bot_add_ct %s", "Pumpkin66");
			ServerCommand("mp_teamlogo_1 avg");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "TNDKingg");
			ServerCommand("bot_add_t %s", "tasman");
			ServerCommand("bot_add_t %s", "def1zer");
			ServerCommand("bot_add_t %s", "BLVCKM4GIC");
			ServerCommand("bot_add_t %s", "Pumpkin66");
			ServerCommand("mp_teamlogo_2 avg");
		}
	}
	
	if(strcmp(szTeamArg, "Permitta", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "bnox");
			ServerCommand("bot_add_ct %s", "morelz");
			ServerCommand("bot_add_ct %s", "maaryy");
			ServerCommand("bot_add_ct %s", "Vegi");
			ServerCommand("bot_add_ct %s", "mASKED");
			ServerCommand("mp_teamlogo_1 perm");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "bnox");
			ServerCommand("bot_add_t %s", "morelz");
			ServerCommand("bot_add_t %s", "maaryy");
			ServerCommand("bot_add_t %s", "Vegi");
			ServerCommand("bot_add_t %s", "mASKED");
			ServerCommand("mp_teamlogo_2 perm");
		}
	}
	
	if(strcmp(szTeamArg, "777", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Viktha");
			ServerCommand("bot_add_ct %s", "wenba");
			ServerCommand("bot_add_ct %s", "Affava");
			ServerCommand("bot_add_ct %s", "MadeInRed");
			ServerCommand("bot_add_ct %s", "Hagmeister");
			ServerCommand("mp_teamlogo_1 777");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Viktha");
			ServerCommand("bot_add_t %s", "wenba");
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
			ServerCommand("bot_add_ct %s", "swiftsteel");
			ServerCommand("bot_add_ct %s", "anttzz");
			ServerCommand("bot_add_ct %s", "casE");
			ServerCommand("bot_add_ct %s", "mizu");
			ServerCommand("bot_add_ct %s", "nitzie");
			ServerCommand("mp_teamlogo_1 hotu");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "swiftsteel");
			ServerCommand("bot_add_t %s", "anttzz");
			ServerCommand("bot_add_t %s", "casE");
			ServerCommand("bot_add_t %s", "mizu");
			ServerCommand("bot_add_t %s", "nitzie");
			ServerCommand("mp_teamlogo_2 hotu");
		}
	}
	
	if(strcmp(szTeamArg, "Falcons", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Magisk");
			ServerCommand("bot_add_ct %s", "SunPayus");
			ServerCommand("bot_add_ct %s", "Snappi");
			ServerCommand("bot_add_ct %s", "maden");
			ServerCommand("bot_add_ct %s", "s1mple");
			ServerCommand("mp_teamlogo_1 fal");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Magisk");
			ServerCommand("bot_add_t %s", "SunPayus");
			ServerCommand("bot_add_t %s", "Snappi");
			ServerCommand("bot_add_t %s", "maden");
			ServerCommand("bot_add_t %s", "s1mple");
			ServerCommand("mp_teamlogo_2 fal");
		}
	}
	
	if(strcmp(szTeamArg, "500", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "REDSTAR");
			ServerCommand("bot_add_ct %s", "dennyslaw");
			ServerCommand("bot_add_ct %s", "SHiPZ");
			ServerCommand("bot_add_ct %s", "Rainwaker");
			ServerCommand("bot_add_ct %s", "Grashog");
			ServerCommand("mp_teamlogo_1 500");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "REDSTAR");
			ServerCommand("bot_add_t %s", "dennyslaw");
			ServerCommand("bot_add_t %s", "SHiPZ");
			ServerCommand("bot_add_t %s", "Rainwaker");
			ServerCommand("bot_add_t %s", "Grashog");
			ServerCommand("mp_teamlogo_2 500");
		}
	}
	
	if(strcmp(szTeamArg, "Aurora", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Lack1");
			ServerCommand("bot_add_ct %s", "deko");
			ServerCommand("bot_add_ct %s", "Norwi");
			ServerCommand("bot_add_ct %s", "KENSI");
			ServerCommand("bot_add_ct %s", "SELLTER");
			ServerCommand("mp_teamlogo_1 aur");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Lack1");
			ServerCommand("bot_add_t %s", "deko");
			ServerCommand("bot_add_t %s", "Norwi");
			ServerCommand("bot_add_t %s", "KENSI");
			ServerCommand("bot_add_t %s", "SELLTER");
			ServerCommand("mp_teamlogo_2 aur");
		}
	}
	
	if(strcmp(szTeamArg, "ARCRED", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "synyx");
			ServerCommand("bot_add_ct %s", "DSSj");
			ServerCommand("bot_add_ct %s", "1NVISIBLEE");
			ServerCommand("bot_add_ct %s", "Get_Jeka");
			ServerCommand("bot_add_ct %s", "shg");
			ServerCommand("mp_teamlogo_1 arc");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "synyx");
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
			ServerCommand("bot_add_ct %s", "HEN1");
			ServerCommand("bot_add_ct %s", "felps");
			ServerCommand("bot_add_ct %s", "decenty");
			ServerCommand("bot_add_ct %s", "VINI");
			ServerCommand("mp_teamlogo_1 imp");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "noway");
			ServerCommand("bot_add_t %s", "HEN1");
			ServerCommand("bot_add_t %s", "felps");
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
			ServerCommand("bot_add_ct %s", "Sapec");
			ServerCommand("bot_add_ct %s", "SHiNE");
			ServerCommand("bot_add_ct %s", "Peppzor");
			ServerCommand("mp_teamlogo_1 eye");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "HEAP");
			ServerCommand("bot_add_t %s", "JW");
			ServerCommand("bot_add_t %s", "Sapec");
			ServerCommand("bot_add_t %s", "SHiNE");
			ServerCommand("bot_add_t %s", "Peppzor");
			ServerCommand("mp_teamlogo_2 eye");
		}
	}
	
	if(strcmp(szTeamArg, "Monte", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Gizmy");
			ServerCommand("bot_add_ct %s", "Woro2k");
			ServerCommand("bot_add_ct %s", "DemQQ");
			ServerCommand("bot_add_ct %s", "kRaSnaL");
			ServerCommand("bot_add_ct %s", "ryu");
			ServerCommand("mp_teamlogo_1 mont");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Gizmy");
			ServerCommand("bot_add_t %s", "Woro2k");
			ServerCommand("bot_add_t %s", "DemQQ");
			ServerCommand("bot_add_t %s", "kRaSnaL");
			ServerCommand("bot_add_t %s", "ryu");
			ServerCommand("mp_teamlogo_2 mont");
		}
	}
	
	if(strcmp(szTeamArg, "NKT", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "XigN");
			ServerCommand("bot_add_ct %s", "xerolte");
			ServerCommand("bot_add_ct %s", "fr0k");
			ServerCommand("bot_add_ct %s", "BnTeT");
			ServerCommand("bot_add_ct %s", "cool4st");
			ServerCommand("mp_teamlogo_1 nkt");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "XigN");
			ServerCommand("bot_add_t %s", "xerolte");
			ServerCommand("bot_add_t %s", "fr0k");
			ServerCommand("bot_add_t %s", "BnTeT");
			ServerCommand("bot_add_t %s", "cool4st");
			ServerCommand("mp_teamlogo_2 nkt");
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
			ServerCommand("bot_add_ct %s", "malbsMd");
			ServerCommand("bot_add_ct %s", "maNkz");
			ServerCommand("mp_teamlogo_1 m80");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Swisher");
			ServerCommand("bot_add_t %s", "slaxz-");
			ServerCommand("bot_add_t %s", "reck");
			ServerCommand("bot_add_t %s", "malbsMd");
			ServerCommand("bot_add_t %s", "maNkz");
			ServerCommand("mp_teamlogo_2 m80");
		}
	}
	
	if(strcmp(szTeamArg, "Sampi", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "\"The eLiVe\"");
			ServerCommand("bot_add_ct %s", "fino");
			ServerCommand("bot_add_ct %s", "ZEDKO");
			ServerCommand("bot_add_ct %s", "sAvana1");
			ServerCommand("bot_add_ct %s", "manguss");
			ServerCommand("mp_teamlogo_1 samp");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "\"The eLiVe\"");
			ServerCommand("bot_add_t %s", "fino");
			ServerCommand("bot_add_t %s", "ZEDKO");
			ServerCommand("bot_add_t %s", "sAvana1");
			ServerCommand("bot_add_t %s", "manguss");
			ServerCommand("mp_teamlogo_2 samp");
		}
	}
	
	if(strcmp(szTeamArg, "begrip", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Reedz");
			ServerCommand("bot_add_ct %s", "Karma");
			ServerCommand("bot_add_ct %s", "titulus");
			ServerCommand("bot_add_ct %s", "Ariant0");
			ServerCommand("bot_add_ct %s", "treckiz");
			ServerCommand("mp_teamlogo_1 beg");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Reedz");
			ServerCommand("bot_add_t %s", "Karma");
			ServerCommand("bot_add_t %s", "titulus");
			ServerCommand("bot_add_t %s", "Ariant0");
			ServerCommand("bot_add_t %s", "treckiz");
			ServerCommand("mp_teamlogo_2 beg");
		}
	}
	
	if(strcmp(szTeamArg, "GR", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "weqt2");
			ServerCommand("bot_add_ct %s", "mediocrity");
			ServerCommand("bot_add_ct %s", "qqGOD");
			ServerCommand("bot_add_ct %s", "SALO_MUX");
			ServerCommand("bot_add_ct %s", "Reminder");
			ServerCommand("mp_teamlogo_1 gr");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "weqt2");
			ServerCommand("bot_add_t %s", "mediocrity");
			ServerCommand("bot_add_t %s", "qqGOD");
			ServerCommand("bot_add_t %s", "SALO_MUX");
			ServerCommand("bot_add_t %s", "Reminder");
			ServerCommand("mp_teamlogo_2 gr");
		}
	}
	
	if(strcmp(szTeamArg, "Legacy", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "latto");
			ServerCommand("bot_add_ct %s", "NEKIZ");
			ServerCommand("bot_add_ct %s", "dumau");
			ServerCommand("bot_add_ct %s", "coldzera");
			ServerCommand("bot_add_ct %s", "b4rtiN");
			ServerCommand("mp_teamlogo_1 leg");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "latto");
			ServerCommand("bot_add_t %s", "NEKIZ");
			ServerCommand("bot_add_t %s", "dumau");
			ServerCommand("bot_add_t %s", "coldzera");
			ServerCommand("bot_add_t %s", "b4rtiN");
			ServerCommand("mp_teamlogo_2 leg");
		}
	}
	
	if(strcmp(szTeamArg, "BetBoom", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "nafany");
			ServerCommand("bot_add_ct %s", "zorte");
			ServerCommand("bot_add_ct %s", "KaiR0N-");
			ServerCommand("bot_add_ct %s", "s1ren");
			ServerCommand("bot_add_ct %s", "danistzz");
			ServerCommand("mp_teamlogo_1 bet");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "nafany");
			ServerCommand("bot_add_t %s", "zorte");
			ServerCommand("bot_add_t %s", "KaiR0N-");
			ServerCommand("bot_add_t %s", "s1ren");
			ServerCommand("bot_add_t %s", "danistzz");
			ServerCommand("mp_teamlogo_2 bet");
		}
	}
	
	if(strcmp(szTeamArg, "Fluxo", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "PKL");
			ServerCommand("bot_add_ct %s", "zevy");
			ServerCommand("bot_add_ct %s", "Lucaozy");
			ServerCommand("bot_add_ct %s", "chay");
			ServerCommand("bot_add_ct %s", "v$m");
			ServerCommand("mp_teamlogo_1 flux");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "PKL");
			ServerCommand("bot_add_t %s", "zevy");
			ServerCommand("bot_add_t %s", "Lucaozy");
			ServerCommand("bot_add_t %s", "chay");
			ServerCommand("bot_add_t %s", "v$m");
			ServerCommand("mp_teamlogo_2 flux");
		}
	}
	
	if(strcmp(szTeamArg, "Detonate", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Enzo");
			ServerCommand("bot_add_ct %s", "Tr1ck");
			ServerCommand("bot_add_ct %s", "FuuuZion");
			ServerCommand("bot_add_ct %s", "Gibbyatl");
			ServerCommand("bot_add_ct %s", "Ravenzs");
			ServerCommand("mp_teamlogo_1 det");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Enzo");
			ServerCommand("bot_add_t %s", "Tr1ck");
			ServerCommand("bot_add_t %s", "FuuuZion");
			ServerCommand("bot_add_t %s", "Gibbyatl");
			ServerCommand("bot_add_t %s", "Ravenzs");
			ServerCommand("mp_teamlogo_2 det");
		}
	}
	
	if(strcmp(szTeamArg, "DUSTY", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "EddezeNNN");
			ServerCommand("bot_add_ct %s", "TH0R");
			ServerCommand("bot_add_ct %s", "RavlE");
			ServerCommand("bot_add_ct %s", "PANDAZ");
			ServerCommand("bot_add_ct %s", "StebbiC0C0");
			ServerCommand("mp_teamlogo_1 dust");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "EddezeNNN");
			ServerCommand("bot_add_t %s", "TH0R");
			ServerCommand("bot_add_t %s", "RavlE");
			ServerCommand("bot_add_t %s", "PANDAZ");
			ServerCommand("bot_add_t %s", "StebbiC0C0");
			ServerCommand("mp_teamlogo_2 dust");
		}
	}
	
	if(strcmp(szTeamArg, "TZE", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "gRuChA");
			ServerCommand("bot_add_ct %s", "kadziu");
			ServerCommand("bot_add_ct %s", "darko");
			ServerCommand("bot_add_ct %s", "b1elany");
			ServerCommand("bot_add_ct %s", "Markoś");
			ServerCommand("mp_teamlogo_1 tze");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "gRuChA");
			ServerCommand("bot_add_t %s", "kadziu");
			ServerCommand("bot_add_t %s", "darko");
			ServerCommand("bot_add_t %s", "b1elany");
			ServerCommand("bot_add_t %s", "Markoś");
			ServerCommand("mp_teamlogo_2 tze");
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
			ServerCommand("bot_add_ct %s", "Tuurtle");
			ServerCommand("bot_add_ct %s", "ponter");
			ServerCommand("mp_teamlogo_1 odd");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "naitte");
			ServerCommand("bot_add_t %s", "WOOD7");
			ServerCommand("bot_add_t %s", "matios");
			ServerCommand("bot_add_t %s", "Tuurtle");
			ServerCommand("bot_add_t %s", "ponter");
			ServerCommand("mp_teamlogo_2 odd");
		}
	}
	
	if(strcmp(szTeamArg, "Sashi", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "PR1mE");
			ServerCommand("bot_add_ct %s", "n1Xen");
			ServerCommand("bot_add_ct %s", "nut nut");
			ServerCommand("bot_add_ct %s", "b0RUP");
			ServerCommand("bot_add_ct %s", "nikozan");
			ServerCommand("mp_teamlogo_1 sas");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "PR1mE");
			ServerCommand("bot_add_t %s", "n1Xen");
			ServerCommand("bot_add_t %s", "nut nut");
			ServerCommand("bot_add_t %s", "b0RUP");
			ServerCommand("bot_add_t %s", "nikozan");
			ServerCommand("mp_teamlogo_2 sas");
		}
	}
	
	if(strcmp(szTeamArg, "Insilio", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Pipw");
			ServerCommand("bot_add_ct %s", "FpSSS");
			ServerCommand("bot_add_ct %s", "Polt");
			ServerCommand("bot_add_ct %s", "faydett");
			ServerCommand("bot_add_ct %s", "sugaR");
			ServerCommand("mp_teamlogo_1 ins");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Pipw");
			ServerCommand("bot_add_t %s", "FpSSS");
			ServerCommand("bot_add_t %s", "Polt");
			ServerCommand("bot_add_t %s", "faydett");
			ServerCommand("bot_add_t %s", "sugaR");
			ServerCommand("mp_teamlogo_2 ins");
		}
	}
	
	if(strcmp(szTeamArg, "Case", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "yepz");
			ServerCommand("bot_add_ct %s", "RCF");
			ServerCommand("bot_add_ct %s", "urban0");
			ServerCommand("bot_add_ct %s", "RICIOLI");
			ServerCommand("bot_add_ct %s", "Snowzin");
			ServerCommand("mp_teamlogo_1 case");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "yepz");
			ServerCommand("bot_add_t %s", "RCF");
			ServerCommand("bot_add_t %s", "urban0");
			ServerCommand("bot_add_t %s", "RICIOLI");
			ServerCommand("bot_add_t %s", "Snowzin");
			ServerCommand("mp_teamlogo_2 case");
		}
	}
	
	if(strcmp(szTeamArg, "esuba", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "teCkoO");
			ServerCommand("bot_add_ct %s", "HenkkyG");
			ServerCommand("bot_add_ct %s", "Tusi");
			ServerCommand("bot_add_ct %s", "naturaL");
			ServerCommand("bot_add_ct %s", "creZe");
			ServerCommand("mp_teamlogo_1 esu");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "teCkoO");
			ServerCommand("bot_add_t %s", "HenkkyG");
			ServerCommand("bot_add_t %s", "Tusi");
			ServerCommand("bot_add_t %s", "naturaL");
			ServerCommand("bot_add_t %s", "creZe");
			ServerCommand("mp_teamlogo_2 esu");
		}
	}
	
	if(strcmp(szTeamArg, "Illuminar", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "ANeraX");
			ServerCommand("bot_add_ct %s", "ultimate");
			ServerCommand("bot_add_ct %s", "phr");
			ServerCommand("bot_add_ct %s", "Furlan");
			ServerCommand("bot_add_ct %s", "keis");
			ServerCommand("mp_teamlogo_1 illu");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "ANeraX");
			ServerCommand("bot_add_t %s", "ultimate");
			ServerCommand("bot_add_t %s", "phr");
			ServerCommand("bot_add_t %s", "Furlan");
			ServerCommand("bot_add_t %s", "keis");
			ServerCommand("mp_teamlogo_2 illu");
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
			ServerCommand("bot_add_ct %s", "Lcm");
			ServerCommand("bot_add_ct %s", "bnc");
			ServerCommand("bot_add_ct %s", "xureba");
			ServerCommand("bot_add_ct %s", "CSO");
			ServerCommand("mp_teamlogo_1 sol");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "gbb");
			ServerCommand("bot_add_t %s", "Lcm");
			ServerCommand("bot_add_t %s", "bnc");
			ServerCommand("bot_add_t %s", "xureba");
			ServerCommand("bot_add_t %s", "CSO");
			ServerCommand("mp_teamlogo_2 sol");
		}
	}
	
	if(strcmp(szTeamArg, "JANO", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Jerppa");
			ServerCommand("bot_add_ct %s", "allu");
			ServerCommand("bot_add_ct %s", "doto");
			ServerCommand("bot_add_ct %s", "Sm1llee");
			ServerCommand("bot_add_ct %s", "jelo");
			ServerCommand("mp_teamlogo_1 jano");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Jerppa");
			ServerCommand("bot_add_t %s", "allu");
			ServerCommand("bot_add_t %s", "doto");
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
			ServerCommand("bot_add_ct %s", "SnacKZ1");
			ServerCommand("bot_add_ct %s", "LapeX");
			ServerCommand("bot_add_ct %s", "ND");
			ServerCommand("bot_add_ct %s", "sehza");
			ServerCommand("bot_add_ct %s", "Shairoe");
			ServerCommand("mp_teamlogo_1 snog");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "SnacKZ1");
			ServerCommand("bot_add_t %s", "LapeX");
			ServerCommand("bot_add_t %s", "ND");
			ServerCommand("bot_add_t %s", "sehza");
			ServerCommand("bot_add_t %s", "Shairoe");
			ServerCommand("mp_teamlogo_2 snog");
		}
	}
	
	if(strcmp(szTeamArg, "BEE", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "er9k");
			ServerCommand("bot_add_ct %s", "vincso");
			ServerCommand("bot_add_ct %s", "gubi");
			ServerCommand("bot_add_ct %s", "Myekry");
			ServerCommand("bot_add_ct %s", "s1cklxrd");
			ServerCommand("mp_teamlogo_1 bee");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "er9k");
			ServerCommand("bot_add_t %s", "vincso");
			ServerCommand("bot_add_t %s", "gubi");
			ServerCommand("bot_add_t %s", "Myekry");
			ServerCommand("bot_add_t %s", "s1cklxrd");
			ServerCommand("mp_teamlogo_2 bee");
		}
	}
	
	if(strcmp(szTeamArg, "9Pandas", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "seized");
			ServerCommand("bot_add_ct %s", "iDISBALANCE");
			ServerCommand("bot_add_ct %s", "d1Ledez");
			ServerCommand("bot_add_ct %s", "clax");
			ServerCommand("bot_add_ct %s", "glowiing");
			ServerCommand("mp_teamlogo_1 pand");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "seized");
			ServerCommand("bot_add_t %s", "iDISBALANCE");
			ServerCommand("bot_add_t %s", "d1Ledez");
			ServerCommand("bot_add_t %s", "clax");
			ServerCommand("bot_add_t %s", "glowiing");
			ServerCommand("mp_teamlogo_2 pand");
		}
	}
	
	if(strcmp(szTeamArg, "Betera", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "sad");
			ServerCommand("bot_add_ct %s", "MaSvAl");
			ServerCommand("bot_add_ct %s", "nifee");
			ServerCommand("bot_add_ct %s", "lollipop21k");
			ServerCommand("bot_add_ct %s", "alex666");
			ServerCommand("mp_teamlogo_1 bete");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "sad");
			ServerCommand("bot_add_t %s", "MaSvAl");
			ServerCommand("bot_add_t %s", "nifee");
			ServerCommand("bot_add_t %s", "lollipop21k");
			ServerCommand("bot_add_t %s", "alex666");
			ServerCommand("mp_teamlogo_2 bete");
		}
	}
	
	if(strcmp(szTeamArg, "Flyte", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "mds");
			ServerCommand("bot_add_ct %s", "CoJoMo");
			ServerCommand("bot_add_ct %s", "Gabe");
			ServerCommand("bot_add_ct %s", "BeaKie");
			ServerCommand("bot_add_ct %s", "shutout");
			ServerCommand("mp_teamlogo_1 flyte");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "mds");
			ServerCommand("bot_add_t %s", "CoJoMo");
			ServerCommand("bot_add_t %s", "Gabe");
			ServerCommand("bot_add_t %s", "BeaKie");
			ServerCommand("bot_add_t %s", "shutout");
			ServerCommand("mp_teamlogo_2 flyte");
		}
	}
	
	if(strcmp(szTeamArg, "Coalesce", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "BehinDx");
			ServerCommand("bot_add_ct %s", "PrimeOPI");
			ServerCommand("bot_add_ct %s", "Karrar");
			ServerCommand("bot_add_ct %s", "wfn");
			ServerCommand("bot_add_ct %s", "moz");
			ServerCommand("mp_teamlogo_1 coal");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "BehinDx");
			ServerCommand("bot_add_t %s", "PrimeOPI");
			ServerCommand("bot_add_t %s", "Karrar");
			ServerCommand("bot_add_t %s", "wfn");
			ServerCommand("bot_add_t %s", "moz");
			ServerCommand("mp_teamlogo_2 coal");
		}
	}
	
	if(strcmp(szTeamArg, "DUDES", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "otto");
			ServerCommand("bot_add_ct %s", "Askan");
			ServerCommand("bot_add_ct %s", "Straxy");
			ServerCommand("bot_add_ct %s", "noleN");
			ServerCommand("bot_add_ct %s", "Distu");
			ServerCommand("mp_teamlogo_1 dude");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "otto");
			ServerCommand("bot_add_t %s", "Askan");
			ServerCommand("bot_add_t %s", "Straxy");
			ServerCommand("bot_add_t %s", "noleN");
			ServerCommand("bot_add_t %s", "Distu");
			ServerCommand("mp_teamlogo_2 dude");
		}
	}
	
	if(strcmp(szTeamArg, "Eruption", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "fury5k");
			ServerCommand("bot_add_ct %s", "MagnumZ");
			ServerCommand("bot_add_ct %s", "ariucle");
			ServerCommand("bot_add_ct %s", "ROUX");
			ServerCommand("bot_add_ct %s", "NEUZ");
			ServerCommand("mp_teamlogo_1 erup");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "fury5k");
			ServerCommand("bot_add_t %s", "MagnumZ");
			ServerCommand("bot_add_t %s", "ariucle");
			ServerCommand("bot_add_t %s", "ROUX");
			ServerCommand("bot_add_t %s", "NEUZ");
			ServerCommand("mp_teamlogo_2 erup");
		}
	}
	
	if(strcmp(szTeamArg, "TSM", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "valde");
			ServerCommand("bot_add_ct %s", "poizon");
			ServerCommand("bot_add_ct %s", "Zyphon");
			ServerCommand("bot_add_ct %s", "joel");
			ServerCommand("bot_add_ct %s", "KWERTZZ");
			ServerCommand("mp_teamlogo_1 tsm");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "valde");
			ServerCommand("bot_add_t %s", "poizon");
			ServerCommand("bot_add_t %s", "Zyphon");
			ServerCommand("bot_add_t %s", "joel");
			ServerCommand("bot_add_t %s", "KWERTZZ");
			ServerCommand("mp_teamlogo_2 tsm");
		}
	}
	
	if(strcmp(szTeamArg, "Rare", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "somebody");
			ServerCommand("bot_add_ct %s", "phzy");
			ServerCommand("bot_add_ct %s", "Summer");
			ServerCommand("bot_add_ct %s", "EXPRO");
			ServerCommand("bot_add_ct %s", "kory");
			ServerCommand("mp_teamlogo_1 rar");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "somebody");
			ServerCommand("bot_add_t %s", "phzy");
			ServerCommand("bot_add_t %s", "Summer");
			ServerCommand("bot_add_t %s", "EXPRO");
			ServerCommand("bot_add_t %s", "kory");
			ServerCommand("mp_teamlogo_2 rar");
		}
	}
	
	if(strcmp(szTeamArg, "TT", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "dosikzz");
			ServerCommand("bot_add_ct %s", "icyvl0ne");
			ServerCommand("bot_add_ct %s", "wetfy");
			ServerCommand("bot_add_ct %s", "kanshineF");
			ServerCommand("bot_add_ct %s", "Hitori");
			ServerCommand("mp_teamlogo_1 tt");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "dosikzz");
			ServerCommand("bot_add_t %s", "icyvl0ne");
			ServerCommand("bot_add_t %s", "wetfy");
			ServerCommand("bot_add_t %s", "kanshineF");
			ServerCommand("bot_add_t %s", "Hitori");
			ServerCommand("mp_teamlogo_2 tt");
		}
	}
	
	if(strcmp(szTeamArg, "GTZ", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "M1KA");
			ServerCommand("bot_add_ct %s", "brA");
			ServerCommand("bot_add_ct %s", "c0mplex");
			ServerCommand("bot_add_ct %s", "MattyMyimb");
			ServerCommand("bot_add_ct %s", "Jayy2s");
			ServerCommand("mp_teamlogo_1 gtz");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "M1KA");
			ServerCommand("bot_add_t %s", "brA");
			ServerCommand("bot_add_t %s", "c0mplex");
			ServerCommand("bot_add_t %s", "MattyMyimb");
			ServerCommand("bot_add_t %s", "Jayy2s");
			ServerCommand("mp_teamlogo_2 gtz");
		}
	}
	
	if(strcmp(szTeamArg, "FA", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "sacrifice");
			ServerCommand("bot_add_ct %s", "LEARSI");
			ServerCommand("bot_add_ct %s", "Jason");
			ServerCommand("bot_add_ct %s", "PNDLM");
			ServerCommand("bot_add_ct %s", "intra");
			ServerCommand("mp_teamlogo_1 fa");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "sacrifice");
			ServerCommand("bot_add_t %s", "LEARSI");
			ServerCommand("bot_add_t %s", "Jason");
			ServerCommand("bot_add_t %s", "PNDLM");
			ServerCommand("bot_add_t %s", "intra");
			ServerCommand("mp_teamlogo_2 fa");
		}
	}
	
	if(strcmp(szTeamArg, "ATOX", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "dobu");
			ServerCommand("bot_add_ct %s", "ANNIHILATION");
			ServerCommand("bot_add_ct %s", "kabal");
			ServerCommand("bot_add_ct %s", "MiQ");
			ServerCommand("bot_add_ct %s", "zesta");
			ServerCommand("mp_teamlogo_1 ato");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "dobu");
			ServerCommand("bot_add_t %s", "ANNIHILATION");
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
			ServerCommand("bot_add_ct %s", "CycloneF");
			ServerCommand("mp_teamlogo_1 rei");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Ph1NNN");
			ServerCommand("bot_add_t %s", "f1redup");
			ServerCommand("bot_add_t %s", "Bhavi");
			ServerCommand("bot_add_t %s", "R2B2");
			ServerCommand("bot_add_t %s", "CycloneF");
			ServerCommand("mp_teamlogo_2 rei");
		}
	}
	
	if(strcmp(szTeamArg, "JJH", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "m1N1");
			ServerCommand("bot_add_ct %s", "DavCost");
			ServerCommand("bot_add_ct %s", "El1an");
			ServerCommand("bot_add_ct %s", "ISSAA");
			ServerCommand("bot_add_ct %s", "ViTaL");
			ServerCommand("mp_teamlogo_1 jjh");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "m1N1");
			ServerCommand("bot_add_t %s", "DavCost");
			ServerCommand("bot_add_t %s", "El1an");
			ServerCommand("bot_add_t %s", "ISSAA");
			ServerCommand("bot_add_t %s", "ViTaL");
			ServerCommand("mp_teamlogo_2 jjh");
		}
	}
	
	if(strcmp(szTeamArg, "PDucks", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Trudo");
			ServerCommand("bot_add_ct %s", "holli");
			ServerCommand("bot_add_ct %s", "jsr");
			ServerCommand("bot_add_ct %s", "MoR");
			ServerCommand("bot_add_ct %s", "PYRO");
			ServerCommand("mp_teamlogo_1 pduc");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Trudo");
			ServerCommand("bot_add_t %s", "holli");
			ServerCommand("bot_add_t %s", "jsr");
			ServerCommand("bot_add_t %s", "MoR");
			ServerCommand("bot_add_t %s", "PYRO");
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
			ServerCommand("bot_add_ct %s", "Djoko");
			ServerCommand("bot_add_ct %s", "Ex3rcice");
			ServerCommand("bot_add_ct %s", "hAdji");
			ServerCommand("mp_teamlogo_1 3dm");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Lucky");
			ServerCommand("bot_add_t %s", "Maka");
			ServerCommand("bot_add_t %s", "Djoko");
			ServerCommand("bot_add_t %s", "Ex3rcice");
			ServerCommand("bot_add_t %s", "hAdji");
			ServerCommand("mp_teamlogo_2 3dm");
		}
	}
	
	if(strcmp(szTeamArg, "Elevate", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "snav");
			ServerCommand("bot_add_ct %s", "dare");
			ServerCommand("bot_add_ct %s", "shane");
			ServerCommand("bot_add_ct %s", "Peeping");
			ServerCommand("bot_add_ct %s", "dea");
			ServerCommand("mp_teamlogo_1 ele");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "snav");
			ServerCommand("bot_add_t %s", "dare");
			ServerCommand("bot_add_t %s", "shane");
			ServerCommand("bot_add_t %s", "Peeping");
			ServerCommand("bot_add_t %s", "dea");
			ServerCommand("mp_teamlogo_2 ele");
		}
	}
	
	if(strcmp(szTeamArg, "GenOne", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Graviti");
			ServerCommand("bot_add_ct %s", "AMANEK");
			ServerCommand("bot_add_ct %s", "Kursy");
			ServerCommand("bot_add_ct %s", "Brooxsy");
			ServerCommand("bot_add_ct %s", "Razzmo");
			ServerCommand("mp_teamlogo_1 gen");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Graviti");
			ServerCommand("bot_add_t %s", "AMANEK");
			ServerCommand("bot_add_t %s", "Kursy");
			ServerCommand("bot_add_t %s", "Brooxsy");
			ServerCommand("bot_add_t %s", "Razzmo");
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
			ServerCommand("bot_add_ct %s", "Cha0s");
			ServerCommand("bot_add_ct %s", "Byfield");
			ServerCommand("bot_add_ct %s", "FincHY");
			ServerCommand("bot_add_ct %s", "CJE");
			ServerCommand("bot_add_ct %s", "Rezzed");
			ServerCommand("mp_teamlogo_1 r");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Cha0s");
			ServerCommand("bot_add_t %s", "Byfield");
			ServerCommand("bot_add_t %s", "FincHY");
			ServerCommand("bot_add_t %s", "CJE");
			ServerCommand("bot_add_t %s", "Rezzed");
			ServerCommand("mp_teamlogo_2 r");
		}
	}
	
	if(strcmp(szTeamArg, "Preasy", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Altekz");
			ServerCommand("bot_add_ct %s", "dupreeh");
			ServerCommand("bot_add_ct %s", "TMB");
			ServerCommand("bot_add_ct %s", "refrezh");
			ServerCommand("bot_add_ct %s", "roeJ");
			ServerCommand("mp_teamlogo_1 pre");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Altekz");
			ServerCommand("bot_add_t %s", "dupreeh");
			ServerCommand("bot_add_t %s", "TMB");
			ServerCommand("bot_add_t %s", "refrezh");
			ServerCommand("bot_add_t %s", "roeJ");
			ServerCommand("mp_teamlogo_2 pre");
		}
	}
	
	if(strcmp(szTeamArg, "NRG", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Walco");
			ServerCommand("bot_add_ct %s", "oSee");
			ServerCommand("bot_add_ct %s", "Brehze");
			ServerCommand("bot_add_ct %s", "HexT");
			ServerCommand("bot_add_ct %s", "autimatic");
			ServerCommand("mp_teamlogo_1 nr");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Walco");
			ServerCommand("bot_add_t %s", "oSee");
			ServerCommand("bot_add_t %s", "Brehze");
			ServerCommand("bot_add_t %s", "HexT");
			ServerCommand("bot_add_t %s", "autimatic");
			ServerCommand("mp_teamlogo_2 nr");
		}
	}
	
	if(strcmp(szTeamArg, "Canids", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "DeStiNy");
			ServerCommand("bot_add_ct %s", "nython");
			ServerCommand("bot_add_ct %s", "venomzera");
			ServerCommand("bot_add_ct %s", "hardzao");
			ServerCommand("bot_add_ct %s", "dav1deuS");
			ServerCommand("mp_teamlogo_1 cani");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "DeStiNy");
			ServerCommand("bot_add_t %s", "nython");
			ServerCommand("bot_add_t %s", "venomzera");
			ServerCommand("bot_add_t %s", "hardzao");
			ServerCommand("bot_add_t %s", "dav1deuS");
			ServerCommand("mp_teamlogo_2 cani");
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
			
			if (IsItMyChance(5.0))
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
					
					if (((GetAliveTeamCount(CS_TEAM_T) == 0 && GetAliveTeamCount(CS_TEAM_CT) == 1 && fPlantedC4Distance > 100.0 && GetTask(i) != ESCAPE_FROM_BOMB) || fPlantedC4Distance > 2000.0) && GetEntData(i, g_iBotNearbyEnemiesOffset) == 0 && !g_bDontSwitch[i])
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

public void OnGameFrame()
{
	g_bBombPlanted = !!GameRules_GetProp("m_bBombPlanted");

	for (int client = 1; client <= MaxClients; client++)
	{
		if (IsValidClient(client) && IsFakeClient(client) && IsPlayerAlive(client))
		{
			if (!IsValidEntity(g_iActiveWeapon[client])) return;
			
			g_pCurrArea[client] = NavMesh_GetNearestArea(g_fBotOrigin[client]);
			
			if ((GetAliveTeamCount(CS_TEAM_T) == 0 || GetAliveTeamCount(CS_TEAM_CT) == 0) && !g_bDontSwitch[client])
			{
				SDKCall(g_hSwitchWeaponCall, client, GetPlayerWeaponSlot(client, CS_SLOT_KNIFE), 0);
				g_bEveryoneDead = true;
			}
				
			if(g_bFreezetimeEnd && IsItMyChance(0.5) && g_iDoingSmokeNum[client] == -1)
				g_iDoingSmokeNum[client] = GetNearestGrenade(client);
			
			if (g_bIsProBot[client])
			{
				int iDroppedC4 = GetNearestEntity(client, "weapon_c4");
				
				if (g_bFreezetimeEnd && !g_bBombPlanted && !IsValidEntity(iDroppedC4) && !BotIsHiding(client) && GetTask(client) != COLLECT_HOSTAGES && GetTask(client) != RESCUE_HOSTAGES)
				{
					float fClientEyes[3];
					GetClientEyePosition(client, fClientEyes);
				
					//Rifles
					int iAWP = GetNearestEntity(client, "weapon_awp");
					int iAK47 = GetNearestEntity(client, "weapon_ak47");
					int iM4A1 = GetNearestEntity(client, "weapon_m4a1");
					int iPrimary = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
					int iPrimaryDefIndex;

					if (IsValidEntity(iAWP))
					{
						iPrimaryDefIndex = IsValidEntity(iPrimary) ? GetEntProp(iPrimary, Prop_Send, "m_iItemDefinitionIndex") : 0;
						float fAWPLocation[3];
						
						if (iPrimaryDefIndex != 9)
						{
							GetEntPropVector(iAWP, Prop_Send, "m_vecOrigin", fAWPLocation);

							if (GetVectorLength(fAWPLocation) > 0.0 && IsPointVisible(fClientEyes, fAWPLocation) && (GetGameTime() - g_fSearchGunTimestamp[client] > 5.0 || GetVectorDistance(g_fWeaponPos[client], fAWPLocation) < 5.0))
							{
								BotMoveTo(client, fAWPLocation, FASTEST_ROUTE);
								Array_Copy(fAWPLocation, g_fWeaponPos[client], 3);
								g_fSearchGunTimestamp[client] = GetGameTime();
								if (GetVectorDistance(g_fBotOrigin[client], fAWPLocation) < 50.0 && GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY) != -1)
									CS_DropWeapon(client, GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY), false);
							}
						}
						else if (iPrimary == -1)
						{
							GetEntPropVector(iAWP, Prop_Send, "m_vecOrigin", fAWPLocation);

							if (GetVectorLength(fAWPLocation) > 0.0 && IsPointVisible(fClientEyes, fAWPLocation) && (GetGameTime() - g_fSearchGunTimestamp[client] > 5.0 || GetVectorDistance(g_fWeaponPos[client], fAWPLocation) < 5.0))
							{
								BotMoveTo(client, fAWPLocation, FASTEST_ROUTE);
								Array_Copy(fAWPLocation, g_fWeaponPos[client], 3);
								g_fSearchGunTimestamp[client] = GetGameTime();
							}
						}
					}
					else if (IsValidEntity(iAK47))
					{
						iPrimaryDefIndex = IsValidEntity(iPrimary) ? GetEntProp(iPrimary, Prop_Send, "m_iItemDefinitionIndex") : 0;
						float fAK47Location[3];
						
						if ((iPrimaryDefIndex != 7 && iPrimaryDefIndex != 9) || iPrimary == -1)
						{
							GetEntPropVector(iAK47, Prop_Send, "m_vecOrigin", fAK47Location);

							if (GetVectorLength(fAK47Location) > 0.0 && IsPointVisible(fClientEyes, fAK47Location) && (GetGameTime() - g_fSearchGunTimestamp[client] > 5.0 || GetVectorDistance(g_fWeaponPos[client], fAK47Location) < 5.0))
							{
								BotMoveTo(client, fAK47Location, FASTEST_ROUTE);
								Array_Copy(fAK47Location, g_fWeaponPos[client], 3);
								g_fSearchGunTimestamp[client] = GetGameTime();
							}
						}
					}
					else if (IsValidEntity(iM4A1))
					{
						iPrimaryDefIndex = IsValidEntity(iPrimary) ? GetEntProp(iPrimary, Prop_Send, "m_iItemDefinitionIndex") : 0;
						float fM4A1Location[3];

						if (iPrimaryDefIndex != 7 && iPrimaryDefIndex != 9 && iPrimaryDefIndex != 16 && iPrimaryDefIndex != 60)
						{
							GetEntPropVector(iM4A1, Prop_Send, "m_vecOrigin", fM4A1Location);

							if (GetVectorLength(fM4A1Location) > 0.0 && IsPointVisible(fClientEyes, fM4A1Location) && (GetGameTime() - g_fSearchGunTimestamp[client] > 5.0 || GetVectorDistance(g_fWeaponPos[client], fM4A1Location) < 5.0))
							{
								BotMoveTo(client, fM4A1Location, FASTEST_ROUTE);
								Array_Copy(fM4A1Location, g_fWeaponPos[client], 3);
								g_fSearchGunTimestamp[client] = GetGameTime();
								if (GetVectorDistance(g_fBotOrigin[client], fM4A1Location) < 50.0 && GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY) != -1)
									CS_DropWeapon(client, GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY), false);
							}
						}
						else if (iPrimary == -1)
						{
							GetEntPropVector(iM4A1, Prop_Send, "m_vecOrigin", fM4A1Location);

							if (GetVectorLength(fM4A1Location) > 0.0 && IsPointVisible(fClientEyes, fM4A1Location) && (GetGameTime() - g_fSearchGunTimestamp[client] > 5.0 || GetVectorDistance(g_fWeaponPos[client], fM4A1Location) < 5.0))
							{
								BotMoveTo(client, fM4A1Location, FASTEST_ROUTE);
								Array_Copy(fM4A1Location, g_fWeaponPos[client], 3);
								g_fSearchGunTimestamp[client] = GetGameTime();
							}
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
							
							if (GetVectorLength(fDeagleLocation) > 0.0 && IsPointVisible(fClientEyes, fDeagleLocation) && (GetGameTime() - g_fSearchGunTimestamp[client] > 5.0 || GetVectorDistance(g_fWeaponPos[client], fDeagleLocation) < 5.0))
							{
								BotMoveTo(client, fDeagleLocation, FASTEST_ROUTE);
								Array_Copy(fDeagleLocation, g_fWeaponPos[client], 3);
								g_fSearchGunTimestamp[client] = GetGameTime();
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
							
							if (GetVectorLength(fTec9Location) > 0.0 && IsPointVisible(fClientEyes, fTec9Location) && (GetGameTime() - g_fSearchGunTimestamp[client] > 5.0 || GetVectorDistance(g_fWeaponPos[client], fTec9Location) < 5.0))
							{
								BotMoveTo(client, fTec9Location, FASTEST_ROUTE);
								Array_Copy(fTec9Location, g_fWeaponPos[client], 3);
								g_fSearchGunTimestamp[client] = GetGameTime();
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
							
							if (GetVectorLength(fFiveSevenLocation) > 0.0 && IsPointVisible(fClientEyes, fFiveSevenLocation) && (GetGameTime() - g_fSearchGunTimestamp[client] > 5.0 || GetVectorDistance(g_fWeaponPos[client], fFiveSevenLocation) < 5.0))
							{
								BotMoveTo(client, fFiveSevenLocation, FASTEST_ROUTE);
								Array_Copy(fFiveSevenLocation, g_fWeaponPos[client], 3);
								g_fSearchGunTimestamp[client] = GetGameTime();
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
							
							if (GetVectorLength(fP250Location) > 0.0 && IsPointVisible(fClientEyes, fP250Location) && (GetGameTime() - g_fSearchGunTimestamp[client] > 5.0 || GetVectorDistance(g_fWeaponPos[client], fP250Location) < 5.0))
							{
								BotMoveTo(client, fP250Location, FASTEST_ROUTE);
								Array_Copy(fP250Location, g_fWeaponPos[client], 3);
								g_fSearchGunTimestamp[client] = GetGameTime();
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
							
							if (GetVectorLength(fUSPLocation) > 0.0 && IsPointVisible(fClientEyes, fUSPLocation) && (GetGameTime() - g_fSearchGunTimestamp[client] > 5.0 || GetVectorDistance(g_fWeaponPos[client], fUSPLocation) < 5.0))
							{
								BotMoveTo(client, fUSPLocation, FASTEST_ROUTE);
								Array_Copy(fUSPLocation, g_fWeaponPos[client], 3);
								g_fSearchGunTimestamp[client] = GetGameTime();
								if (GetVectorDistance(g_fBotOrigin[client], fUSPLocation) < 50.0 && GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY) != -1)
									CS_DropWeapon(client, GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY), false);
							}
						}
					}
				}
			}
		}
	}
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
		char szClanTag[MAX_NAME_LENGTH];
		
		GetClientName(client, szBotName, sizeof(szBotName));
		g_bIsProBot[client] = false;
		SDKHook(client, SDKHook_WeaponDrop, OnWeaponDrop);
		
		if(IsProBot(szBotName, szClanTag))
		{
			if(strcmp(szBotName, "s1mple") == 0 || strcmp(szBotName, "ZywOo") == 0 || strcmp(szBotName, "NiKo") == 0 || strcmp(szBotName, "sh1ro") == 0 || strcmp(szBotName, "Ax1Le") == 0 || strcmp(szBotName, "donk") == 0)
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
		
		CS_SetClientClanTag(client, szClanTag);
		GetCrosshairCode(szBotName, g_szCrosshairCode[client], 35);
		
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
			g_bCanThrowGrenade[i] = false;
			g_iTarget[i] = -1;
			g_iPrevTarget[i] = -1;
			g_iDoingSmokeNum[i] = -1;
			g_fShootTimestamp[i] = 0.0;				
			g_fThrowNadeTimestamp[i] = 0.0;				
			g_fSearchGunTimestamp[i] = 0.0;				
			g_fCrouchTimestamp[i] = 0.0;				
			g_fWeaponPos[i] = { 0.0, 0.0, 0.0 };						
			
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
		
		if (strcmp(szWeaponName, "weapon_awp") == 0 || strcmp(szWeaponName, "weapon_ssg08") == 0)
			CreateTimer(0.1, Timer_DelaySwitch, GetClientUserId(client));
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
		
		return MRES_Ignored;
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
		
		if(eItems_GetWeaponSlotByWeapon(g_iActiveWeapon[client]) == CS_SLOT_KNIFE)
			BotEquipBestWeapon(client, true);
		
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
		
		if(g_bFreezetimeEnd)
		{
			if (!IsValidEntity(g_iActiveWeapon[client])) return Plugin_Continue;
			
			int iDefIndex = GetEntProp(g_iActiveWeapon[client], Prop_Send, "m_iItemDefinitionIndex");
			
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
					float fPlayerVelocity[3];
					GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", fPlayerVelocity);
										
					if(view_as<LookAtSpotState>(GetEntData(client, g_iBotLookAtSpotStateOffset)) == LOOK_AT_SPOT && GetVectorLength(fPlayerVelocity) == 0.0 && (GetEntityFlags(client) & FL_ONGROUND))
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
					BotAttack(client, g_iTarget[client]);
					if(g_iPrevTarget[client] == -1)
						g_fCrouchTimestamp[client] = GetGameTime() + Math_GetRandomFloat(0.175, 0.20);
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
					switch(iDefIndex)
					{
						case 7, 8, 10, 13, 14, 16, 17, 19, 23, 24, 25, 26, 28, 33, 34, 39, 60:
						{
							if (fOnTarget > fAimTolerance && fTargetDistance < 2000.0)
							{
								iButtons &= ~IN_ATTACK;
							
								if(!bIsReloading)
								{
									iButtons |= IN_ATTACK;
									SetEntDataFloat(client, g_iFireWeaponOffset, GetGameTime());
								}
							}
							
							if (fOnTarget > fAimTolerance && !bIsDucking && fTargetDistance < 2000.0 && iDefIndex != 17 && iDefIndex != 19 && iDefIndex != 23 && iDefIndex != 24 && iDefIndex != 25 && iDefIndex != 26 && iDefIndex != 33 && iDefIndex != 34)
								AutoStop(client, fVel, fAngles);
							else if (fTargetDistance > 2000.0 && GetEntDataFloat(client, g_iFireWeaponOffset) == GetGameTime())
								AutoStop(client, fVel, fAngles);
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
								AutoStop(client, fVel, fAngles);
							}	
						}
					}
					
					float fClientLoc[3];
					Array_Copy(g_fBotOrigin[client], fClientLoc, 3);
					fClientLoc[2] += HalfHumanHeight;
						
					if (GetGameTime() >= g_fCrouchTimestamp[client] && !GetEntProp(g_iActiveWeapon[client], Prop_Data, "m_bInReload") && IsPointVisible(fClientLoc, g_fTargetPos[client]) && fOnTarget > fAimTolerance && fTargetDistance < 2000.0 && (iDefIndex == 7 || iDefIndex == 8 || iDefIndex == 10 || iDefIndex == 13 || iDefIndex == 14 || iDefIndex == 16 || iDefIndex == 39 || iDefIndex == 60 || iDefIndex == 28))
						iButtons |= IN_DUCK;
						
					if(!(GetEntityFlags(client) & FL_ONGROUND))
						iButtons &= ~IN_ATTACK;
						
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

bool IsProBot(const char[] szName, char[] szClanTag)
{
	char szPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, szPath, sizeof(szPath), "configs/bot_names.txt");
	
	if (!FileExists(szPath))
	{
		PrintToServer("Configuration file %s is not found.", szPath);
		return false;
	}
	
	KeyValues kv = new KeyValues("Names");
	
	if (!kv.ImportFromFile(szPath))
	{
		delete kv;
		PrintToServer("Unable to parse Key Values file %s.", szPath);
		return false;
	}
	
	if(!kv.GetString(szName, szClanTag, MAX_NAME_LENGTH))
	{
		delete kv;
		return false;
	}
	
	if(strcmp(szClanTag, "") == 0)
	{
		delete kv;
		return false;
	}
	
	delete kv;
	
	return true;
}

bool GetCrosshairCode(const char[] szName, char[] szCrosshairCode, int iSize)
{
	char szPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, szPath, sizeof(szPath), "configs/bot_crosshaircodes.txt");
	
	if (!FileExists(szPath))
	{
		PrintToServer("Configuration file %s is not found.", szPath);
		return false;
	}
	
	KeyValues kv = new KeyValues("Names");
	
	if (!kv.ImportFromFile(szPath))
	{
		delete kv;
		PrintToServer("Unable to parse Key Values file %s.", szPath);
		return false;
	}
	
	kv.GetString(szName, szCrosshairCode, iSize);
	
	delete kv;
	
	return true;
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
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConfig, SDKConf_Signature, "CCSBot::Attack");
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	if ((g_hBotAttack = EndPrepSDKCall()) == null)SetFailState("Failed to create SDKCall for CCSBot::Attack signature!");
	
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

public void BotAttack(int client, int iTarget)
{
	SDKCall(g_hBotAttack, client, iTarget);
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
	
	//Out of ammo? or Reloading? or Finishing Weapon Switch?
	if(GetEntProp(g_iActiveWeapon[client], Prop_Data, "m_bInReload") || GetEntProp(g_iActiveWeapon[client], Prop_Send, "m_iClip1") <= 0 || GetEntProp(g_iActiveWeapon[client], Prop_Send, "m_iIronSightMode") == 2)
		return true;
	
	if(GetEntPropFloat(client, Prop_Send, "m_flNextAttack") > GetGameTime())
		return true;
	
	return GetEntPropFloat(g_iActiveWeapon[client], Prop_Send, "m_flNextPrimaryAttack") >= GetGameTime();
}

public Action Timer_ThrowSmoke(Handle hTimer, int client)
{
	g_bCanThrowGrenade[client] = true;
	
	return Plugin_Stop;
}

public Action Timer_SmokeDelay(Handle hTimer, int client)
{
	g_iDoingSmokeNum[client] = -1;
	g_bCanThrowGrenade[client] = false;
	
	return Plugin_Stop;
}

public Action Timer_DelaySwitch(Handle hTimer, any client)
{
	client = GetClientOfUserId(client);
	
	if(client != 0 && IsClientInGame(client))
	{
		SDKCall(g_hSwitchWeaponCall, client, GetPlayerWeaponSlot(client, CS_SLOT_KNIFE), 0);
		SDKCall(g_hSwitchWeaponCall, client, GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY), 0);
	}
	
	return Plugin_Stop;
}

public Action Timer_DelayBestWeapon(Handle hTimer, any client)
{
	client = GetClientOfUserId(client);
	
	if(client != 0 && IsClientInGame(client))
		BotEquipBestWeapon(client, true);
	
	return Plugin_Stop;
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

public Action Timer_ThrowGrenade(Handle hTimer, any client)
{
	client = GetClientOfUserId(client);
	
	if(client != 0 && IsClientInGame(client))
		g_bCanThrowGrenade[client] = true;
	
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
						if (IsItMyChance(80.0))
							bShootSpine = true;
					}
					case 2, 3, 4, 30, 32, 36, 61, 63:
					{
						if (IsItMyChance(30.0))
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
	GetGrenadeToss(client, fTarget);
	
	Array_Copy(fTarget, g_fNadeTarget[client], 3);
	SDKCall(g_hSwitchWeaponCall, client, GetPlayerWeaponSlot(client, CS_SLOT_GRENADE), 0);
	RequestFrame(DelayThrow, GetClientUserId(client));
}

stock void GetGrenadeToss(int client, float fTossTarget[3])
{
	float fEyePosition[3], fTo[3];
	GetClientEyePosition(client, fEyePosition);
	SubtractVectors(fTossTarget, fEyePosition, fTo);
	float fRange = GetVectorLength(fTo);

	const float fSlope = 0.2; // 0.25f;
	float fTossHeight = fSlope * fRange;

	float fHeightInc = fTossHeight / 10.0;
	float fTarget[3];
	float safeSpace = fTossHeight / 2.0;

	// Build a box to sweep along the ray when looking for obstacles
	float fMins[3] = { -16.0, -16.0, 0.0 };
	float fMaxs[3] = { 16.0, 16.0, 72.0 };
	fMins[2] = 0.0;
	fMaxs[2] = fHeightInc;


	// find low and high bounds of toss window
	float fLow = 0.0;
	float fHigh = fTossHeight + safeSpace;
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
			if (fLow + safeSpace > fHigh)
				// narrow window
				fTossHeight = (fHigh + fLow)/2.0;
			else
				fTossHeight = fLow + safeSpace;
		}
		else if (fTossHeight > fHigh - safeSpace)
		{
			if (fHigh - safeSpace < fLow)
				// narrow window
				fTossHeight = (fHigh + fLow)/2.0;
			else
				fTossHeight = fHigh - safeSpace;
		}
		
		fTossTarget[2] += fTossHeight;
	}
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