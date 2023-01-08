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

char g_szMap[128];
char g_szCrosshairCode[MAXPLAYERS+1][35], g_szPreviousBuy[MAXPLAYERS+1][128];
bool g_bIsBombScenario, g_bIsHostageScenario, g_bFreezetimeEnd, g_bBombPlanted, g_bTerroristEco, g_bAbortExecute, g_bEveryoneDead, g_bHalftimeSwitch;
bool g_bUseCZ75[MAXPLAYERS+1], g_bUseUSP[MAXPLAYERS+1], g_bUseM4A1S[MAXPLAYERS+1], g_bDontSwitch[MAXPLAYERS+1], g_bDropWeapon[MAXPLAYERS+1], g_bHasGottenDrop[MAXPLAYERS+1];
bool g_bIsProBot[MAXPLAYERS+1], g_bThrowGrenade[MAXPLAYERS+1], g_bUncrouch[MAXPLAYERS+1], g_bCanThrowGrenade[MAXPLAYERS+1];
int g_iProfileRank[MAXPLAYERS+1], g_iPlayerColor[MAXPLAYERS+1], g_iTarget[MAXPLAYERS+1], g_iDoingSmokeNum[MAXPLAYERS+1];
int g_iRndExecute = -1, g_iCurrentRound, g_iRoundsPlayed, g_iCTScore, g_iTScore, g_iMaxNades;
int g_iProfileRankOffset, g_iPlayerColorOffset;
int g_iBotTargetSpotOffset, g_iBotNearbyEnemiesOffset, g_iFireWeaponOffset, g_iEnemyVisibleOffset, g_iBotProfileOffset, g_iBotSafeTimeOffset, g_iBotEnemyOffset, g_iBotLookAtSpotStateOffset, g_iBotMoraleOffset, g_iBotTaskOffset, g_iBotNadeStateOffs;
float g_fTargetPos[MAXPLAYERS+1][3], g_fNadeTarget[MAXPLAYERS+1][3], g_fLookAngleMaxAccel[MAXPLAYERS+1], g_fReactionTime[MAXPLAYERS+1], g_fAggression[MAXPLAYERS+1], g_fRoundStart, g_fFreezeTimeEnd;
float g_fZoomedTimestamp[MAXPLAYERS+1];
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
ArrayList g_ArrayNades[128] =  { null, ... };
CNavArea g_pCurrArea[MAXPLAYERS+1];

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

#include "bot_stuff/de_mirage.sp"
#include "bot_stuff/de_dust2.sp"
#include "bot_stuff/de_inferno.sp"
#include "bot_stuff/de_overpass.sp"
#include "bot_stuff/de_train.sp"
#include "bot_stuff/de_nuke.sp"
#include "bot_stuff/de_vertigo.sp"
#include "bot_stuff/de_cache.sp"
#include "bot_stuff/de_ancient.sp"

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
			ServerCommand("bot_add_ct %s", "Brollan");
			ServerCommand("bot_add_ct %s", "REZ");
			ServerCommand("bot_add_ct %s", "hampus");
			ServerCommand("bot_add_ct %s", "Aleksib");
			ServerCommand("bot_add_ct %s", "es3tag");
			ServerCommand("mp_teamlogo_1 nip");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Brollan");
			ServerCommand("bot_add_t %s", "REZ");
			ServerCommand("bot_add_t %s", "hampus");
			ServerCommand("bot_add_t %s", "Aleksib");
			ServerCommand("bot_add_t %s", "es3tag");
			ServerCommand("mp_teamlogo_2 nip");
		}
	}
	
	if(strcmp(szTeamArg, "MIBR", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "brnz4n");
			ServerCommand("bot_add_ct %s", "HEN1");
			ServerCommand("bot_add_ct %s", "Tuurtle");
			ServerCommand("bot_add_ct %s", "JOTA");
			ServerCommand("bot_add_ct %s", "exit");
			ServerCommand("mp_teamlogo_1 mibr");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "brnz4n");
			ServerCommand("bot_add_t %s", "HEN1");
			ServerCommand("bot_add_t %s", "Tuurtle");
			ServerCommand("bot_add_t %s", "JOTA");
			ServerCommand("bot_add_t %s", "exit");
			ServerCommand("mp_teamlogo_2 mibr");
		}
	}
	
	if(strcmp(szTeamArg, "FaZe", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Twistzz");
			ServerCommand("bot_add_ct %s", "broky");
			ServerCommand("bot_add_ct %s", "karrigan");
			ServerCommand("bot_add_ct %s", "rain");
			ServerCommand("bot_add_ct %s", "ropz");
			ServerCommand("mp_teamlogo_1 faze");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Twistzz");
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
			ServerCommand("bot_add_ct %s", "gla1ve");
			ServerCommand("bot_add_ct %s", "dev1ce");
			ServerCommand("bot_add_ct %s", "Xyp9x");
			ServerCommand("bot_add_ct %s", "MistR");
			ServerCommand("bot_add_ct %s", "blameF");
			ServerCommand("mp_teamlogo_1 astr");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "gla1ve");
			ServerCommand("bot_add_t %s", "dev1ce");
			ServerCommand("bot_add_t %s", "Xyp9x");
			ServerCommand("bot_add_t %s", "MistR");
			ServerCommand("bot_add_t %s", "blameF");
			ServerCommand("mp_teamlogo_2 astr");
		}
	}
	
	if(strcmp(szTeamArg, "1win", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "glowiing");
			ServerCommand("bot_add_ct %s", "flamie");
			ServerCommand("bot_add_ct %s", "TRAVIS");
			ServerCommand("bot_add_ct %s", "lollipop21k");
			ServerCommand("bot_add_ct %s", "deko");
			ServerCommand("mp_teamlogo_1 1win");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "glowiing");
			ServerCommand("bot_add_t %s", "flamie");
			ServerCommand("bot_add_t %s", "TRAVIS");
			ServerCommand("bot_add_t %s", "lollipop21k");
			ServerCommand("bot_add_t %s", "deko");
			ServerCommand("mp_teamlogo_2 1win");
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
			ServerCommand("bot_add_ct %s", "jks");
			ServerCommand("bot_add_ct %s", "NiKo");
			ServerCommand("mp_teamlogo_1 g2");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "huNter-");
			ServerCommand("bot_add_t %s", "m0NESY");
			ServerCommand("bot_add_t %s", "HooXi");
			ServerCommand("bot_add_t %s", "jks");
			ServerCommand("bot_add_t %s", "NiKo");
			ServerCommand("mp_teamlogo_2 g2");
		}
	}
	
	if(strcmp(szTeamArg, "fnatic", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "roeJ");
			ServerCommand("bot_add_ct %s", "nicoodoz");
			ServerCommand("bot_add_ct %s", "KRIMZ");
			ServerCommand("bot_add_ct %s", "FASHR");
			ServerCommand("bot_add_ct %s", "mezii");
			ServerCommand("mp_teamlogo_1 fntc");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "roeJ");
			ServerCommand("bot_add_t %s", "nicoodoz");
			ServerCommand("bot_add_t %s", "KRIMZ");
			ServerCommand("bot_add_t %s", "FASHR");
			ServerCommand("bot_add_t %s", "mezii");
			ServerCommand("mp_teamlogo_2 fntc");
		}
	}
	
	if(strcmp(szTeamArg, "Dynamo", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Dytor");
			ServerCommand("bot_add_ct %s", "capseN");
			ServerCommand("bot_add_ct %s", "K1-FiDa");
			ServerCommand("bot_add_ct %s", "Valencio");
			ServerCommand("bot_add_ct %s", "nbqq");
			ServerCommand("mp_teamlogo_1 dyna");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Dytor");
			ServerCommand("bot_add_t %s", "capseN");
			ServerCommand("bot_add_t %s", "K1-FiDa");
			ServerCommand("bot_add_t %s", "Valencio");
			ServerCommand("bot_add_t %s", "nbqq");
			ServerCommand("mp_teamlogo_2 dyna");
		}
	}
	
	if(strcmp(szTeamArg, "mouz", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "dexter");
			ServerCommand("bot_add_ct %s", "torzsi");
			ServerCommand("bot_add_ct %s", "xertioN");
			ServerCommand("bot_add_ct %s", "frozen");
			ServerCommand("bot_add_ct %s", "JDC");
			ServerCommand("mp_teamlogo_1 mouz");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "dexter");
			ServerCommand("bot_add_t %s", "torzsi");
			ServerCommand("bot_add_t %s", "xertioN");
			ServerCommand("bot_add_t %s", "frozen");
			ServerCommand("bot_add_t %s", "JDC");
			ServerCommand("mp_teamlogo_2 mouz");
		}
	}
	
	if(strcmp(szTeamArg, "TYLOO", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Summer");
			ServerCommand("bot_add_ct %s", "Attacker");
			ServerCommand("bot_add_ct %s", "SLOWLY");
			ServerCommand("bot_add_ct %s", "Freeman");
			ServerCommand("bot_add_ct %s", "DANK1NG");
			ServerCommand("mp_teamlogo_1 tyl");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Summer");
			ServerCommand("bot_add_t %s", "Attacker");
			ServerCommand("bot_add_t %s", "SLOWLY");
			ServerCommand("bot_add_t %s", "Freeman");
			ServerCommand("bot_add_t %s", "DANK1NG");
			ServerCommand("mp_teamlogo_2 tyl");
		}
	}
	
	if(strcmp(szTeamArg, "EG", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "HexT");
			ServerCommand("bot_add_ct %s", "CeRq");
			ServerCommand("bot_add_ct %s", "Brehze");
			ServerCommand("bot_add_ct %s", "autimatic");
			ServerCommand("bot_add_ct %s", "neaLaN");
			ServerCommand("mp_teamlogo_1 evl");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "HexT");
			ServerCommand("bot_add_t %s", "CeRq");
			ServerCommand("bot_add_t %s", "Brehze");
			ServerCommand("bot_add_t %s", "autimatic");
			ServerCommand("bot_add_t %s", "neaLaN");
			ServerCommand("mp_teamlogo_2 evl");
		}
	}
	
	if(strcmp(szTeamArg, "NaVi", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "electronic");
			ServerCommand("bot_add_ct %s", "s1mple");
			ServerCommand("bot_add_ct %s", "B1T");
			ServerCommand("bot_add_ct %s", "sdy");
			ServerCommand("bot_add_ct %s", "Perfecto");
			ServerCommand("mp_teamlogo_1 navi");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "electronic");
			ServerCommand("bot_add_t %s", "s1mple");
			ServerCommand("bot_add_t %s", "B1T");
			ServerCommand("bot_add_t %s", "sdy");
			ServerCommand("bot_add_t %s", "Perfecto");
			ServerCommand("mp_teamlogo_2 navi");
		}
	}
	
	if(strcmp(szTeamArg, "Liquid", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "YEKINDAR");
			ServerCommand("bot_add_ct %s", "oSee");
			ServerCommand("bot_add_ct %s", "nitr0");
			ServerCommand("bot_add_ct %s", "ELiGE");
			ServerCommand("bot_add_ct %s", "NAF");
			ServerCommand("mp_teamlogo_1 liq");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "YEKINDAR");
			ServerCommand("bot_add_t %s", "oSee");
			ServerCommand("bot_add_t %s", "nitr0");
			ServerCommand("bot_add_t %s", "ELiGE");
			ServerCommand("bot_add_t %s", "NAF");
			ServerCommand("mp_teamlogo_2 liq");
		}
	}
	
	if(strcmp(szTeamArg, "AGO", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Furlan");
			ServerCommand("bot_add_ct %s", "snatchie");
			ServerCommand("bot_add_ct %s", "jedqr");
			ServerCommand("bot_add_ct %s", "sh3nanigan");
			ServerCommand("bot_add_ct %s", "leman");
			ServerCommand("mp_teamlogo_1 ago");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Furlan");
			ServerCommand("bot_add_t %s", "snatchie");
			ServerCommand("bot_add_t %s", "jedqr");
			ServerCommand("bot_add_t %s", "sh3nanigan");
			ServerCommand("bot_add_t %s", "leman");
			ServerCommand("mp_teamlogo_2 ago");
		}
	}
	
	if(strcmp(szTeamArg, "ENCE", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Snappi");
			ServerCommand("bot_add_ct %s", "SunPayus");
			ServerCommand("bot_add_ct %s", "valde");
			ServerCommand("bot_add_ct %s", "maden");
			ServerCommand("bot_add_ct %s", "dycha");
			ServerCommand("mp_teamlogo_1 ence");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Snappi");
			ServerCommand("bot_add_t %s", "SunPayus");
			ServerCommand("bot_add_t %s", "valde");
			ServerCommand("bot_add_t %s", "maden");
			ServerCommand("bot_add_t %s", "dycha");
			ServerCommand("mp_teamlogo_2 ence");
		}
	}
	
	if(strcmp(szTeamArg, "Vitality", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "dupreeh");
			ServerCommand("bot_add_ct %s", "ZywOo");
			ServerCommand("bot_add_ct %s", "apEX");
			ServerCommand("bot_add_ct %s", "Magisk");
			ServerCommand("bot_add_ct %s", "Spinx");
			ServerCommand("mp_teamlogo_1 vita");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "dupreeh");
			ServerCommand("bot_add_t %s", "ZywOo");
			ServerCommand("bot_add_t %s", "apEX");
			ServerCommand("bot_add_t %s", "Magisk");
			ServerCommand("bot_add_t %s", "Spinx");
			ServerCommand("mp_teamlogo_2 vita");
		}
	}
	
	if(strcmp(szTeamArg, "BIG", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "k1to");
			ServerCommand("bot_add_ct %s", "syrsoN");
			ServerCommand("bot_add_ct %s", "faveN");
			ServerCommand("bot_add_ct %s", "tabseN");
			ServerCommand("bot_add_ct %s", "Krimbo");
			ServerCommand("mp_teamlogo_1 big");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "k1to");
			ServerCommand("bot_add_t %s", "syrsoN");
			ServerCommand("bot_add_t %s", "faveN");
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
			ServerCommand("bot_add_ct %s", "saffee");
			ServerCommand("bot_add_ct %s", "drop");
			ServerCommand("bot_add_ct %s", "KSCERATO");
			ServerCommand("bot_add_ct %s", "arT");
			ServerCommand("mp_teamlogo_1 furi");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "yuurih");
			ServerCommand("bot_add_t %s", "saffee");
			ServerCommand("bot_add_t %s", "drop");
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
			ServerCommand("bot_add_ct %s", "FaNg");
			ServerCommand("bot_add_ct %s", "floppy");
			ServerCommand("bot_add_ct %s", "Grim");
			ServerCommand("mp_teamlogo_1 col");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "JT");
			ServerCommand("bot_add_t %s", "hallzerk");
			ServerCommand("bot_add_t %s", "FaNg");
			ServerCommand("bot_add_t %s", "floppy");
			ServerCommand("bot_add_t %s", "Grim");
			ServerCommand("mp_teamlogo_2 col");
		}
	}
	
	if(strcmp(szTeamArg, "Atom", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Mercury");
			ServerCommand("bot_add_ct %s", "kaze");
			ServerCommand("bot_add_ct %s", "Moseyuh");
			ServerCommand("bot_add_ct %s", "JamYoung");
			ServerCommand("bot_add_ct %s", "advent");
			ServerCommand("mp_teamlogo_1 atom");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Mercury");
			ServerCommand("bot_add_t %s", "kaze");
			ServerCommand("bot_add_t %s", "Moseyuh");
			ServerCommand("bot_add_t %s", "JamYoung");
			ServerCommand("bot_add_t %s", "advent");
			ServerCommand("mp_teamlogo_2 atom");
		}
	}
	
	if(strcmp(szTeamArg, "forZe", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "KENSI");
			ServerCommand("bot_add_ct %s", "zorte");
			ServerCommand("bot_add_ct %s", "Krad");
			ServerCommand("bot_add_ct %s", "shalfey");
			ServerCommand("bot_add_ct %s", "Jerry");
			ServerCommand("mp_teamlogo_1 forz");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "KENSI");
			ServerCommand("bot_add_t %s", "zorte");
			ServerCommand("bot_add_t %s", "Krad");
			ServerCommand("bot_add_t %s", "shalfey");
			ServerCommand("bot_add_t %s", "Jerry");
			ServerCommand("mp_teamlogo_2 forz");
		}
	}
	
	if(strcmp(szTeamArg, "Sprout", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Staehr");
			ServerCommand("bot_add_ct %s", "slaxz");
			ServerCommand("bot_add_ct %s", "Zyphon");
			ServerCommand("bot_add_ct %s", "lauNX");
			ServerCommand("bot_add_ct %s", "refrezh");
			ServerCommand("mp_teamlogo_1 spr");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Staehr");
			ServerCommand("bot_add_t %s", "slaxz");
			ServerCommand("bot_add_t %s", "Zyphon");
			ServerCommand("bot_add_t %s", "lauNX");
			ServerCommand("bot_add_t %s", "refrezh");
			ServerCommand("mp_teamlogo_2 spr");
		}
	}
	
	if(strcmp(szTeamArg, "Heroic", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "TeSeS");
			ServerCommand("bot_add_ct %s", "cadiaN");
			ServerCommand("bot_add_ct %s", "sjuush");
			ServerCommand("bot_add_ct %s", "Jabbi");
			ServerCommand("bot_add_ct %s", "stavn");
			ServerCommand("mp_teamlogo_1 hero");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "TeSeS");
			ServerCommand("bot_add_t %s", "cadiaN");
			ServerCommand("bot_add_t %s", "sjuush");
			ServerCommand("bot_add_t %s", "Jabbi");
			ServerCommand("bot_add_t %s", "stavn");
			ServerCommand("mp_teamlogo_2 hero");
		}
	}
	
	if(strcmp(szTeamArg, "VP", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "n0rb3r7");
			ServerCommand("bot_add_ct %s", "Jame");
			ServerCommand("bot_add_ct %s", "qikert");
			ServerCommand("bot_add_ct %s", "FL1T");
			ServerCommand("bot_add_ct %s", "fame");
			ServerCommand("mp_teamlogo_1 vp");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "n0rb3r7");
			ServerCommand("bot_add_t %s", "Jame");
			ServerCommand("bot_add_t %s", "qikert");
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
			ServerCommand("bot_add_ct %s", "jL");
			ServerCommand("bot_add_ct %s", "STYKO");
			ServerCommand("bot_add_ct %s", "shox");
			ServerCommand("mp_teamlogo_1 ape");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "jkaem");
			ServerCommand("bot_add_t %s", "nawwk");
			ServerCommand("bot_add_t %s", "jL");
			ServerCommand("bot_add_t %s", "STYKO");
			ServerCommand("bot_add_t %s", "shox");
			ServerCommand("mp_teamlogo_2 ape");
		}
	}
	
	if(strcmp(szTeamArg, "Grayhound", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "INS");
			ServerCommand("bot_add_ct %s", "sico");
			ServerCommand("bot_add_ct %s", "aliStair");
			ServerCommand("bot_add_ct %s", "Vexite");
			ServerCommand("bot_add_ct %s", "Liazz");
			ServerCommand("mp_teamlogo_1 gray");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "INS");
			ServerCommand("bot_add_t %s", "sico");
			ServerCommand("bot_add_t %s", "aliStair");
			ServerCommand("bot_add_t %s", "Vexite");
			ServerCommand("bot_add_t %s", "Liazz");
			ServerCommand("mp_teamlogo_2 gray");
		}
	}
	
	if(strcmp(szTeamArg, "HAVU", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "zehN");
			ServerCommand("bot_add_ct %s", "spargo");
			ServerCommand("bot_add_ct %s", "Aerial");
			ServerCommand("bot_add_ct %s", "xseveN");
			ServerCommand("bot_add_ct %s", "doto");
			ServerCommand("mp_teamlogo_1 havu");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "zehN");
			ServerCommand("bot_add_t %s", "spargo");
			ServerCommand("bot_add_t %s", "Aerial");
			ServerCommand("bot_add_t %s", "xseveN");
			ServerCommand("bot_add_t %s", "doto");
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
			ServerCommand("bot_add_ct %s", "maNkz");
			ServerCommand("bot_add_ct %s", "Cabbi");
			ServerCommand("bot_add_ct %s", "salazar");
			ServerCommand("mp_teamlogo_1 ecs");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "kraghen");
			ServerCommand("bot_add_t %s", "Queenix");
			ServerCommand("bot_add_t %s", "maNkz");
			ServerCommand("bot_add_t %s", "Cabbi");
			ServerCommand("bot_add_t %s", "salazar");
			ServerCommand("mp_teamlogo_2 ecs");
		}
	}
	
	if(strcmp(szTeamArg, "Riders", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "mopoz");
			ServerCommand("bot_add_ct %s", "Martinez");
			ServerCommand("bot_add_ct %s", "sausol");
			ServerCommand("bot_add_ct %s", "\"alex*\"");
			ServerCommand("bot_add_ct %s", "dav1g");
			ServerCommand("mp_teamlogo_1 ride");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "mopoz");
			ServerCommand("bot_add_t %s", "Martinez");
			ServerCommand("bot_add_t %s", "sausol");
			ServerCommand("bot_add_t %s", "\"alex*\"");
			ServerCommand("bot_add_t %s", "dav1g");
			ServerCommand("mp_teamlogo_2 ride");
		}
	}
	
	if(strcmp(szTeamArg, "eSuba", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Pechyn");
			ServerCommand("bot_add_ct %s", "M1key");
			ServerCommand("bot_add_ct %s", "luko");
			ServerCommand("bot_add_ct %s", "blogg1s");
			ServerCommand("bot_add_ct %s", "Levi");
			ServerCommand("mp_teamlogo_1 esu");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Pechyn");
			ServerCommand("bot_add_t %s", "M1key");
			ServerCommand("bot_add_t %s", "luko");
			ServerCommand("bot_add_t %s", "blogg1s");
			ServerCommand("bot_add_t %s", "Levi");
			ServerCommand("mp_teamlogo_2 esu");
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
			ServerCommand("bot_add_ct %s", "ERSIN");
			ServerCommand("bot_add_ct %s", "SEMINTE");
			ServerCommand("mp_teamlogo_1 nex");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "BTN");
			ServerCommand("bot_add_t %s", "XELLOW");
			ServerCommand("bot_add_t %s", "ragga");
			ServerCommand("bot_add_t %s", "ERSIN");
			ServerCommand("bot_add_t %s", "SEMINTE");
			ServerCommand("mp_teamlogo_2 nex");
		}
	}
	
	if(strcmp(szTeamArg, "Nemiga", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "xsepower");
			ServerCommand("bot_add_ct %s", "BELCHONOKK");
			ServerCommand("bot_add_ct %s", "fostar");
			ServerCommand("bot_add_ct %s", "keep3r");
			ServerCommand("bot_add_ct %s", "1eeR");
			ServerCommand("mp_teamlogo_1 nem");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "xsepower");
			ServerCommand("bot_add_t %s", "BELCHONOKK");
			ServerCommand("bot_add_t %s", "fostar");
			ServerCommand("bot_add_t %s", "keep3r");
			ServerCommand("bot_add_t %s", "1eeR");
			ServerCommand("mp_teamlogo_2 nem");
		}
	}
	
	if(strcmp(szTeamArg, "IHC", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Techno4K");
			ServerCommand("bot_add_ct %s", "bLitz");
			ServerCommand("bot_add_ct %s", "kabal");
			ServerCommand("bot_add_ct %s", "Annihilation");
			ServerCommand("bot_add_ct %s", "sk0R");
			ServerCommand("mp_teamlogo_1 ihc");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Techno4K");
			ServerCommand("bot_add_t %s", "bLitz");
			ServerCommand("bot_add_t %s", "kabal");
			ServerCommand("bot_add_t %s", "Annihilation");
			ServerCommand("bot_add_t %s", "sk0R");
			ServerCommand("mp_teamlogo_2 ihc");
		}
	}
	
	if(strcmp(szTeamArg, "Infinity", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "k1Nky");
			ServerCommand("bot_add_ct %s", "pacman^v^");
			ServerCommand("bot_add_ct %s", "spamzzy");
			ServerCommand("bot_add_ct %s", "tor1towOw");
			ServerCommand("bot_add_ct %s", "Marro");
			ServerCommand("mp_teamlogo_1 infi");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "k1Nky");
			ServerCommand("bot_add_t %s", "pacman^v^");
			ServerCommand("bot_add_t %s", "spamzzy");
			ServerCommand("bot_add_t %s", "tor1towOw");
			ServerCommand("bot_add_t %s", "Marro");
			ServerCommand("mp_teamlogo_2 infi");
		}
	}
	
	if(strcmp(szTeamArg, "Isurus", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "meyern");
			ServerCommand("bot_add_ct %s", "Noktse");
			ServerCommand("bot_add_ct %s", "reversive");
			ServerCommand("bot_add_ct %s", "decov9jse");
			ServerCommand("bot_add_ct %s", "luchov");
			ServerCommand("mp_teamlogo_1 isu");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "meyern");
			ServerCommand("bot_add_t %s", "Noktse");
			ServerCommand("bot_add_t %s", "reversive");
			ServerCommand("bot_add_t %s", "decov9jse");
			ServerCommand("bot_add_t %s", "luchov");
			ServerCommand("mp_teamlogo_2 isu");
		}
	}
	
	if(strcmp(szTeamArg, "paiN", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "PKL");
			ServerCommand("bot_add_ct %s", "zevy");
			ServerCommand("bot_add_ct %s", "skullz");
			ServerCommand("bot_add_ct %s", "biguzera");
			ServerCommand("bot_add_ct %s", "hardzao");
			ServerCommand("mp_teamlogo_1 pain");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "PKL");
			ServerCommand("bot_add_t %s", "zevy");
			ServerCommand("bot_add_t %s", "skullz");
			ServerCommand("bot_add_t %s", "biguzera");
			ServerCommand("bot_add_t %s", "hardzao");
			ServerCommand("mp_teamlogo_2 pain");
		}
	}
	
	if(strcmp(szTeamArg, "Sharks", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "chay");
			ServerCommand("bot_add_ct %s", "drg");
			ServerCommand("bot_add_ct %s", "jnt");
			ServerCommand("bot_add_ct %s", "n1ssim");
			ServerCommand("bot_add_ct %s", "togs");
			ServerCommand("mp_teamlogo_1 shrk");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "chay");
			ServerCommand("bot_add_t %s", "drg");
			ServerCommand("bot_add_t %s", "jnt");
			ServerCommand("bot_add_t %s", "n1ssim");
			ServerCommand("bot_add_t %s", "togs");
			ServerCommand("mp_teamlogo_2 shrk");
		}
	}
	
	if(strcmp(szTeamArg, "LOne", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "iDk");
			ServerCommand("bot_add_ct %s", "Maluk3");
			ServerCommand("bot_add_ct %s", "trk");
			ServerCommand("bot_add_ct %s", "malbsMd");
			ServerCommand("bot_add_ct %s", "pesadelo");
			ServerCommand("mp_teamlogo_1 lone");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "iDk");
			ServerCommand("bot_add_t %s", "Maluk3");
			ServerCommand("bot_add_t %s", "trk");
			ServerCommand("bot_add_t %s", "malbsMd");
			ServerCommand("bot_add_t %s", "pesadelo");
			ServerCommand("mp_teamlogo_2 lone");
		}
	}
	
	if(strcmp(szTeamArg, "9ine", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Goofy");
			ServerCommand("bot_add_ct %s", "SZPERO");
			ServerCommand("bot_add_ct %s", "KEi");
			ServerCommand("bot_add_ct %s", "Kylar");
			ServerCommand("bot_add_ct %s", "mynio");
			ServerCommand("mp_teamlogo_1 9ine");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Goofy");
			ServerCommand("bot_add_t %s", "SZPERO");
			ServerCommand("bot_add_t %s", "KEi");
			ServerCommand("bot_add_t %s", "Kylar");
			ServerCommand("bot_add_t %s", "mynio");
			ServerCommand("mp_teamlogo_2 9ine");
		}
	}
	
	if(strcmp(szTeamArg, "GamerLegion", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "iM");
			ServerCommand("bot_add_ct %s", "acoR");
			ServerCommand("bot_add_ct %s", "isak");
			ServerCommand("bot_add_ct %s", "siuhy");
			ServerCommand("bot_add_ct %s", "Keoz");
			ServerCommand("mp_teamlogo_1 gl");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "iM");
			ServerCommand("bot_add_t %s", "acoR");
			ServerCommand("bot_add_t %s", "isak");
			ServerCommand("bot_add_t %s", "siuhy");
			ServerCommand("bot_add_t %s", "Keoz");
			ServerCommand("mp_teamlogo_2 gl");
		}
	}
	
	if(strcmp(szTeamArg, "divizon", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "j1NZO");
			ServerCommand("bot_add_ct %s", "astra");
			ServerCommand("bot_add_ct %s", "cello");
			ServerCommand("bot_add_ct %s", "ReacTioNNN");
			ServerCommand("bot_add_ct %s", "masta");
			ServerCommand("mp_teamlogo_1 divi");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "j1NZO");
			ServerCommand("bot_add_t %s", "astra");
			ServerCommand("bot_add_t %s", "cello");
			ServerCommand("bot_add_t %s", "ReacTioNNN");
			ServerCommand("bot_add_t %s", "masta");
			ServerCommand("mp_teamlogo_2 divi");
		}
	}
	
	if(strcmp(szTeamArg, "Goliath", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "aw3some");
			ServerCommand("bot_add_ct %s", "March");
			ServerCommand("bot_add_ct %s", "tristanxa");
			ServerCommand("bot_add_ct %s", ".exe");
			ServerCommand("bot_add_ct %s", "slash");
			ServerCommand("mp_teamlogo_1 goli");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "aw3some");
			ServerCommand("bot_add_t %s", "March");
			ServerCommand("bot_add_t %s", "tristanxa");
			ServerCommand("bot_add_t %s", ".exe");
			ServerCommand("bot_add_t %s", "slash");
			ServerCommand("mp_teamlogo_2 goli");
		}
	}
	
	if(strcmp(szTeamArg, "ECB", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "ritchiEE");
			ServerCommand("bot_add_ct %s", "Stev0se");
			ServerCommand("bot_add_ct %s", "simix");
			ServerCommand("bot_add_ct %s", "n0te");
			ServerCommand("bot_add_ct %s", "Nexius");
			ServerCommand("mp_teamlogo_1 ecb");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "ritchiEE");
			ServerCommand("bot_add_t %s", "Stev0se");
			ServerCommand("bot_add_t %s", "simix");
			ServerCommand("bot_add_t %s", "n0te");
			ServerCommand("bot_add_t %s", "Nexius");
			ServerCommand("mp_teamlogo_2 ecb");
		}
	}
	
	if(strcmp(szTeamArg, "Bravado", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Doru");
			ServerCommand("bot_add_ct %s", "SloWye");
			ServerCommand("bot_add_ct %s", "Wip3ouT");
			ServerCommand("bot_add_ct %s", "bLazE");
			ServerCommand("bot_add_ct %s", "wilj");
			ServerCommand("mp_teamlogo_1 bravg");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Doru");
			ServerCommand("bot_add_t %s", "SloWye");
			ServerCommand("bot_add_t %s", "Wip3ouT");
			ServerCommand("bot_add_t %s", "bLazE");
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
			ServerCommand("bot_add_ct %s", "bottle");
			ServerCommand("mp_teamlogo_1 sh");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "captainMo");
			ServerCommand("bot_add_t %s", "AE");
			ServerCommand("bot_add_t %s", "18yM");
			ServerCommand("bot_add_t %s", "XiaosaGe");
			ServerCommand("bot_add_t %s", "bottle");
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
			ServerCommand("bot_add_ct %s", "imoRR");
			ServerCommand("bot_add_ct %s", "xfl0ud");
			ServerCommand("mp_teamlogo_1 eter");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "XANTARES");
			ServerCommand("bot_add_t %s", "Calyx");
			ServerCommand("bot_add_t %s", "MAJ3R");
			ServerCommand("bot_add_t %s", "imoRR");
			ServerCommand("bot_add_t %s", "xfl0ud");
			ServerCommand("mp_teamlogo_2 eter");
		}
	}
	
	if(strcmp(szTeamArg, "K23", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Jyo");
			ServerCommand("bot_add_ct %s", "iDISBALANCE");
			ServerCommand("bot_add_ct %s", "Raijin");
			ServerCommand("bot_add_ct %s", "def1zer");
			ServerCommand("bot_add_ct %s", "X5G7V");
			ServerCommand("mp_teamlogo_1 k23");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Jyo");
			ServerCommand("bot_add_t %s", "iDISBALANCE");
			ServerCommand("bot_add_t %s", "Raijin");
			ServerCommand("bot_add_t %s", "def1zer");
			ServerCommand("bot_add_t %s", "X5G7V");
			ServerCommand("mp_teamlogo_2 k23");
		}
	}
	
	if(strcmp(szTeamArg, "VERTEX", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "BRACE");
			ServerCommand("bot_add_ct %s", "pz");
			ServerCommand("bot_add_ct %s", "ADDICT");
			ServerCommand("bot_add_ct %s", "malta");
			ServerCommand("bot_add_ct %s", "Valiance");
			ServerCommand("mp_teamlogo_1 vert");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "BRACE");
			ServerCommand("bot_add_t %s", "pz");
			ServerCommand("bot_add_t %s", "ADDICT");
			ServerCommand("bot_add_t %s", "malta");
			ServerCommand("bot_add_t %s", "Valiance");
			ServerCommand("mp_teamlogo_2 vert");
		}
	}
	
	if(strcmp(szTeamArg, "C9", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "nafany");
			ServerCommand("bot_add_ct %s", "sh1ro");
			ServerCommand("bot_add_ct %s", "interz");
			ServerCommand("bot_add_ct %s", "Ax1Le");
			ServerCommand("bot_add_ct %s", "Hobbit");
			ServerCommand("mp_teamlogo_1 c9");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "nafany");
			ServerCommand("bot_add_t %s", "sh1ro");
			ServerCommand("bot_add_t %s", "interz");
			ServerCommand("bot_add_t %s", "Ax1Le");
			ServerCommand("bot_add_t %s", "Hobbit");
			ServerCommand("mp_teamlogo_2 c9");
		}
	}
	
	if(strcmp(szTeamArg, "Davenport", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Pugg");
			ServerCommand("bot_add_ct %s", "CoJoMo");
			ServerCommand("bot_add_ct %s", "corn");
			ServerCommand("bot_add_ct %s", "spek");
			ServerCommand("bot_add_ct %s", "swicher");
			ServerCommand("mp_teamlogo_1 dav");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Pugg");
			ServerCommand("bot_add_t %s", "CoJoMo");
			ServerCommand("bot_add_t %s", "corn");
			ServerCommand("bot_add_t %s", "spek");
			ServerCommand("bot_add_t %s", "swicher");
			ServerCommand("mp_teamlogo_2 dav");
		}
	}
	
	if(strcmp(szTeamArg, "ATK", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "b0denmaster");
			ServerCommand("bot_add_ct %s", "MisteM");
			ServerCommand("bot_add_ct %s", "djay");
			ServerCommand("bot_add_ct %s", "Fadey");
			ServerCommand("bot_add_ct %s", "Swisher");
			ServerCommand("mp_teamlogo_1 atk");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "b0denmaster");
			ServerCommand("bot_add_t %s", "MisteM");
			ServerCommand("bot_add_t %s", "djay");
			ServerCommand("bot_add_t %s", "Fadey");
			ServerCommand("bot_add_t %s", "Swisher");
			ServerCommand("mp_teamlogo_2 atk");
		}
	}
	
	if(strcmp(szTeamArg, "Wings", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "ChildKing");
			ServerCommand("bot_add_ct %s", "lan");
			ServerCommand("bot_add_ct %s", "MarT1n");
			ServerCommand("bot_add_ct %s", "B1NGO");
			ServerCommand("bot_add_ct %s", "gas");
			ServerCommand("mp_teamlogo_1 wings");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "ChildKing");
			ServerCommand("bot_add_t %s", "lan");
			ServerCommand("bot_add_t %s", "MarT1n");
			ServerCommand("bot_add_t %s", "B1NGO");
			ServerCommand("bot_add_t %s", "gas");
			ServerCommand("mp_teamlogo_2 wings");
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
			ServerCommand("bot_add_ct %s", "EXPRO");
			ServerCommand("bot_add_ct %s", "Nelly");
			ServerCommand("mp_teamlogo_1 lynn");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "westmelon");
			ServerCommand("bot_add_t %s", "z4kr");
			ServerCommand("bot_add_t %s", "Starry");
			ServerCommand("bot_add_t %s", "EXPRO");
			ServerCommand("bot_add_t %s", "Nelly");
			ServerCommand("mp_teamlogo_2 lynn");
		}
	}
	
	if(strcmp(szTeamArg, "cph", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "birdfromsky");
			ServerCommand("bot_add_ct %s", "regali");
			ServerCommand("bot_add_ct %s", "b0RUP");
			ServerCommand("bot_add_ct %s", "TMB");
			ServerCommand("bot_add_ct %s", "raalz");
			ServerCommand("mp_teamlogo_1 cope");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "birdfromsky");
			ServerCommand("bot_add_t %s", "regali");
			ServerCommand("bot_add_t %s", "b0RUP");
			ServerCommand("bot_add_t %s", "TMB");
			ServerCommand("bot_add_t %s", "raalz");
			ServerCommand("mp_teamlogo_2 cope");
		}
	}
	
	if(strcmp(szTeamArg, "OG", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "NEOFRAG");
			ServerCommand("bot_add_ct %s", "degster");
			ServerCommand("bot_add_ct %s", "nexa");
			ServerCommand("bot_add_ct %s", "F1KU");
			ServerCommand("bot_add_ct %s", "flameZ");
			ServerCommand("mp_teamlogo_1 og");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "NEOFRAG");
			ServerCommand("bot_add_t %s", "degster");
			ServerCommand("bot_add_t %s", "nexa");
			ServerCommand("bot_add_t %s", "F1KU");
			ServerCommand("bot_add_t %s", "flameZ");
			ServerCommand("mp_teamlogo_2 og");
		}
	}
	
	if(strcmp(szTeamArg, "BNE", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "juanflatroo");
			ServerCommand("bot_add_ct %s", "SENER1");
			ServerCommand("bot_add_ct %s", "sinnopsyy");
			ServerCommand("bot_add_ct %s", "gxx-");
			ServerCommand("bot_add_ct %s", "rigoN");
			ServerCommand("mp_teamlogo_1 bne");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "juanflatroo");
			ServerCommand("bot_add_t %s", "SENER1");
			ServerCommand("bot_add_t %s", "sinnopsyy");
			ServerCommand("bot_add_t %s", "gxx-");
			ServerCommand("bot_add_t %s", "rigoN");
			ServerCommand("mp_teamlogo_2 bne");
		}
	}
	
	if(strcmp(szTeamArg, "Tricked", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Nodios");
			ServerCommand("bot_add_ct %s", "kwezz");
			ServerCommand("bot_add_ct %s", "Lucky");
			ServerCommand("bot_add_ct %s", "IceBerg");
			ServerCommand("bot_add_ct %s", "PR1mE");
			ServerCommand("mp_teamlogo_1 trick");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Nodios");
			ServerCommand("bot_add_t %s", "kwezz");
			ServerCommand("bot_add_t %s", "Lucky");
			ServerCommand("bot_add_t %s", "IceBerg");
			ServerCommand("bot_add_t %s", "PR1mE");
			ServerCommand("mp_teamlogo_2 trick");
		}
	}
	
	if(strcmp(szTeamArg, "Endpoint", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Surreal");
			ServerCommand("bot_add_ct %s", "mhL");
			ServerCommand("bot_add_ct %s", "MiGHTYMAX");
			ServerCommand("bot_add_ct %s", "HeavyGod");
			ServerCommand("bot_add_ct %s", "Nertz");
			ServerCommand("mp_teamlogo_1 endp");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Surreal");
			ServerCommand("bot_add_t %s", "mhL");
			ServerCommand("bot_add_t %s", "MiGHTYMAX");
			ServerCommand("bot_add_t %s", "HeavyGod");
			ServerCommand("bot_add_t %s", "Nertz");
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
			ServerCommand("bot_add_ct %s", "JUST");
			ServerCommand("bot_add_ct %s", "MUTiRiS");
			ServerCommand("bot_add_ct %s", "rmn");
			ServerCommand("mp_teamlogo_1 saw");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "ewjerkz");
			ServerCommand("bot_add_t %s", "story");
			ServerCommand("bot_add_t %s", "JUST");
			ServerCommand("bot_add_t %s", "MUTiRiS");
			ServerCommand("bot_add_t %s", "rmn");
			ServerCommand("mp_teamlogo_2 saw");
		}
	}
	
	if(strcmp(szTeamArg, "D13", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "hasteka");
			ServerCommand("bot_add_ct %s", "IMAGINE");
			ServerCommand("bot_add_ct %s", "910");
			ServerCommand("bot_add_ct %s", "danss");
			ServerCommand("bot_add_ct %s", "Frip");
			ServerCommand("mp_teamlogo_1 d13");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "hasteka");
			ServerCommand("bot_add_t %s", "IMAGINE");
			ServerCommand("bot_add_t %s", "910");
			ServerCommand("bot_add_t %s", "danss");
			ServerCommand("bot_add_t %s", "Frip");
			ServerCommand("mp_teamlogo_2 d13");
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
			ServerCommand("bot_add_ct %s", "Orbit");
			ServerCommand("bot_add_ct %s", "Spexy");
			ServerCommand("mp_teamlogo_1 ssp");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "farmaG");
			ServerCommand("bot_add_t %s", "Sw1ft");
			ServerCommand("bot_add_t %s", "Cl34v3rs");
			ServerCommand("bot_add_t %s", "Orbit");
			ServerCommand("bot_add_t %s", "Spexy");
			ServerCommand("mp_teamlogo_2 ssp");
		}
	}
	
	if(strcmp(szTeamArg, "Lilmix", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "quix");
			ServerCommand("bot_add_ct %s", "bobeksde");
			ServerCommand("bot_add_ct %s", "FRANSSON");
			ServerCommand("bot_add_ct %s", "hns");
			ServerCommand("bot_add_ct %s", "Hype");
			ServerCommand("mp_teamlogo_1 lil");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "quix");
			ServerCommand("bot_add_t %s", "bobeksde");
			ServerCommand("bot_add_t %s", "FRANSSON");
			ServerCommand("bot_add_t %s", "hns");
			ServerCommand("bot_add_t %s", "Hype");
			ServerCommand("mp_teamlogo_2 lil");
		}
	}
	
	if(strcmp(szTeamArg, "FTW", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Ag1l");
			ServerCommand("bot_add_ct %s", "stadodo");
			ServerCommand("bot_add_ct %s", "DDias");
			ServerCommand("bot_add_ct %s", "suka");
			ServerCommand("bot_add_ct %s", "arrozdoce");
			ServerCommand("mp_teamlogo_1 ftw");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Ag1l");
			ServerCommand("bot_add_t %s", "stadodo");
			ServerCommand("bot_add_t %s", "DDias");
			ServerCommand("bot_add_t %s", "suka");
			ServerCommand("bot_add_t %s", "arrozdoce");
			ServerCommand("mp_teamlogo_2 ftw");
		}
	}
	
	if(strcmp(szTeamArg, "Tigers", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "HenkkyG");
			ServerCommand("bot_add_ct %s", "NIO");
			ServerCommand("bot_add_ct %s", "Rutk0");
			ServerCommand("bot_add_ct %s", "majky");
			ServerCommand("bot_add_ct %s", "creZe");
			ServerCommand("mp_teamlogo_1 tigers");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "HenkkyG");
			ServerCommand("bot_add_t %s", "NIO");
			ServerCommand("bot_add_t %s", "Rutk0");
			ServerCommand("bot_add_t %s", "majky");
			ServerCommand("bot_add_t %s", "creZe");
			ServerCommand("mp_teamlogo_2 tigers");
		}
	}
	
	if(strcmp(szTeamArg, "9z", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "dgt");
			ServerCommand("bot_add_ct %s", "dav1d");
			ServerCommand("bot_add_ct %s", "maxujas");
			ServerCommand("bot_add_ct %s", "try");
			ServerCommand("bot_add_ct %s", "buda");
			ServerCommand("mp_teamlogo_1 nine");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "dgt");
			ServerCommand("bot_add_t %s", "dav1d");
			ServerCommand("bot_add_t %s", "maxujas");
			ServerCommand("bot_add_t %s", "try");
			ServerCommand("bot_add_t %s", "buda");
			ServerCommand("mp_teamlogo_2 nine");
		}
	}
	
	if(strcmp(szTeamArg, "SINNERS", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "ZEDKO");
			ServerCommand("bot_add_ct %s", "oskar");
			ServerCommand("bot_add_ct %s", "SHOCK");
			ServerCommand("bot_add_ct %s", "beastik");
			ServerCommand("bot_add_ct %s", "Zero");
			ServerCommand("mp_teamlogo_1 sinn");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "ZEDKO");
			ServerCommand("bot_add_t %s", "oskar");
			ServerCommand("bot_add_t %s", "SHOCK");
			ServerCommand("bot_add_t %s", "beastik");
			ServerCommand("bot_add_t %s", "Zero");
			ServerCommand("mp_teamlogo_2 sinn");
		}
	}
	
	if(strcmp(szTeamArg, "EP", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "\"The eLiVe\"");
			ServerCommand("bot_add_ct %s", "h4rn");
			ServerCommand("bot_add_ct %s", "manguss");
			ServerCommand("bot_add_ct %s", "Blytz");
			ServerCommand("bot_add_ct %s", "system");
			ServerCommand("mp_teamlogo_1 ente");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "\"The eLiVe\"");
			ServerCommand("bot_add_t %s", "h4rn");
			ServerCommand("bot_add_t %s", "manguss");
			ServerCommand("bot_add_t %s", "Blytz");
			ServerCommand("bot_add_t %s", "system");
			ServerCommand("mp_teamlogo_2 ente");
		}
	}
	
	if(strcmp(szTeamArg, "Lemondogs", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "xelos");
			ServerCommand("bot_add_ct %s", "adamb");
			ServerCommand("bot_add_ct %s", "hemzk9");
			ServerCommand("bot_add_ct %s", "susp");
			ServerCommand("bot_add_ct %s", "KriLLe");
			ServerCommand("mp_teamlogo_1 lemon");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "xelos");
			ServerCommand("bot_add_t %s", "adamb");
			ServerCommand("bot_add_t %s", "hemzk9");
			ServerCommand("bot_add_t %s", "susp");
			ServerCommand("bot_add_t %s", "KriLLe");
			ServerCommand("mp_teamlogo_2 lemon");
		}
	}
	
	if(strcmp(szTeamArg, "Illuminar", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "szejn");
			ServerCommand("bot_add_ct %s", "TOAO");
			ServerCommand("bot_add_ct %s", "byali");
			ServerCommand("bot_add_ct %s", "morelz");
			ServerCommand("bot_add_ct %s", "mASKED");
			ServerCommand("mp_teamlogo_1 illu");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "szejn");
			ServerCommand("bot_add_t %s", "TOAO");
			ServerCommand("bot_add_t %s", "byali");
			ServerCommand("bot_add_t %s", "morelz");
			ServerCommand("bot_add_t %s", "mASKED");
			ServerCommand("mp_teamlogo_2 illu");
		}
	}
	
	if(strcmp(szTeamArg, "Sangal", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "ScrunK");
			ServerCommand("bot_add_ct %s", "kyuubii");
			ServerCommand("bot_add_ct %s", "kory");
			ServerCommand("bot_add_ct %s", "Soulfly");
			ServerCommand("bot_add_ct %s", "phzy");
			ServerCommand("mp_teamlogo_1 sang");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "ScrunK");
			ServerCommand("bot_add_t %s", "kyuubii");
			ServerCommand("bot_add_t %s", "kory");
			ServerCommand("bot_add_t %s", "Soulfly");
			ServerCommand("bot_add_t %s", "phzy");
			ServerCommand("mp_teamlogo_2 sang");
		}
	}
	
	if(strcmp(szTeamArg, "GenOne", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "wasiNk");
			ServerCommand("bot_add_ct %s", "NeOo");
			ServerCommand("bot_add_ct %s", "Nono2k");
			ServerCommand("bot_add_ct %s", "jeyN");
			ServerCommand("bot_add_ct %s", "SIXER");
			ServerCommand("mp_teamlogo_1 geno");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "wasiNk");
			ServerCommand("bot_add_t %s", "NeOo");
			ServerCommand("bot_add_t %s", "Nono2k");
			ServerCommand("bot_add_t %s", "jeyN");
			ServerCommand("bot_add_t %s", "SIXER");
			ServerCommand("mp_teamlogo_2 geno");
		}
	}
	
	if(strcmp(szTeamArg, "CatEvil", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "MrCANI");
			ServerCommand("bot_add_ct %s", "tanxiaomei");
			ServerCommand("bot_add_ct %s", "Gin");
			ServerCommand("bot_add_ct %s", "Chaos");
			ServerCommand("bot_add_ct %s", "Roninbaby");
			ServerCommand("mp_teamlogo_1 cat");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "MrCANI");
			ServerCommand("bot_add_t %s", "tanxiaomei");
			ServerCommand("bot_add_t %s", "Gin");
			ServerCommand("bot_add_t %s", "Chaos");
			ServerCommand("bot_add_t %s", "Roninbaby");
			ServerCommand("mp_teamlogo_2 cat");
		}
	}
	
	if(strcmp(szTeamArg, "Nouns", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "stamina");
			ServerCommand("bot_add_ct %s", "cynic");
			ServerCommand("bot_add_ct %s", "Bwills");
			ServerCommand("bot_add_ct %s", "nosraC");
			ServerCommand("bot_add_ct %s", "cJ");
			ServerCommand("mp_teamlogo_1 nouns");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "stamina");
			ServerCommand("bot_add_t %s", "cynic");
			ServerCommand("bot_add_t %s", "Bwills");
			ServerCommand("bot_add_t %s", "nosraC");
			ServerCommand("bot_add_t %s", "cJ");
			ServerCommand("mp_teamlogo_2 nouns");
		}
	}
	
	if(strcmp(szTeamArg, "Anonymo", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "oskarish");
			ServerCommand("bot_add_ct %s", "MWLKY");
			ServerCommand("bot_add_ct %s", "Demho");
			ServerCommand("bot_add_ct %s", "Vegi");
			ServerCommand("bot_add_ct %s", "innocent");
			ServerCommand("mp_teamlogo_1 anon");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "oskarish");
			ServerCommand("bot_add_t %s", "MWLKY");
			ServerCommand("bot_add_t %s", "Demho");
			ServerCommand("bot_add_t %s", "Vegi");
			ServerCommand("bot_add_t %s", "innocent");
			ServerCommand("mp_teamlogo_2 anon");
		}
	}
	
	if(strcmp(szTeamArg, "HONORIS", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "TaZ");
			ServerCommand("bot_add_ct %s", "SaMey");
			ServerCommand("bot_add_ct %s", "reiko");
			ServerCommand("bot_add_ct %s", "Sobol");
			ServerCommand("bot_add_ct %s", "lunAtic");
			ServerCommand("mp_teamlogo_1 hono");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "TaZ");
			ServerCommand("bot_add_t %s", "SaMey");
			ServerCommand("bot_add_t %s", "reiko");
			ServerCommand("bot_add_t %s", "Sobol");
			ServerCommand("bot_add_t %s", "lunAtic");
			ServerCommand("mp_teamlogo_2 hono");
		}
	}
	
	if(strcmp(szTeamArg, "Spirit", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "chopper");
			ServerCommand("bot_add_ct %s", "w0nderful");
			ServerCommand("bot_add_ct %s", "magixx");
			ServerCommand("bot_add_ct %s", "Patsi");
			ServerCommand("bot_add_ct %s", "s1ren");
			ServerCommand("mp_teamlogo_1 spir");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "chopper");
			ServerCommand("bot_add_t %s", "w0nderful");
			ServerCommand("bot_add_t %s", "magixx");
			ServerCommand("bot_add_t %s", "Patsi");
			ServerCommand("bot_add_t %s", "s1ren");
			ServerCommand("mp_teamlogo_2 spir");
		}
	}
	
	if(strcmp(szTeamArg, "DNMK", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Niix");
			ServerCommand("bot_add_ct %s", "Leggy");
			ServerCommand("bot_add_ct %s", "dyvo");
			ServerCommand("bot_add_ct %s", "zox");
			ServerCommand("bot_add_ct %s", "\"God's Not Dead\"");
			ServerCommand("mp_teamlogo_1 dnmk");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Niix");
			ServerCommand("bot_add_t %s", "Leggy");
			ServerCommand("bot_add_t %s", "dyvo");
			ServerCommand("bot_add_t %s", "zox");
			ServerCommand("bot_add_t %s", "\"God's Not Dead\"");
			ServerCommand("mp_teamlogo_2 dnkm");
		}
	}
	
	if(strcmp(szTeamArg, "iNation", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Dragon");
			ServerCommand("bot_add_ct %s", "VLDN");
			ServerCommand("bot_add_ct %s", "DEPRESHN");
			ServerCommand("bot_add_ct %s", "Kind0");
			ServerCommand("bot_add_ct %s", "choiv7");
			ServerCommand("mp_teamlogo_1 inat");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Dragon");
			ServerCommand("bot_add_t %s", "VLDN");
			ServerCommand("bot_add_t %s", "DEPRESHN");
			ServerCommand("bot_add_t %s", "Kind0");
			ServerCommand("bot_add_t %s", "choiv7");
			ServerCommand("mp_teamlogo_2 inat");
		}
	}
	
	if(strcmp(szTeamArg, "LEISURE", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "get");
			ServerCommand("bot_add_ct %s", "MpMurdock");
			ServerCommand("bot_add_ct %s", "neviZ");
			ServerCommand("bot_add_ct %s", "d1cer");
			ServerCommand("bot_add_ct %s", "gimpen");
			ServerCommand("mp_teamlogo_1 leis");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "get");
			ServerCommand("bot_add_t %s", "MpMurdock");
			ServerCommand("bot_add_t %s", "neviZ");
			ServerCommand("bot_add_t %s", "d1cer");
			ServerCommand("bot_add_t %s", "gimpen");
			ServerCommand("mp_teamlogo_2 leis");
		}
	}
	
	if(strcmp(szTeamArg, "Nation", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "coldzera");
			ServerCommand("bot_add_ct %s", "nqz");
			ServerCommand("bot_add_ct %s", "TACO");
			ServerCommand("bot_add_ct %s", "latto");
			ServerCommand("bot_add_ct %s", "dumau");
			ServerCommand("mp_teamlogo_1 zzn");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "coldzera");
			ServerCommand("bot_add_t %s", "nqz");
			ServerCommand("bot_add_t %s", "TACO");
			ServerCommand("bot_add_t %s", "latto");
			ServerCommand("bot_add_t %s", "dumau");
			ServerCommand("mp_teamlogo_2 zzn");
		}
	}
	
	if(strcmp(szTeamArg, "Strife", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "J0LZ");
			ServerCommand("bot_add_ct %s", "Snakes");
			ServerCommand("bot_add_ct %s", "Infinite");
			ServerCommand("bot_add_ct %s", "reck");
			ServerCommand("bot_add_ct %s", "aris");
			ServerCommand("mp_teamlogo_1 strife");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "J0LZ");
			ServerCommand("bot_add_t %s", "Snakes");
			ServerCommand("bot_add_t %s", "Infinite");
			ServerCommand("bot_add_t %s", "reck");
			ServerCommand("bot_add_t %s", "aris");
			ServerCommand("mp_teamlogo_2 strife");
		}
	}
	
	if(strcmp(szTeamArg, "777", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "SLY");
			ServerCommand("bot_add_ct %s", "Trax");
			ServerCommand("bot_add_ct %s", "mikki");
			ServerCommand("bot_add_ct %s", "akEz");
			ServerCommand("bot_add_ct %s", "PALM1");
			ServerCommand("mp_teamlogo_1 777");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "SLY");
			ServerCommand("bot_add_t %s", "Trax");
			ServerCommand("bot_add_t %s", "mikki");
			ServerCommand("bot_add_t %s", "akEz");
			ServerCommand("bot_add_t %s", "PALM1");
			ServerCommand("mp_teamlogo_2 777");
		}
	}
	
	if(strcmp(szTeamArg, "BLUEJAYS", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "aidKiT");
			ServerCommand("bot_add_ct %s", "kyxsan");
			ServerCommand("bot_add_ct %s", "stYleEeZ");
			ServerCommand("bot_add_ct %s", "dan1");
			ServerCommand("bot_add_ct %s", "CacaNito");
			ServerCommand("mp_teamlogo_1 bluej");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "aidKiT");
			ServerCommand("bot_add_t %s", "kyxsan");
			ServerCommand("bot_add_t %s", "stYleEeZ");
			ServerCommand("bot_add_t %s", "dan1");
			ServerCommand("bot_add_t %s", "CacaNito");
			ServerCommand("mp_teamlogo_2 bluej");
		}
	}
	
	if(strcmp(szTeamArg, "IKLA", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "byr9");
			ServerCommand("bot_add_ct %s", "SENSEi");
			ServerCommand("bot_add_ct %s", "Kvem");
			ServerCommand("bot_add_ct %s", "s4");
			ServerCommand("bot_add_ct %s", "j3kie");
			ServerCommand("mp_teamlogo_1 ikla");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "byr9");
			ServerCommand("bot_add_t %s", "SENSEi");
			ServerCommand("bot_add_t %s", "Kvem");
			ServerCommand("bot_add_t %s", "s4");
			ServerCommand("bot_add_t %s", "j3kie");
			ServerCommand("mp_teamlogo_2 ikla");
		}
	}
	
	if(strcmp(szTeamArg, "Conquer", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "jelo");
			ServerCommand("bot_add_ct %s", "Mikzuuu");
			ServerCommand("bot_add_ct %s", "Elfern");
			ServerCommand("bot_add_ct %s", "eDi");
			ServerCommand("bot_add_ct %s", "LYNXi");
			ServerCommand("mp_teamlogo_1 conq");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "jelo");
			ServerCommand("bot_add_t %s", "Mikzuuu");
			ServerCommand("bot_add_t %s", "Elfern");
			ServerCommand("bot_add_t %s", "eDi");
			ServerCommand("bot_add_t %s", "LYNXi");
			ServerCommand("mp_teamlogo_2 conq");
		}
	}
	
	if(strcmp(szTeamArg, "AVANGAR", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "sorrow");
			ServerCommand("bot_add_ct %s", "ICY");
			ServerCommand("bot_add_ct %s", "kade0");
			ServerCommand("bot_add_ct %s", "icem4N");
			ServerCommand("bot_add_ct %s", "w1nt3r");
			ServerCommand("mp_teamlogo_1 avg");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "sorrow");
			ServerCommand("bot_add_t %s", "ICY");
			ServerCommand("bot_add_t %s", "kade0");
			ServerCommand("bot_add_t %s", "icem4N");
			ServerCommand("bot_add_t %s", "w1nt3r");
			ServerCommand("mp_teamlogo_2 avg");
		}
	}
	
	if(strcmp(szTeamArg, "Furious", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "KAISER");
			ServerCommand("bot_add_ct %s", "peqexino");
			ServerCommand("bot_add_ct %s", "laser");
			ServerCommand("bot_add_ct %s", "andrew");
			ServerCommand("bot_add_ct %s", "ABM");
			ServerCommand("mp_teamlogo_1 fur");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "KAISER");
			ServerCommand("bot_add_t %s", "peqexino");
			ServerCommand("bot_add_t %s", "laser");
			ServerCommand("bot_add_t %s", "andrew");
			ServerCommand("bot_add_t %s", "ABM");
			ServerCommand("mp_teamlogo_2 fur");
		}
	}
	
	if(strcmp(szTeamArg, "Meta", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "CutzMeretz");
			ServerCommand("bot_add_ct %s", "supLex");
			ServerCommand("bot_add_ct %s", "Alisson");
			ServerCommand("bot_add_ct %s", "abr");
			ServerCommand("bot_add_ct %s", "dok");
			ServerCommand("mp_teamlogo_1 meta");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "CutzMeretz");
			ServerCommand("bot_add_t %s", "supLex");
			ServerCommand("bot_add_t %s", "Alisson");
			ServerCommand("bot_add_t %s", "abr");
			ServerCommand("bot_add_t %s", "dok");
			ServerCommand("mp_teamlogo_2 meta");
		}
	}
	
	if(strcmp(szTeamArg, "Dice", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "XpG");
			ServerCommand("bot_add_ct %s", "Gauthierlele");
			ServerCommand("bot_add_ct %s", "DEVIL");
			ServerCommand("bot_add_ct %s", "xReal");
			ServerCommand("bot_add_ct %s", "maeowo");
			ServerCommand("mp_teamlogo_1 dice");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "XpG");
			ServerCommand("bot_add_t %s", "Gauthierlele");
			ServerCommand("bot_add_t %s", "DEVIL");
			ServerCommand("bot_add_t %s", "xReal");
			ServerCommand("bot_add_t %s", "maeowo");
			ServerCommand("mp_teamlogo_2 dice");
		}
	}
	
	if(strcmp(szTeamArg, "Falcons", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "NBK-");
			ServerCommand("bot_add_ct %s", "kennyS");
			ServerCommand("bot_add_ct %s", "hAdji");
			ServerCommand("bot_add_ct %s", "misutaaa");
			ServerCommand("bot_add_ct %s", "Python");
			ServerCommand("mp_teamlogo_1 fal");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "NBK-");
			ServerCommand("bot_add_t %s", "kennyS");
			ServerCommand("bot_add_t %s", "hAdji");
			ServerCommand("bot_add_t %s", "misutaaa");
			ServerCommand("bot_add_t %s", "Python");
			ServerCommand("mp_teamlogo_2 fal");
		}
	}
	
	if(strcmp(szTeamArg, "Entropy", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "tahsiN");
			ServerCommand("bot_add_ct %s", "devraNN");
			ServerCommand("bot_add_ct %s", "rapala");
			ServerCommand("bot_add_ct %s", "mvN");
			ServerCommand("bot_add_ct %s", "LyNeX");
			ServerCommand("mp_teamlogo_1 entr");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "tahsiN");
			ServerCommand("bot_add_t %s", "devraNN");
			ServerCommand("bot_add_t %s", "rapala");
			ServerCommand("bot_add_t %s", "mvN");
			ServerCommand("bot_add_t %s", "LyNeX");
			ServerCommand("mp_teamlogo_2 entr");
		}
	}
	
	if(strcmp(szTeamArg, "Renewal", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "xerolte");
			ServerCommand("bot_add_ct %s", "Tugu");
			ServerCommand("bot_add_ct %s", "NEUZ");
			ServerCommand("bot_add_ct %s", "ROUX");
			ServerCommand("bot_add_ct %s", "ariucle");
			ServerCommand("mp_teamlogo_1 rene");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "xerolte");
			ServerCommand("bot_add_t %s", "Tugu");
			ServerCommand("bot_add_t %s", "NEUZ");
			ServerCommand("bot_add_t %s", "ROUX");
			ServerCommand("bot_add_t %s", "ariucle");
			ServerCommand("mp_teamlogo_2 rene");
		}
	}
	
	if(strcmp(szTeamArg, "500", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "SHiPZ");
			ServerCommand("bot_add_ct %s", "dennyslaw");
			ServerCommand("bot_add_ct %s", "Rainwaker");
			ServerCommand("bot_add_ct %s", "niki1");
			ServerCommand("bot_add_ct %s", "Patrick");
			ServerCommand("mp_teamlogo_1 500");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "SHiPZ");
			ServerCommand("bot_add_t %s", "dennyslaw");
			ServerCommand("bot_add_t %s", "Rainwaker");
			ServerCommand("bot_add_t %s", "niki1");
			ServerCommand("bot_add_t %s", "Patrick");
			ServerCommand("mp_teamlogo_2 500");
		}
	}
	
	if(strcmp(szTeamArg, "BP", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "fleav");
			ServerCommand("bot_add_ct %s", "Chill");
			ServerCommand("bot_add_ct %s", "Aaron");
			ServerCommand("bot_add_ct %s", "EspiranTo");
			ServerCommand("bot_add_ct %s", "keen");
			ServerCommand("mp_teamlogo_1 bp");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "fleav");
			ServerCommand("bot_add_t %s", "Chill");
			ServerCommand("bot_add_t %s", "Aaron");
			ServerCommand("bot_add_t %s", "EspiranTo");
			ServerCommand("bot_add_t %s", "keen");
			ServerCommand("mp_teamlogo_2 bp");
		}
	}
	
	if(strcmp(szTeamArg, "Rooster", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "asap");
			ServerCommand("bot_add_ct %s", "ADK");
			ServerCommand("bot_add_ct %s", "nettik");
			ServerCommand("bot_add_ct %s", "chelleos");
			ServerCommand("bot_add_ct %s", "Rackem");
			ServerCommand("mp_teamlogo_1 roos");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "asap");
			ServerCommand("bot_add_t %s", "ADK");
			ServerCommand("bot_add_t %s", "nettik");
			ServerCommand("bot_add_t %s", "chelleos");
			ServerCommand("bot_add_t %s", "Rackem");
			ServerCommand("mp_teamlogo_2 roos");
		}
	}
	
	if(strcmp(szTeamArg, "HEET", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "JACKZ");
			ServerCommand("bot_add_ct %s", "afro");
			ServerCommand("bot_add_ct %s", "bodyy");
			ServerCommand("bot_add_ct %s", "Djoko");
			ServerCommand("bot_add_ct %s", "Ex3rcice");
			ServerCommand("mp_teamlogo_1 heet");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "JACKZ");
			ServerCommand("bot_add_t %s", "afro");
			ServerCommand("bot_add_t %s", "bodyy");
			ServerCommand("bot_add_t %s", "Djoko");
			ServerCommand("bot_add_t %s", "Ex3rcice");
			ServerCommand("mp_teamlogo_2 heet");
		}
	}
	
	if(strcmp(szTeamArg, "LDLC", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Graviti");
			ServerCommand("bot_add_ct %s", "Broox");
			ServerCommand("bot_add_ct %s", "AMANEK");
			ServerCommand("bot_add_ct %s", "Diviiii");
			ServerCommand("bot_add_ct %s", "Snobling");
			ServerCommand("mp_teamlogo_1 ldlc");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Graviti");
			ServerCommand("bot_add_t %s", "Broox");
			ServerCommand("bot_add_t %s", "AMANEK");
			ServerCommand("bot_add_t %s", "Diviiii");
			ServerCommand("bot_add_t %s", "Snobling");
			ServerCommand("mp_teamlogo_2 ldlc");
		}
	}
	
	if(strcmp(szTeamArg, "Vireo", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Fur_Daddy");
			ServerCommand("bot_add_ct %s", "emokie");
			ServerCommand("bot_add_ct %s", "Champ");
			ServerCommand("bot_add_ct %s", "KRL");
			ServerCommand("bot_add_ct %s", "drayza");
			ServerCommand("mp_teamlogo_1 vireo");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Fur_Daddy");
			ServerCommand("bot_add_t %s", "emokie");
			ServerCommand("bot_add_t %s", "Champ");
			ServerCommand("bot_add_t %s", "KRL");
			ServerCommand("bot_add_t %s", "drayza");
			ServerCommand("mp_teamlogo_2 vireo");
		}
	}
	
	if(strcmp(szTeamArg, "Imperial", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "fer");
			ServerCommand("bot_add_ct %s", "FalleN");
			ServerCommand("bot_add_ct %s", "chelo");
			ServerCommand("bot_add_ct %s", "boltz");
			ServerCommand("bot_add_ct %s", "VINI");
			ServerCommand("mp_teamlogo_1 imp");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "fer");
			ServerCommand("bot_add_t %s", "FalleN");
			ServerCommand("bot_add_t %s", "chelo");
			ServerCommand("bot_add_t %s", "boltz");
			ServerCommand("bot_add_t %s", "VINI");
			ServerCommand("mp_teamlogo_2 imp");
		}
	}
	
	if(strcmp(szTeamArg, "EYEBALLERS", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "flusha");
			ServerCommand("bot_add_ct %s", "JW");
			ServerCommand("bot_add_ct %s", "Sapec");
			ServerCommand("bot_add_ct %s", "SHiNE");
			ServerCommand("bot_add_ct %s", "Peppzor");
			ServerCommand("mp_teamlogo_1 eye");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "flusha");
			ServerCommand("bot_add_t %s", "JW");
			ServerCommand("bot_add_t %s", "Sapec");
			ServerCommand("bot_add_t %s", "SHiNE");
			ServerCommand("bot_add_t %s", "Peppzor");
			ServerCommand("mp_teamlogo_2 eye");
		}
	}
	
	if(strcmp(szTeamArg, "mCon", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Jins");
			ServerCommand("bot_add_ct %s", "AdamJC");
			ServerCommand("bot_add_ct %s", "NiNo");
			ServerCommand("bot_add_ct %s", "ve1nzo");
			ServerCommand("bot_add_ct %s", "vKEMPeN");
			ServerCommand("mp_teamlogo_1 mcon");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Jins");
			ServerCommand("bot_add_t %s", "AdamJC");
			ServerCommand("bot_add_t %s", "NiNo");
			ServerCommand("bot_add_t %s", "ve1nzo");
			ServerCommand("bot_add_t %s", "vKEMPeN");
			ServerCommand("mp_teamlogo_2 mcon");
		}
	}
	
	if(strcmp(szTeamArg, "Encore", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "HaZR");
			ServerCommand("bot_add_ct %s", "sterling");
			ServerCommand("bot_add_ct %s", "Liki");
			ServerCommand("bot_add_ct %s", "SaVage");
			ServerCommand("bot_add_ct %s", "apoc");
			ServerCommand("mp_teamlogo_1 enco");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "HaZR");
			ServerCommand("bot_add_t %s", "sterling");
			ServerCommand("bot_add_t %s", "Liki");
			ServerCommand("bot_add_t %s", "SaVage");
			ServerCommand("bot_add_t %s", "apoc");
			ServerCommand("mp_teamlogo_2 enco");
		}
	}
	
	if(strcmp(szTeamArg, "NKT", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "XigN");
			ServerCommand("bot_add_ct %s", "nin9");
			ServerCommand("bot_add_ct %s", "Senzu");
			ServerCommand("bot_add_ct %s", "BnTeT");
			ServerCommand("bot_add_ct %s", "erkaSt");
			ServerCommand("mp_teamlogo_1 nkt");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "XigN");
			ServerCommand("bot_add_t %s", "nin9");
			ServerCommand("bot_add_t %s", "Senzu");
			ServerCommand("bot_add_t %s", "BnTeT");
			ServerCommand("bot_add_t %s", "erkaSt");
			ServerCommand("mp_teamlogo_2 nkt");
		}
	}
	
	if(strcmp(szTeamArg, "Boca", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "lenci");
			ServerCommand("bot_add_ct %s", "elemeNt");
			ServerCommand("bot_add_ct %s", "alexer");
			ServerCommand("bot_add_ct %s", "Hezz");
			ServerCommand("bot_add_ct %s", "MRN1");
			ServerCommand("mp_teamlogo_1 boca");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "lenci");
			ServerCommand("bot_add_t %s", "elemeNt");
			ServerCommand("bot_add_t %s", "alexer");
			ServerCommand("bot_add_t %s", "Hezz");
			ServerCommand("bot_add_t %s", "MRN1");
			ServerCommand("mp_teamlogo_2 boca");
		}
	}
	
	if(strcmp(szTeamArg, "Sampi", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "HONES");
			ServerCommand("bot_add_ct %s", "Habyzz");
			ServerCommand("bot_add_ct %s", "matys");
			ServerCommand("bot_add_ct %s", "sAvana1");
			ServerCommand("bot_add_ct %s", "T4gg3D");
			ServerCommand("mp_teamlogo_1 samp");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "HONES");
			ServerCommand("bot_add_t %s", "Habyzz");
			ServerCommand("bot_add_t %s", "matys");
			ServerCommand("bot_add_t %s", "sAvana1");
			ServerCommand("bot_add_t %s", "T4gg3D");
			ServerCommand("mp_teamlogo_2 samp");
		}
	}
	
	if(strcmp(szTeamArg, "Ungentium", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Sidney");
			ServerCommand("bot_add_ct %s", "m4tthi");
			ServerCommand("bot_add_ct %s", "Prism");
			ServerCommand("bot_add_ct %s", "GruBy");
			ServerCommand("bot_add_ct %s", "ponczek");
			ServerCommand("mp_teamlogo_1 unge");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Sidney");
			ServerCommand("bot_add_t %s", "m4tthi");
			ServerCommand("bot_add_t %s", "Prism");
			ServerCommand("bot_add_t %s", "GruBy");
			ServerCommand("bot_add_t %s", "ponczek");
			ServerCommand("mp_teamlogo_2 unge");
		}
	}
	
	if(strcmp(szTeamArg, "MASONIC", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "kiR");
			ServerCommand("bot_add_ct %s", "J3nsyy");
			ServerCommand("bot_add_ct %s", "Anlelele");
			ServerCommand("bot_add_ct %s", "Tauson");
			ServerCommand("bot_add_ct %s", "vester");
			ServerCommand("mp_teamlogo_1 maso");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "kiR");
			ServerCommand("bot_add_t %s", "J3nsyy");
			ServerCommand("bot_add_t %s", "Anlelele");
			ServerCommand("bot_add_t %s", "Tauson");
			ServerCommand("bot_add_t %s", "vester");
			ServerCommand("mp_teamlogo_2 maso");
		}
	}
	
	if(strcmp(szTeamArg, "Paqueta", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "DeStiNy");
			ServerCommand("bot_add_ct %s", "Gafolo");
			ServerCommand("bot_add_ct %s", "venomzera");
			ServerCommand("bot_add_ct %s", "xns");
			ServerCommand("bot_add_ct %s", "ALLE");
			ServerCommand("mp_teamlogo_1 paq");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "DeStiNy");
			ServerCommand("bot_add_t %s", "Gafolo");
			ServerCommand("bot_add_t %s", "venomzera");
			ServerCommand("bot_add_t %s", "xns");
			ServerCommand("bot_add_t %s", "ALLE");
			ServerCommand("mp_teamlogo_2 paq");
		}
	}
	
	if(strcmp(szTeamArg, "Plano", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "decenty");
			ServerCommand("bot_add_ct %s", "kNgV-");
			ServerCommand("bot_add_ct %s", "caike");
			ServerCommand("bot_add_ct %s", "piria");
			ServerCommand("bot_add_ct %s", "NEKIZ");
			ServerCommand("mp_teamlogo_1 plan");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "decenty");
			ServerCommand("bot_add_t %s", "kNgV-");
			ServerCommand("bot_add_t %s", "caike");
			ServerCommand("bot_add_t %s", "piria");
			ServerCommand("bot_add_t %s", "NEKIZ");
			ServerCommand("mp_teamlogo_2 plan");
		}
	}
	
	if(strcmp(szTeamArg, "GTZ", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Jaepe");
			ServerCommand("bot_add_ct %s", "shr");
			ServerCommand("bot_add_ct %s", "snapy");
			ServerCommand("bot_add_ct %s", "aragorN");
			ServerCommand("bot_add_ct %s", "Icarus");
			ServerCommand("mp_teamlogo_1 gtz");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Jaepe");
			ServerCommand("bot_add_t %s", "shr");
			ServerCommand("bot_add_t %s", "snapy");
			ServerCommand("bot_add_t %s", "aragorN");
			ServerCommand("bot_add_t %s", "Icarus");
			ServerCommand("mp_teamlogo_2 gtz");
		}
	}
	
	if(strcmp(szTeamArg, "Alpha", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "mupzG");
			ServerCommand("bot_add_ct %s", "Twinx");
			ServerCommand("bot_add_ct %s", "smF");
			ServerCommand("bot_add_ct %s", "Basso");
			ServerCommand("bot_add_ct %s", "Gnøffe");
			ServerCommand("mp_teamlogo_1 alpha");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "mupzG");
			ServerCommand("bot_add_t %s", "Twinx");
			ServerCommand("bot_add_t %s", "smF");
			ServerCommand("bot_add_t %s", "Basso");
			ServerCommand("bot_add_t %s", "Gnøffe");
			ServerCommand("mp_teamlogo_2 alpha");
		}
	}
	
	if(strcmp(szTeamArg, "Fluxo", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "felps");
			ServerCommand("bot_add_ct %s", "WOOD7");
			ServerCommand("bot_add_ct %s", "Lucaozy");
			ServerCommand("bot_add_ct %s", "lux");
			ServerCommand("bot_add_ct %s", "v$m");
			ServerCommand("mp_teamlogo_1 fluxo");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "felps");
			ServerCommand("bot_add_t %s", "WOOD7");
			ServerCommand("bot_add_t %s", "Lucaozy");
			ServerCommand("bot_add_t %s", "lux");
			ServerCommand("bot_add_t %s", "v$m");
			ServerCommand("mp_teamlogo_2 fluxo");
		}
	}
	
	if(strcmp(szTeamArg, "Eruption", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "dobu");
			ServerCommand("bot_add_ct %s", "cool4st");
			ServerCommand("bot_add_ct %s", "fury5k");
			ServerCommand("bot_add_ct %s", "Shinobi");
			ServerCommand("bot_add_ct %s", "yAmi");
			ServerCommand("mp_teamlogo_1 erup");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "dobu");
			ServerCommand("bot_add_t %s", "cool4st");
			ServerCommand("bot_add_t %s", "fury5k");
			ServerCommand("bot_add_t %s", "Shinobi");
			ServerCommand("bot_add_t %s", "yAmi");
			ServerCommand("mp_teamlogo_2 erup");
		}
	}
	
	if(strcmp(szTeamArg, "DUSTY", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "EddezeNNN");
			ServerCommand("bot_add_ct %s", "TH0R");
			ServerCommand("bot_add_ct %s", "pallib0ndi");
			ServerCommand("bot_add_ct %s", "detinate");
			ServerCommand("bot_add_ct %s", "StebbiC0C0");
			ServerCommand("mp_teamlogo_1 dust");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "EddezeNNN");
			ServerCommand("bot_add_t %s", "TH0R");
			ServerCommand("bot_add_t %s", "pallib0ndi");
			ServerCommand("bot_add_t %s", "detinate");
			ServerCommand("bot_add_t %s", "StebbiC0C0");
			ServerCommand("mp_teamlogo_2 dust");
		}
	}
	
	if(strcmp(szTeamArg, "Nixuh", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "adM");
			ServerCommand("bot_add_ct %s", "blackpoisoN");
			ServerCommand("bot_add_ct %s", "kanii");
			ServerCommand("bot_add_ct %s", "Triton");
			ServerCommand("bot_add_ct %s", "Sonic");
			ServerCommand("mp_teamlogo_1 nix");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "adM");
			ServerCommand("bot_add_t %s", "blackpoisoN");
			ServerCommand("bot_add_t %s", "kanii");
			ServerCommand("bot_add_t %s", "Triton");
			ServerCommand("bot_add_t %s", "Sonic");
			ServerCommand("mp_teamlogo_2 nix");
		}
	}
	
	if(strcmp(szTeamArg, "INTZ", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "Leomonster");
			ServerCommand("bot_add_ct %s", "desh");
			ServerCommand("bot_add_ct %s", "BobZ");
			ServerCommand("bot_add_ct %s", "TEKO");
			ServerCommand("bot_add_ct %s", "w1");
			ServerCommand("mp_teamlogo_1 intz");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "Leomonster");
			ServerCommand("bot_add_t %s", "desh");
			ServerCommand("bot_add_t %s", "BobZ");
			ServerCommand("bot_add_t %s", "TEKO");
			ServerCommand("bot_add_t %s", "w1");
			ServerCommand("mp_teamlogo_2 intz");
		}
	}
	
	if(strcmp(szTeamArg, "Arctic", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "MaLLby");
			ServerCommand("bot_add_ct %s", "history");
			ServerCommand("bot_add_ct %s", "ninjaZ");
			ServerCommand("bot_add_ct %s", "short");
			ServerCommand("bot_add_ct %s", "ponter");
			ServerCommand("mp_teamlogo_1 arct");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "MaLLby");
			ServerCommand("bot_add_t %s", "history");
			ServerCommand("bot_add_t %s", "ninjaZ");
			ServerCommand("bot_add_t %s", "short");
			ServerCommand("bot_add_t %s", "ponter");
			ServerCommand("mp_teamlogo_2 arct");
		}
	}
	
	if(strcmp(szTeamArg, "ODDIK", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "naitte");
			ServerCommand("bot_add_ct %s", "remix");
			ServerCommand("bot_add_ct %s", "RICIOLI");
			ServerCommand("bot_add_ct %s", "vLa");
			ServerCommand("bot_add_ct %s", "r1see");
			ServerCommand("mp_teamlogo_1 odd");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "naitte");
			ServerCommand("bot_add_t %s", "remix");
			ServerCommand("bot_add_t %s", "RICIOLI");
			ServerCommand("bot_add_t %s", "vLa");
			ServerCommand("bot_add_t %s", "r1see");
			ServerCommand("mp_teamlogo_2 odd");
		}
	}
	
	if(strcmp(szTeamArg, "River", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "maxxkor");
			ServerCommand("bot_add_ct %s", "gishu");
			ServerCommand("bot_add_ct %s", "awoken");
			ServerCommand("bot_add_ct %s", "gonza");
			ServerCommand("bot_add_ct %s", "rushardo");
			ServerCommand("mp_teamlogo_1 rive");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "maxxkor");
			ServerCommand("bot_add_t %s", "gishu");
			ServerCommand("bot_add_t %s", "awoken");
			ServerCommand("bot_add_t %s", "gonza");
			ServerCommand("bot_add_t %s", "rushardo");
			ServerCommand("mp_teamlogo_2 rive");
		}
	}
	
	if(strcmp(szTeamArg, "GameAgents", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "kANDARO");
			ServerCommand("bot_add_ct %s", "Vopsick");
			ServerCommand("bot_add_ct %s", "SasukeQO");
			ServerCommand("bot_add_ct %s", "Akv1lon");
			ServerCommand("bot_add_ct %s", "ZetBest");
			ServerCommand("mp_teamlogo_1 game");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "kANDARO");
			ServerCommand("bot_add_t %s", "Vopsick");
			ServerCommand("bot_add_t %s", "SasukeQO");
			ServerCommand("bot_add_t %s", "Akv1lon");
			ServerCommand("bot_add_t %s", "ZetBest");
			ServerCommand("mp_teamlogo_2 game");
		}
	}
	
	if(strcmp(szTeamArg, "BLINK", false) == 0)
	{
		if (strcmp(szSideArg, "ct", false) == 0)
		{
			ServerCommand("bot_kick ct all");
			ServerCommand("bot_add_ct %s", "gulito");
			ServerCommand("bot_add_ct %s", "BledarD");
			ServerCommand("bot_add_ct %s", "deb0");
			ServerCommand("bot_add_ct %s", "Krabeni");
			ServerCommand("bot_add_ct %s", "HYPER1");
			ServerCommand("mp_teamlogo_1 blin");
		}
		
		if (strcmp(szSideArg, "t", false) == 0)
		{
			ServerCommand("bot_kick t all");
			ServerCommand("bot_add_t %s", "gulito");
			ServerCommand("bot_add_t %s", "BledarD");
			ServerCommand("bot_add_t %s", "deb0");
			ServerCommand("bot_add_t %s", "Krabeni");
			ServerCommand("bot_add_t %s", "HYPER1");
			ServerCommand("mp_teamlogo_2 blin");
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
	
	g_bIsBombScenario = IsValidEntity(FindEntityByClassname(-1, "func_bomb_target")) ? true : false;
	g_bIsHostageScenario = IsValidEntity(FindEntityByClassname(-1, "func_hostage_rescue")) ? true : false;
	
	CreateTimer(1.0, Timer_CheckPlayer, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(0.1, Timer_CheckPlayerFast, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
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
			
			if (IsItMyChance(1.0))
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
					int iRndPistol = Math_GetRandomInt(1, 6);
					
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
			
			if (iAccount < g_cvBotEcoLimit.IntValue && !IsValidEntity(iPrimary))
			{
				if(GetClientTeam(i) == CS_TEAM_T)
					g_bTerroristEco = true;
			}
			
			if (g_iCurrentRound == 0 || g_iCurrentRound == 15)
			{
				if(IsItMyChance(2.0))
					FakeClientCommand(i, "buy %s", (iTeam == CS_TEAM_CT) ? "elite" : "vest");
				else if(IsItMyChance(30.0))
					FakeClientCommand(i, "buy %s", (iTeam == CS_TEAM_CT) ? "defuser" : "p250");
				else if(IsItMyChance(60.0))
					FakeClientCommand(i, "buy vest");
				
				g_bTerroristEco = false;
			}
		}
	}
	
	return Plugin_Continue;
}

public Action Timer_CheckPlayerFast(Handle hTimer, any data)
{
	g_bBombPlanted = !!GameRules_GetProp("m_bBombPlanted");

	for (int client = 1; client <= MaxClients; client++)
	{
		if (IsValidClient(client) && IsFakeClient(client) && IsPlayerAlive(client))
		{
			int iActiveWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
			if (iActiveWeapon == -1) return Plugin_Continue;
			
			float fClientLoc[3], fClientEyes[3];
			GetClientAbsOrigin(client, fClientLoc);
			GetClientEyePosition(client, fClientEyes);
			g_pCurrArea[client] = NavMesh_GetNearestArea(fClientLoc);
			
			if ((GetAliveTeamCount(CS_TEAM_T) == 0 || GetAliveTeamCount(CS_TEAM_CT) == 0) && !g_bDontSwitch[client])
			{
				SDKCall(g_hSwitchWeaponCall, client, GetPlayerWeaponSlot(client, CS_SLOT_KNIFE), 0);
				g_bEveryoneDead = true;
			}
			
			if (BotMimic_IsPlayerMimicing(client) && ((GetClientTeam(client) == CS_TEAM_T && GetAliveTeamCount(CS_TEAM_T) <= 3 && GetAliveTeamCount(CS_TEAM_CT) > 0) || g_bAbortExecute))
				BotMimic_StopPlayerMimic(client);
				
			if(g_bFreezetimeEnd && IsItMyChance(15.0) && g_iDoingSmokeNum[client] == -1 && !g_bBombPlanted)
				g_iDoingSmokeNum[client] = GetNearestGrenade(client);
			
			if (g_bIsProBot[client])
			{				
				if(g_bBombPlanted)
				{
					int iPlantedC4 = -1;
					iPlantedC4 = FindEntityByClassname(iPlantedC4, "planted_c4");
					
					if (IsValidEntity(iPlantedC4) && GetClientTeam(client) == CS_TEAM_CT)
					{
						float fPlantedC4Location[3];
						GetEntPropVector(iPlantedC4, Prop_Send, "m_vecOrigin", fPlantedC4Location);
						
						float fPlantedC4Distance;
						
						fPlantedC4Distance = GetVectorDistance(fClientLoc, fPlantedC4Location);
						
						if (((GetAliveTeamCount(CS_TEAM_T) == 0 && GetAliveTeamCount(CS_TEAM_CT) == 1 && fPlantedC4Distance > 100.0 && GetTask(client) != ESCAPE_FROM_BOMB) || fPlantedC4Distance > 2000.0) && GetEntData(client, g_iBotNearbyEnemiesOffset) == 0 && !g_bDontSwitch[client])
						{
							SDKCall(g_hSwitchWeaponCall, client, GetPlayerWeaponSlot(client, CS_SLOT_KNIFE), 0);
							BotMoveTo(client, fPlantedC4Location, FASTEST_ROUTE);
						}
					}
				}
				
				int iDroppedC4 = GetNearestEntity(client, "weapon_c4", false);
				
				if (g_bFreezetimeEnd && !g_bBombPlanted && !IsValidEntity(iDroppedC4) && !BotIsHiding(client) && !BotMimic_IsPlayerMimicing(client))
				{
					//Rifles
					int iAK47 = GetNearestEntity(client, "weapon_ak47");
					int iM4A1 = GetNearestEntity(client, "weapon_m4a1");
					int iPrimary = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
					int iPrimaryDefIndex;

					if (IsValidEntity(iAK47))
					{
						float fAK47Location[3];

						iPrimaryDefIndex = IsValidEntity(iPrimary) ? GetEntProp(iPrimary, Prop_Send, "m_iItemDefinitionIndex") : 0;

						if ((iPrimaryDefIndex != 7 && iPrimaryDefIndex != 9) || iPrimary == -1)
						{
							GetEntPropVector(iAK47, Prop_Send, "m_vecOrigin", fAK47Location);

							if (GetVectorLength(fAK47Location) > 0.0)
								BotMoveTo(client, fAK47Location, FASTEST_ROUTE);
						}
					}
					else if (IsValidEntity(iM4A1))
					{
						float fM4A1Location[3];

						iPrimaryDefIndex = IsValidEntity(iPrimary) ? GetEntProp(iPrimary, Prop_Send, "m_iItemDefinitionIndex") : 0;

						if (iPrimaryDefIndex != 7 && iPrimaryDefIndex != 9 && iPrimaryDefIndex != 16 && iPrimaryDefIndex != 60)
						{
							GetEntPropVector(iM4A1, Prop_Send, "m_vecOrigin", fM4A1Location);

							if (GetVectorLength(fM4A1Location) > 0.0)
							{
								BotMoveTo(client, fM4A1Location, FASTEST_ROUTE);

								if (GetVectorDistance(fClientLoc, fM4A1Location) < 50.0 && GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY) != -1)
									CS_DropWeapon(client, GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY), false);
							}
						}
						else if (iPrimary == -1)
						{
							GetEntPropVector(iM4A1, Prop_Send, "m_vecOrigin", fM4A1Location);

							if (GetVectorLength(fM4A1Location) > 0.0)
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
						float fDeagleLocation[3];
						
						iSecondaryDefIndex = IsValidEntity(iSecondary) ? GetEntProp(iSecondary, Prop_Send, "m_iItemDefinitionIndex") : 0;
						
						if (iSecondaryDefIndex == 4 || iSecondaryDefIndex == 32 || iSecondaryDefIndex == 61 || iSecondaryDefIndex == 36 || iSecondaryDefIndex == 30 || iSecondaryDefIndex == 3 || iSecondaryDefIndex == 63)
						{
							GetEntPropVector(iDeagle, Prop_Send, "m_vecOrigin", fDeagleLocation);
							
							if (GetVectorLength(fDeagleLocation) > 0.0)
							{
								BotMoveTo(client, fDeagleLocation, FASTEST_ROUTE);
								
								if (GetVectorDistance(fClientLoc, fDeagleLocation) < 50.0 && GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY) != -1)
									CS_DropWeapon(client, GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY), false);
							}
						}
					}
					else if (IsValidEntity(iTec9))
					{
						float fTec9Location[3];
						
						iSecondaryDefIndex = IsValidEntity(iSecondary) ? GetEntProp(iSecondary, Prop_Send, "m_iItemDefinitionIndex") : 0;
						
						if (iSecondaryDefIndex == 4 || iSecondaryDefIndex == 32 || iSecondaryDefIndex == 61 || iSecondaryDefIndex == 36)
						{
							GetEntPropVector(iTec9, Prop_Send, "m_vecOrigin", fTec9Location);
							
							if (GetVectorLength(fTec9Location) > 0.0)
							{
								BotMoveTo(client, fTec9Location, FASTEST_ROUTE);
								
								if (GetVectorDistance(fClientLoc, fTec9Location) < 50.0 && GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY) != -1)
									CS_DropWeapon(client, GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY), false);
							}
						}
					}
					else if (IsValidEntity(iFiveSeven))
					{
						float fFiveSevenLocation[3];
						
						iSecondaryDefIndex = IsValidEntity(iSecondary) ? GetEntProp(iSecondary, Prop_Send, "m_iItemDefinitionIndex") : 0;
						
						if (iSecondaryDefIndex == 4 || iSecondaryDefIndex == 32 || iSecondaryDefIndex == 61 || iSecondaryDefIndex == 36)
						{
							GetEntPropVector(iFiveSeven, Prop_Send, "m_vecOrigin", fFiveSevenLocation);
							
							if (GetVectorLength(fFiveSevenLocation) > 0.0)
							{
								BotMoveTo(client, fFiveSevenLocation, FASTEST_ROUTE);
								
								if (GetVectorDistance(fClientLoc, fFiveSevenLocation) < 50.0 && GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY) != -1)
									CS_DropWeapon(client, GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY), false);
							}
						}
					}
					else if (IsValidEntity(iP250))
					{
						float fP250Location[3];
						
						iSecondaryDefIndex = IsValidEntity(iSecondary) ? GetEntProp(iSecondary, Prop_Send, "m_iItemDefinitionIndex") : 0;
						
						if (iSecondaryDefIndex == 4 || iSecondaryDefIndex == 32 || iSecondaryDefIndex == 61)
						{
							GetEntPropVector(iP250, Prop_Send, "m_vecOrigin", fP250Location);
							
							if (GetVectorLength(fP250Location) > 0.0)
							{
								BotMoveTo(client, fP250Location, FASTEST_ROUTE);
								
								if (GetVectorDistance(fClientLoc, fP250Location) < 50.0 && GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY) != -1)
									CS_DropWeapon(client, GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY), false);
							}
						}
					}
					else if (IsValidEntity(iUSP))
					{
						float fUSPLocation[3];
						
						iSecondaryDefIndex = IsValidEntity(iSecondary) ? GetEntProp(iSecondary, Prop_Send, "m_iItemDefinitionIndex") : 0;
						
						if (iSecondaryDefIndex == 4)
						{
							GetEntPropVector(iUSP, Prop_Send, "m_vecOrigin", fUSPLocation);
							
							if (GetVectorLength(fUSPLocation) > 0.0)
							{
								BotMoveTo(client, fUSPLocation, FASTEST_ROUTE);
								
								if (GetVectorDistance(fClientLoc, fUSPLocation) < 50.0 && GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY) != -1)
									CS_DropWeapon(client, GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY), false);
							}
						}
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
		char szClanTag[MAX_NAME_LENGTH];
		
		GetClientName(client, szBotName, sizeof(szBotName));
		g_bIsProBot[client] = false;
		
		if(IsProBot(szBotName, szClanTag))
		{
			if(strcmp(szBotName, "s1mple") == 0 || strcmp(szBotName, "ZywOo") == 0 || strcmp(szBotName, "NiKo") == 0)
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
		
		SDKHook(client, SDKHook_OnTakeDamageAlive, OnTakeDamageAlive);
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
	g_bAbortExecute = false;
	g_bTerroristEco = false;
	g_bEveryoneDead = false;
	g_fRoundStart = GetGameTime();
	g_iRndExecute = -1;
	
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
			g_iDoingSmokeNum[i] = -1;
			g_fZoomedTimestamp[i] = 0.0;
				
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
	
	g_iRoundsPlayed = g_iCTScore + g_iTScore;
	
	for(int i = 0; i < g_iMaxNades; i++)
	{
		if(g_ArrayNades[i] == null)
			return;
			
		g_ArrayNades[i].Set(5, 0.0);
	}
}

public void OnFreezetimeEnd(Event eEvent, char[] szName, bool bDontBroadcast)
{
	g_bFreezetimeEnd = true;
	g_fFreezeTimeEnd = GetGameTime();
	bool bWarmupPeriod = !!GameRules_GetProp("m_bWarmupPeriod");
	
	if(bWarmupPeriod || g_bTerroristEco || HumansOnTeam(CS_TEAM_T) > 0)
		return;
	
	if(IsItMyChance(60.0))
	{
		if (strcmp(g_szMap, "de_mirage") == 0)
		{
			g_iRndExecute = (g_iCurrentRound == 0 || g_iCurrentRound == 15) ? Math_GetRandomInt(1, 3) : Math_GetRandomInt(1, 21);
			LogMessage("BOT STUFF: %s selected execute for Round %i: %i", g_szMap, g_iCurrentRound, g_iRndExecute);
			PrepareMirageExecutes();
		}
		else if (strcmp(g_szMap, "de_dust2") == 0 || strcmp(g_szMap, "de_dust2_halloween") == 0)
		{
			g_iRndExecute = (g_iCurrentRound == 0 || g_iCurrentRound == 15) ? Math_GetRandomInt(1, 1) : Math_GetRandomInt(1, 11);
			LogMessage("BOT STUFF: %s selected execute for Round %i: %i", g_szMap, g_iCurrentRound, g_iRndExecute);
			PrepareDust2Executes();
		}
		else if (strcmp(g_szMap, "de_inferno") == 0 || strcmp(g_szMap, "de_inferno_night") == 0 || strcmp(g_szMap, "de_infernohr_night") == 0)
		{
			g_iRndExecute = (g_iCurrentRound == 0 || g_iCurrentRound == 15) ? Math_GetRandomInt(1, 7) : Math_GetRandomInt(1, 15);
			LogMessage("BOT STUFF: %s selected execute for Round %i: %i", g_szMap, g_iCurrentRound, g_iRndExecute);
			PrepareInfernoExecutes();
		}
		else if (strcmp(g_szMap, "de_overpass") == 0)
		{
			g_iRndExecute = (g_iCurrentRound == 0 || g_iCurrentRound == 15) ? Math_GetRandomInt(1, 1) : Math_GetRandomInt(1, 9);
			LogMessage("BOT STUFF: %s selected execute for Round %i: %i", g_szMap, g_iCurrentRound, g_iRndExecute);
			PrepareOverpassExecutes();
		}
		else if (strcmp(g_szMap, "de_train") == 0)
		{
			g_iRndExecute = (g_iCurrentRound == 0 || g_iCurrentRound == 15) ? -1 : Math_GetRandomInt(1, 2);
			LogMessage("BOT STUFF: %s selected execute for Round %i: %i", g_szMap, g_iCurrentRound, g_iRndExecute);
			PrepareTrainExecutes();
		}
		else if (strcmp(g_szMap, "de_nuke") == 0)
		{
			g_iRndExecute = (g_iCurrentRound == 0 || g_iCurrentRound == 15) ? -1 : Math_GetRandomInt(1, 2);
			LogMessage("BOT STUFF: %s selected execute for Round %i: %i", g_szMap, g_iCurrentRound, g_iRndExecute);
			PrepareNukeExecutes();
		}
		else if (strcmp(g_szMap, "de_vertigo") == 0)
		{
			g_iRndExecute = (g_iCurrentRound == 0 || g_iCurrentRound == 15) ? Math_GetRandomInt(1, 6) : Math_GetRandomInt(1, 5);
			LogMessage("BOT STUFF: %s selected execute for Round %i: %i", g_szMap, g_iCurrentRound, g_iRndExecute);
			PrepareVertigoExecutes();
		}
		else if (strcmp(g_szMap, "de_cache") == 0)
		{
			g_iRndExecute = (g_iCurrentRound == 0 || g_iCurrentRound == 15) ? -1 : Math_GetRandomInt(1, 3);
			LogMessage("BOT STUFF: %s selected execute for Round %i: %i", g_szMap, g_iCurrentRound, g_iRndExecute);
			PrepareCacheExecutes();
		}
		else if (strcmp(g_szMap, "de_ancient") == 0)
		{
			g_iRndExecute = (g_iCurrentRound == 0 || g_iCurrentRound == 15) ? -1 : Math_GetRandomInt(1, 3);
			LogMessage("BOT STUFF: %s selected execute for Round %i: %i", g_szMap, g_iCurrentRound, g_iRndExecute);
			PrepareAncientExecutes();
		}
	}
}

public void OnWeaponZoom(Event eEvent, const char[] szName, bool bDontBroadcast)
{
	int client = GetClientOfUserId(eEvent.GetInt("userid"));
	
	if (IsValidClient(client) && IsFakeClient(client) && IsPlayerAlive(client))
		g_fZoomedTimestamp[client] = GetGameTime();
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
			float fClientLoc[3], fTargetLoc[3];
			
			GetClientAbsOrigin(client, fClientLoc);
			GetClientAbsOrigin(g_iTarget[client], fTargetLoc);
			
			float fRangeToEnemy = GetVectorDistance(fClientLoc, fTargetLoc);
			
			if (strcmp(szWeaponName, "weapon_deagle") == 0 && fRangeToEnemy > 100.0)
				SetEntDataFloat(client, g_iFireWeaponOffset, GetEntDataFloat(client, g_iFireWeaponOffset) + Math_GetRandomFloat(0.35, 0.60));
		}
		
		if (strcmp(szWeaponName, "weapon_awp") == 0 || strcmp(szWeaponName, "weapon_ssg08") == 0)
			CreateTimer(0.1, Timer_DelaySwitch, GetClientUserId(client));
	}
}

public Action OnTakeDamageAlive(int iVictim, int &iAttacker, int &iInflictor, float &fDamage, int &iDamageType, int &iWeapon, float fDamageForce[3], float fDamagePosition[3])
{
	if (float(GetClientHealth(iVictim)) - fDamage < 0.0)
		return Plugin_Continue;
	
	if (!(iDamageType & DMG_SLASH) && !(iDamageType & DMG_BULLET) && !(iDamageType & DMG_BURN))
		return Plugin_Continue;
	
	if (iVictim == iAttacker || !IsValidClient(iAttacker) || !IsPlayerAlive(iAttacker))
		return Plugin_Continue;
	
	if(BotMimic_IsPlayerMimicing(iVictim) && GetClientTeam(iVictim) == CS_TEAM_T && GetClientTeam(iAttacker) != CS_TEAM_T)
		g_bAbortExecute = true;
	
	return Plugin_Continue;
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
		
		return MRES_Supercede;
	}
	
	return MRES_Ignored;
}

public MRESReturn CCSBot_SetLookAt(int client, DHookParam hParams)
{
	char szDesc[64];
	
	DHookGetParamString(hParams, 1, szDesc, sizeof(szDesc));
	
	if (strcmp(szDesc, "Defuse bomb") == 0 || strcmp(szDesc, "Use entity") == 0 || strcmp(szDesc, "Open door") == 0 || strcmp(szDesc, "Hostage") == 0 || strcmp(szDesc, "Face outward") == 0)
		return MRES_Ignored;
	else if (strcmp(szDesc, "Avoid Flashbang") == 0)
	{
		DHookSetParam(hParams, 3, PRIORITY_HIGH);
		
		return MRES_ChangedHandled;
	}
	else if (strcmp(szDesc, "Blind") == 0)
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
		int iActiveWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		int iDefIndex = IsValidEntity(iActiveWeapon) ? GetEntProp(iActiveWeapon, Prop_Send, "m_iItemDefinitionIndex") : 0;
		int iSlot = eItems_GetWeaponSlotByDefIndex(iDefIndex);
		bool bIsWalking = !!GetEntProp(client, Prop_Send, "m_bIsWalking");
		float fClientEyes[3], fNoisePosition[3];
		
		DHookGetParamVector(hParams, 2, fNoisePosition);
		fNoisePosition[2] += 25.0;
		DHookSetParamVector(hParams, 2, fNoisePosition);
		
		GetClientEyePosition(client, fClientEyes);
		if(IsItMyChance(35.0) && IsPointVisible(fClientEyes, fNoisePosition) && LineGoesThroughSmoke(fClientEyes, fNoisePosition) && !bIsWalking)
			DHookSetParam(hParams, 7, true);
		
		if(GetTask(client) != ESCAPE_FROM_BOMB && GetTask(client) != ESCAPE_FROM_FLAMES)
		{
			if(IsPositionCloseToEnemy(client, fNoisePosition) && (iSlot == CS_SLOT_KNIFE || iSlot == CS_SLOT_GRENADE))
				BotEquipBestWeapon(client, true);
			else if(IsItMyChance(0.5) && !IsPositionCloseToEnemy(client, fNoisePosition) && IsValidEntity(GetPlayerWeaponSlot(client, CS_SLOT_GRENADE)))
				ProcessGrenadeThrow(client, fNoisePosition);
		}
		
		return MRES_ChangedHandled;
	}
	else if(strcmp(szDesc, "Approach Point (Hiding)") == 0 || strcmp(szDesc, "Nearby enemy gunfire") == 0)
	{
		float fPos[3], fClientEyes[3];
		
		DHookGetParamVector(hParams, 2, fPos);
		fPos[2] += 25.0;
		DHookSetParamVector(hParams, 2, fPos);
		
		if(GetTask(client) != ESCAPE_FROM_BOMB && GetTask(client) != ESCAPE_FROM_FLAMES)
		{
			GetClientEyePosition(client, fClientEyes);
			BotBendLineOfSight(client, fClientEyes, fPos, fPos, 135.0);
			if(IsItMyChance(15.0) && !IsPositionCloseToEnemy(client, fPos) && IsValidEntity(GetPlayerWeaponSlot(client, CS_SLOT_GRENADE)))
				ProcessGrenadeThrow(client, fPos);
		}
		
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
		
		if(g_bFreezetimeEnd)
		{
			int iActiveWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
			if (iActiveWeapon == -1) return Plugin_Continue;
			
			int iDefIndex = GetEntProp(iActiveWeapon, Prop_Send, "m_iItemDefinitionIndex");
			
			float fClientLoc[3];
			
			GetClientAbsOrigin(client, fClientLoc);
			
			if(g_pCurrArea[client] != INVALID_NAV_AREA)
			{
				if (g_pCurrArea[client].Attributes & NAV_MESH_WALK)
					iButtons |= IN_SPEED;
				
				if (g_pCurrArea[client].Attributes & NAV_MESH_RUN)
					iButtons &= ~IN_SPEED;
			}
			
			//ArrayList Indexes
			//0 - Position
			//1 - LookAt
			//2 - Nade Def Index
			//3 - Is Jumpthrow?
			//4 - Crouch?
			//5 - Timestamp
			//6 - Team
			bool bIsJumpthrow ,bCrouch;
			if(g_iDoingSmokeNum[client] != -1 && g_ArrayNades[g_iDoingSmokeNum[client]] != null)
			{
				float fNadeSpot[3];
				g_ArrayNades[g_iDoingSmokeNum[client]].Set(5, GetGameTime());
				g_ArrayNades[g_iDoingSmokeNum[client]].GetArray(0, fNadeSpot);
				float fDisToNade = GetVectorDistance(fClientLoc, fNadeSpot);

				if(fDisToNade < 175.0)
				{
					BotMoveTo(client, fNadeSpot, FASTEST_ROUTE);
					SDKCall(g_hSwitchWeaponCall, client, eItems_FindWeaponByDefIndex(client, g_ArrayNades[g_iDoingSmokeNum[client]].Get(2)), 0);
				}
					
				if(fDisToNade < 25.0)
				{					
					float fNadeLook[3];
					g_ArrayNades[g_iDoingSmokeNum[client]].GetArray(1, fNadeLook);
					
					BotSetLookAt(client, "Use entity", fNadeLook, PRIORITY_HIGH, 2.0, false, 3.0, false);
					float fPlayerVelocity[3];
					GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", fPlayerVelocity);
					
					if(view_as<LookAtSpotState>(GetEntData(client, g_iBotLookAtSpotStateOffset)) == LOOK_AT_SPOT && GetVectorLength(fPlayerVelocity) == 0.0 && (GetEntityFlags(client) & FL_ONGROUND))
					{
						CreateTimer(1.5, Timer_ThrowGrenade, GetClientUserId(client));
						bIsJumpthrow = !!g_ArrayNades[g_iDoingSmokeNum[client]].Get(3);	
						bCrouch = !!g_ArrayNades[g_iDoingSmokeNum[client]].Get(4);	
						
						if(bCrouch)
							iButtons |= IN_DUCK;
						
						if (g_bCanThrowGrenade[client])
						{
							Array_Copy(fNadeLook, g_fNadeTarget[client], 3);
							RequestFrame(DelayThrow, GetClientUserId(client));
						}
						
						if(g_bThrowGrenade[client] && view_as<GrenadeTossState>(GetEntData(client, g_iBotNadeStateOffs)) == FINISH_THROW)
						{
							TeleportEntity(client, fNadeSpot, NULL_VECTOR, NULL_VECTOR);
							if(bIsJumpthrow)
								iButtons |= IN_JUMP;
							
							if(bCrouch)
								iButtons |= IN_DUCK;
								
							g_iDoingSmokeNum[client] = -1;
							g_bCanThrowGrenade[client] = false;
						}
					}
				}
			}
			
			if(g_bThrowGrenade[client] && eItems_GetWeaponSlotByDefIndex(iDefIndex) == CS_SLOT_GRENADE)
				BotThrowGrenade(client, g_fNadeTarget[client]);
			
			if((IsSafe(client) && !BotMimic_IsPlayerMimicing(client)) || g_bEveryoneDead)
				iButtons &= ~IN_SPEED;
				
			if(GetEntPropFloat(client, Prop_Send, "m_flMaxspeed") == 1.0)
				SetEntPropFloat(client, Prop_Send, "m_flMaxspeed", 260.0);
			
			if (g_bIsProBot[client])
			{		
				g_iTarget[client] = BotGetEnemy(client);
				
				float fTargetDistance;
				int iZoomLevel;
				bool bIsEnemyVisible = !!GetEntData(client, g_iEnemyVisibleOffset);
				bool bIsHiding = BotIsHiding(client);
				bool bIsDucking = !!(GetEntityFlags(client) & FL_DUCKING);
				bool bIsReloading = IsPlayerReloading(client);
				
				if(HasEntProp(iActiveWeapon, Prop_Send, "m_zoomLevel"))
					iZoomLevel = GetEntProp(iActiveWeapon, Prop_Send, "m_zoomLevel");
				
				if(bIsHiding && (iDefIndex == 8 || iDefIndex == 39) && iZoomLevel == 0)
					iButtons |= IN_ATTACK2;
				else if(!bIsHiding && (iDefIndex == 8 || iDefIndex == 39) && iZoomLevel == 1)
					iButtons |= IN_ATTACK2;
				
				if (bIsHiding && g_bUncrouch[client])
					iButtons &= ~IN_DUCK;
					
				if (!IsValidClient(g_iTarget[client]) || !IsPlayerAlive(g_iTarget[client]) || g_fTargetPos[client][2] == 0)
					return Plugin_Continue;
				
				if (eItems_GetWeaponSlotByDefIndex(iDefIndex) == CS_SLOT_KNIFE || eItems_GetWeaponSlotByDefIndex(iDefIndex) == CS_SLOT_GRENADE)
						BotEquipBestWeapon(client, true);
				
				if (bIsEnemyVisible && GetEntityMoveType(client) != MOVETYPE_LADDER)
				{
					g_bAbortExecute = true;
					
					BotAttack(client, g_iTarget[client]);
					fTargetDistance = GetVectorDistance(fClientLoc, g_fTargetPos[client]);
					
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
									iButtons |= IN_ATTACK;
							}
							
							if (fOnTarget > fAimTolerance && !bIsDucking && fTargetDistance < 2000.0 && iDefIndex != 17 && iDefIndex != 19 && iDefIndex != 23 && iDefIndex != 24 && iDefIndex != 25 && iDefIndex != 26 && iDefIndex != 33 && iDefIndex != 34)
								SetEntPropFloat(client, Prop_Send, "m_flMaxspeed", 1.0);
							else if (fTargetDistance > 2000.0 && GetEntDataFloat(client, g_iFireWeaponOffset) == GetGameTime())
								SetEntPropFloat(client, Prop_Send, "m_flMaxspeed", 1.0);
						}
						case 1:
						{
							if (GetGameTime() - GetEntDataFloat(client, g_iFireWeaponOffset) < 0.1 && !bIsDucking && !bIsReloading)
								SetEntPropFloat(client, Prop_Send, "m_flMaxspeed", 1.0);
						}
						case 9, 40:
						{
							if (fTargetDistance < 2750.0 && !bIsReloading && GetGameTime() - g_fZoomedTimestamp[client] > 2.5 && GetClientAimTarget(client, true) == g_iTarget[client])
							{
								iButtons |= IN_ATTACK;
								SetEntDataFloat(client, g_iFireWeaponOffset, GetGameTime());
							}
							
							if(GetGameTime() - GetEntDataFloat(client, g_iFireWeaponOffset) < 0.1)
								SetEntPropFloat(client, Prop_Send, "m_flMaxspeed", 1.0);
						}
					}
					
					fClientLoc[2] += 35.5;
						
					if (!GetEntProp(iActiveWeapon, Prop_Data, "m_bInReload") && IsPointVisible(fClientLoc, g_fTargetPos[client]) && fOnTarget > fAimTolerance && fTargetDistance < 2000.0 && (iDefIndex == 7 || iDefIndex == 8 || iDefIndex == 10 || iDefIndex == 13 || iDefIndex == 14 || iDefIndex == 16 || iDefIndex == 39 || iDefIndex == 60 || iDefIndex == 28))
						iButtons |= IN_DUCK;
						
					if(!(GetEntityFlags(client) & FL_ONGROUND))
						iButtons &= ~IN_ATTACK;
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
	CreateTimer(0.2, Timer_DelayBestWeapon, GetClientUserId(client));
}

public void OnClientDisconnect(int client)
{
	if (IsValidClient(client) && IsFakeClient(client))
	{
		g_iProfileRank[client] = 0;
		SDKUnhook(client, SDKHook_OnTakeDamageAlive, OnTakeDamageAlive);
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
		float fPosition[3], fLookAt[3];
		char szTeam[8];
		
		if (g_ArrayNades[i] == null)
			delete g_ArrayNades[i];
		
		g_ArrayNades[i] = new ArrayList(3);
		g_ArrayNades[i].Clear();
		
		kv.GetVector("position", 	fPosition);
		g_ArrayNades[i].PushArray(fPosition);
		kv.GetVector("lookat", fLookAt);
		g_ArrayNades[i].PushArray(fLookAt);
		g_ArrayNades[i].Push(kv.GetNum("nadedefindex"));
		g_ArrayNades[i].Push(kv.GetNum("jumpthrow"));
		g_ArrayNades[i].Push(kv.GetNum("crouch"));
		g_ArrayNades[i].Push(kv.GetFloat("timestamp"));
		kv.GetString("team", szTeam, sizeof(szTeam));
		if(strcmp(szTeam, "CT", false) == 0)
			g_ArrayNades[i].Push(CS_TEAM_CT);
		else if(strcmp(szTeam, "T", false) == 0)
			g_ArrayNades[i].Push(CS_TEAM_T);
	
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
	
	if ((g_iBotNadeStateOffs = hGameConfig.GetOffset("CCSBot::m_grenadeTossState")) == -1)
		SetFailState("Failed to get CCSBot::m_grenadeTossState offset.");
	
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
	int nearestEntity = -1;
	float clientVecOrigin[3], fNadeSpot[3];
	
	GetEntPropVector(client, Prop_Data, "m_vecOrigin", clientVecOrigin); // Line 2607
	
	//Get the distance between the first entity and client
	float distance, nearestDistance = -1.0;
	
	for(int i = 0; i < g_iMaxNades; i++)
	{
		if(g_ArrayNades[i] == null)
			return -1;
			
		if(BotMimic_IsPlayerMimicing(client))
			return -1;
		
		if((GetGameTime() - g_ArrayNades[i].Get(5)) < 25.0)
			continue;
			
		if(!IsValidEntity(eItems_FindWeaponByDefIndex(client, g_ArrayNades[i].Get(2))))
			continue;
		
		if(GetClientTeam(client) != g_ArrayNades[i].Get(6))
			continue;
	
		g_ArrayNades[i].GetArray(0, fNadeSpot);
		
		distance = GetVectorDistance(clientVecOrigin, fNadeSpot);
		
		if(distance > 175.0)
			continue;
		
		if (distance < nearestDistance || nearestDistance == -1.0)
		{
			nearestEntity = i;
			nearestDistance = distance;
		}
	}
	
	return nearestEntity;
} 

stock int GetNearestEntity(int client, char[] szClassname, bool bCheckVisibility = true)
{
	int iNearestEntity = -1;
	float fClientOrigin[3], fClientEyes[3], fEntityOrigin[3];
	
	GetEntPropVector(client, Prop_Data, "m_vecOrigin", fClientOrigin); // Line 2607
	GetClientEyePosition(client, fClientEyes); // Line 2607
	
	//Get the distance between the first entity and client
	float fDistance, fNearestDistance = -1.0;
	
	//Find all the entity and compare the distances
	int iEntity = -1;
	bool bVisible;
	while ((iEntity = FindEntityByClassname(iEntity, szClassname)) != -1)
	{
		GetEntPropVector(iEntity, Prop_Data, "m_vecOrigin", fEntityOrigin); // Line 2610
		fDistance = GetVectorDistance(fClientOrigin, fEntityOrigin);
		bVisible = bCheckVisibility ? IsPointVisible(fClientEyes, fEntityOrigin) : true;
		
		if ((fDistance < fNearestDistance || fNearestDistance == -1.0) && bVisible)
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
	int iPlayerWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	
	if(!IsValidEntity(iPlayerWeapon))
		return false;
	
	//Out of ammo? or Reloading? or Finishing Weapon Switch?
	if(GetEntProp(iPlayerWeapon, Prop_Data, "m_bInReload") || GetEntProp(iPlayerWeapon, Prop_Send, "m_iClip1") <= 0 || GetEntProp(iPlayerWeapon, Prop_Send, "m_iIronSightMode") == 2)
		return true;
	
	if(GetEntPropFloat(client, Prop_Send, "m_flNextAttack") > GetGameTime())
		return true;
	
	return GetEntPropFloat(iPlayerWeapon, Prop_Send, "m_flNextPrimaryAttack") >= GetGameTime();
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
				int iActiveWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
				if (iActiveWeapon == -1) return;
				
				int iDefIndex = GetEntProp(iActiveWeapon, Prop_Send, "m_iItemDefinitionIndex");
				
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
	GetGrenadeToss(client, fTarget);
			
	int iNade = GetPlayerWeaponSlot(client, CS_SLOT_GRENADE);
	int iNadeDefIndex = IsValidEntity(iNade) ? GetEntProp(iNade, Prop_Send, "m_iItemDefinitionIndex") : 0;
	float fClientPos[3], fClientEyes[3], fPredictedNade[3], fNadeAngles[3];
	GetClientEyePosition(client, fClientEyes);
	MakeVectorFromPoints(fClientEyes, fTarget, fNadeAngles);
	GetVectorAngles(fNadeAngles, fNadeAngles);
	fNadeAngles[0] = AngleNormalize(fNadeAngles[0]);
	fNadeAngles[1] = AngleNormalize(fNadeAngles[1]);
	fNadeAngles[2] = 0.0;
	
	GetClientAbsOrigin(client, fClientPos);
	ShowTrajectory(client, fNadeAngles, iNadeDefIndex, 0.9, 0.0, fPredictedNade);
	
	if(GetVectorDistance(fPredictedNade, fClientPos) < 250.0 && IsPointVisible(fClientPos, fPredictedNade))
		return;
	
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
	float fMins[3] = { -2.0, -2.0, -2.0 };
	float fMaxs[3] = { 2.0, 2.0, 2.0 };
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

stock void ShowTrajectory(int iClient, float ThrowAngle[3], int iNadeDefIndex, float factor, float disp, float fPosition[3])
{
	float GrenadeVelocity[3];
	float PlayerVelocity[3];
	float ThrowVector[3];
	float ThrowVelocity;
	float gStart[3];
	float gEnd[3];
	float fwd[3];
	float right[3];
	float up[3];
	float dtime = 1.5;

	ThrowAngle[0] = -10.0 + ThrowAngle[0] + FloatAbs(ThrowAngle[0]) * 10.0 / 90.0;

	GetAngleVectors(ThrowAngle, fwd, right, up);
	NormalizeVector(fwd, ThrowVector);

	GetClientEyePosition(iClient, gStart);

	for (int i = 0; i < 3; i++)
		gStart[i] += ThrowVector[i] * 16.0;

	gStart[2] += disp;

	GetEntPropVector(iClient, Prop_Data, "m_vecAbsVelocity", PlayerVelocity);

	ThrowVelocity = 750.0 * factor;
	ScaleVector(PlayerVelocity, 1.25);

	for (int i = 0; i < 3; i++)
	{
		GrenadeVelocity[i] = ThrowVector[i] * ThrowVelocity + PlayerVelocity[i];
	}

	float dt = 0.05;
	for (float t = 0.0; t <= dtime; t += dt)
	{
		gEnd[0] = gStart[0] + GrenadeVelocity[0] * dt;
		gEnd[1] = gStart[1] + GrenadeVelocity[1] * dt;

		float gForce      = 0.4 * FindConVar("sv_gravity").FloatValue;
		float NewVelocity = GrenadeVelocity[2] - gForce * dt;
		float AvgVelocity = (GrenadeVelocity[2] + NewVelocity) / 2.0;

		gEnd[2]            = gStart[2] + AvgVelocity * dt;
		GrenadeVelocity[2] = NewVelocity;

		float mins[3] = { -2.0, -2.0, -2.0 };
		float maxs[3] = { 2.0, 2.0, 2.0 };

		Handle gRayTrace = TR_TraceHullEx(gStart, gEnd, mins, maxs, MASK_SHOT_HULL);

		if (TR_GetFraction(gRayTrace) != 1.0)
		{
			if (TR_GetEntityIndex(gRayTrace) == iClient && t == 0.0)
			{
				delete gRayTrace;
				gStart = gEnd;
				continue;
			}

			TR_GetEndPosition(gEnd, gRayTrace);

			float NVector[3];
			TR_GetPlaneNormal(gRayTrace, NVector);

			float Impulse = 2.0 * GetVectorDotProduct(NVector, GrenadeVelocity);

			for (int i = 0; i < 3; i++)
			{
				GrenadeVelocity[i] -= Impulse * NVector[i];

				if (FloatAbs(GrenadeVelocity[i]) < 0.1)
					GrenadeVelocity[i] = 0.0;
			}

			float SurfaceElasticity = GetEntPropFloat(TR_GetEntityIndex(gRayTrace), Prop_Send, "m_flElasticity");
			float elasticity        = 0.45 * SurfaceElasticity;
			ScaleVector(GrenadeVelocity, elasticity);

			float ZVector[3] = { 0.0, 0.0, 1.0 };
			if (GetVectorDotProduct(NVector, ZVector) > 0.7)
			{
				if (iNadeDefIndex == 48 || iNadeDefIndex == 46)
					dtime = 0.0;
			}
		}

		delete gRayTrace;

		gStart = gEnd;
	}
	
	Array_Copy(gEnd, fPosition, 3);
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

stock int HumansOnTeam(int iTeam, bool bIsAlive = false)
{
	int iCount = 0;

	for (int i = 1; i <= MaxClients; ++i)
	{
		if (!IsValidClient(i))
			continue;

		if (IsFakeClient(i))
			continue;

		if (GetClientTeam(i) != iTeam)
			continue;

		if (bIsAlive && !IsPlayerAlive(i))
			continue;

		iCount++;
	}

	return iCount;
}

stock bool IsSafe(int client)
{
	if(!IsFakeClient(client))
		return false;
	
	if((GetGameTime() - g_fFreezeTimeEnd) < GetEntDataFloat(client, g_iBotSafeTimeOffset))
		return true;
	
	return false;
}

stock bool IsPositionCloseToEnemy(int client, float fOrigin[3])
{
	float fEnemyOrigin[3];
	float fSmallestDistance = 150.0;
	for (int i=1; i <= MaxClients; i++) 
	{
		if(!IsValidClient(i)) 
			continue;	
			
		if(client == i)
			continue;

		if(GetClientTeam(client) == GetClientTeam(i))
			continue;

		GetClientAbsOrigin(i, fEnemyOrigin);

		float fDistance = GetVectorDistance(fOrigin, fEnemyOrigin);

		if(fDistance < fSmallestDistance || fSmallestDistance == 0.0)
			return true;
	}

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