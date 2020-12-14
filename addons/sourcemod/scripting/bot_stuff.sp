#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <cstrike>
#include <eItems>
#include <smlib>
#include <navmesh>
#include <dhooks>

char g_szMap[128];
char g_szSmoke[64][MAXPLAYERS + 1];
char g_szFlashbang[64][MAXPLAYERS + 1];
char g_szPosition[64][MAXPLAYERS + 1];
bool g_bFreezetimeEnd = false;
bool g_bBombPlanted = false;
bool g_bDoExecute = false;
bool g_bIsProBot[MAXPLAYERS + 1] = false;
bool g_bHasThrownNade[MAXPLAYERS + 1], g_bHasThrownSmoke[MAXPLAYERS + 1], g_bCanAttack[MAXPLAYERS + 1], g_bCanThrowSmoke[MAXPLAYERS + 1], g_bCanThrowFlash[MAXPLAYERS + 1], g_bIsHeadVisible[MAXPLAYERS + 1], g_bZoomed[MAXPLAYERS + 1];
int g_iProfileRank[MAXPLAYERS + 1], g_iUncrouchChance[MAXPLAYERS + 1], g_iUSPChance[MAXPLAYERS + 1], g_iM4A1SChance[MAXPLAYERS + 1], g_iProfileRankOffset, g_iRndExecute, g_iRoundStartedTime;
float g_fHoldPos[MAXPLAYERS + 1][3];
CNavArea navArea[MAXPLAYERS + 1];
int g_iBotTargetSpotXOffset, g_iBotTargetSpotYOffset, g_iBotTargetSpotZOffset, g_iBotNearbyEnemiesOffset;
Handle g_hBotMoveTo;
Handle g_hLookupBone;
Handle g_hGetBonePosition;
Handle g_hBotAttack;
Handle g_hBotIsVisible;
Handle g_hBotIsBusy;
Handle g_hBotIsHiding;
Handle g_hBotEquipBestWeapon;
Handle g_hBotSetLookAt;
Handle g_hBotBendLineOfSight;
Handle g_hBotSetLookAtDetour;
Handle g_hBotUpdateDetour;
Handle g_hBotPickNewAimSpotDetour;
Handle g_hBotThrowGrenadeDetour;

enum RouteType
{
	DEFAULT_ROUTE = 0, 
	FASTEST_ROUTE, 
	SAFEST_ROUTE, 
	RETREAT_ROUTE
}

enum PriorityType
{
	PRIORITY_LOW = 0, 
	PRIORITY_MEDIUM, 
	PRIORITY_HIGH, 
	PRIORITY_UNINTERRUPTABLE
}

char g_szBoneNames[][] =  {
	"neck_0", 
	"pelvis", 
	"spine_0", 
	"spine_1", 
	"spine_2", 
	"spine_3", 
	"arm_upper_L", 
	"arm_lower_L", 
	"hand_L", 
	"arm_upper_R", 
	"arm_lower_R", 
	"hand_R", 
	"leg_upper_L", 
	"ankle_L", 
	"leg_lower_L", 
	"leg_upper_R", 
	"ankle_R", 
	"leg_lower_R"
};

#include "bot_stuff/de_mirage.sp"
#include "bot_stuff/de_dust2.sp"
#include "bot_stuff/de_inferno.sp"
#include "bot_stuff/de_overpass.sp"

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
	HookEventEx("round_start", OnRoundStart);
	HookEventEx("round_freeze_end", OnFreezetimeEnd);
	HookEventEx("bomb_planted", OnBombPlanted);
	HookEventEx("weapon_zoom", OnWeaponZoom);
	
	LoadSDK();
	LoadDetours();
	
	RegConsoleCmd("team_nip", Team_NiP);
	RegConsoleCmd("team_mibr", Team_MIBR);
	RegConsoleCmd("team_faze", Team_FaZe);
	RegConsoleCmd("team_astralis", Team_Astralis);
	RegConsoleCmd("team_c9", Team_C9);
	RegConsoleCmd("team_g2", Team_G2);
	RegConsoleCmd("team_fnatic", Team_fnatic);
	RegConsoleCmd("team_north", Team_North);
	RegConsoleCmd("team_mouz", Team_mouz);
	RegConsoleCmd("team_tyloo", Team_TYLOO);
	RegConsoleCmd("team_eg", Team_EG);
	RegConsoleCmd("team_navi", Team_NaVi);
	RegConsoleCmd("team_liquid", Team_Liquid);
	RegConsoleCmd("team_ago", Team_AGO);
	RegConsoleCmd("team_ence", Team_ENCE);
	RegConsoleCmd("team_vitality", Team_Vitality);
	RegConsoleCmd("team_big", Team_BIG);
	RegConsoleCmd("team_furia", Team_FURIA);
	RegConsoleCmd("team_contact", Team_c0ntact);
	RegConsoleCmd("team_col", Team_coL);
	RegConsoleCmd("team_vici", Team_ViCi);
	RegConsoleCmd("team_forze", Team_forZe);
	RegConsoleCmd("team_winstrike", Team_Winstrike);
	RegConsoleCmd("team_sprout", Team_Sprout);
	RegConsoleCmd("team_heroic", Team_Heroic);
	RegConsoleCmd("team_intz", Team_INTZ);
	RegConsoleCmd("team_vp", Team_VP);
	RegConsoleCmd("team_apeks", Team_Apeks);
	RegConsoleCmd("team_attax", Team_aTTaX);
	RegConsoleCmd("team_rng", Team_Renegades);
	RegConsoleCmd("team_envy", Team_Envy);
	RegConsoleCmd("team_spirit", Team_Spirit);
	RegConsoleCmd("team_ldlc", Team_LDLC);
	RegConsoleCmd("team_gamerlegion", Team_GamerLegion);
	RegConsoleCmd("team_wolsung", Team_Wolsung);
	RegConsoleCmd("team_pducks", Team_PDucks);
	RegConsoleCmd("team_havu", Team_HAVU);
	RegConsoleCmd("team_lyngby", Team_Lyngby);
	RegConsoleCmd("team_godsent", Team_GODSENT);
	RegConsoleCmd("team_nordavind", Team_Nordavind);
	RegConsoleCmd("team_sj", Team_SJ);
	RegConsoleCmd("team_bren", Team_Bren);
	RegConsoleCmd("team_giants", Team_Giants);
	RegConsoleCmd("team_lions", Team_Lions);
	RegConsoleCmd("team_riders", Team_Riders);
	RegConsoleCmd("team_offset", Team_OFFSET);
	RegConsoleCmd("team_esuba", Team_eSuba);
	RegConsoleCmd("team_nexus", Team_Nexus);
	RegConsoleCmd("team_pact", Team_PACT);
	RegConsoleCmd("team_heretics", Team_Heretics);
	RegConsoleCmd("team_nemiga", Team_Nemiga);
	RegConsoleCmd("team_pro100", Team_pro100);
	RegConsoleCmd("team_yalla", Team_YaLLa);
	RegConsoleCmd("team_yeah", Team_Yeah);
	RegConsoleCmd("team_singularity", Team_Singularity);
	RegConsoleCmd("team_detona", Team_DETONA);
	RegConsoleCmd("team_infinity", Team_Infinity);
	RegConsoleCmd("team_isurus", Team_Isurus);
	RegConsoleCmd("team_pain", Team_paiN);
	RegConsoleCmd("team_sharks", Team_Sharks);
	RegConsoleCmd("team_one", Team_One);
	RegConsoleCmd("team_w7m", Team_W7M);
	RegConsoleCmd("team_avant", Team_Avant);
	RegConsoleCmd("team_chiefs", Team_Chiefs);
	RegConsoleCmd("team_order", Team_ORDER);
	RegConsoleCmd("team_skade", Team_SKADE);
	RegConsoleCmd("team_paradox", Team_Paradox);
	RegConsoleCmd("team_beyond", Team_Beyond);
	RegConsoleCmd("team_boom", Team_BOOM);
	RegConsoleCmd("team_nasr", Team_NASR);
	RegConsoleCmd("team_ttt", Team_TTT);
	RegConsoleCmd("team_px", Team_PX);
	RegConsoleCmd("team_nxl", Team_nxl);
	RegConsoleCmd("team_dv", Team_DV);
	RegConsoleCmd("team_energy", Team_energy);
	RegConsoleCmd("team_furious", Team_Furious);
	RegConsoleCmd("team_groundzero", Team_GroundZero);
	RegConsoleCmd("team_avez", Team_AVEZ);
	RegConsoleCmd("team_gtz", Team_GTZ);
	RegConsoleCmd("team_x6tence", Team_x6tence);
	RegConsoleCmd("team_k23", Team_K23);
	RegConsoleCmd("team_goliath", Team_Goliath);
	RegConsoleCmd("team_uol", Team_UOL);
	RegConsoleCmd("team_radix", Team_RADIX);
	RegConsoleCmd("team_illuminar", Team_Illuminar);
	RegConsoleCmd("team_queso", Team_Queso);
	RegConsoleCmd("team_ig", Team_IG);
	RegConsoleCmd("team_hr", Team_HR);
	RegConsoleCmd("team_dice", Team_Dice);
	RegConsoleCmd("team_planetkey", Team_PlanetKey);
	RegConsoleCmd("team_vexed", Team_Vexed);
	RegConsoleCmd("team_hle", Team_HLE);
	RegConsoleCmd("team_gambit", Team_Gambit);
	RegConsoleCmd("team_wisla", Team_Wisla);
	RegConsoleCmd("team_imperial", Team_Imperial);
	RegConsoleCmd("team_pompa", Team_Pompa);
	RegConsoleCmd("team_Unique", Team_Unique);
	RegConsoleCmd("team_izako", Team_Izako);
	RegConsoleCmd("team_atk", Team_ATK);
	RegConsoleCmd("team_chaos", Team_Chaos);
	RegConsoleCmd("team_wings", Team_Wings);
	RegConsoleCmd("team_lynn", Team_Lynn);
	RegConsoleCmd("team_triumph", Team_Triumph);
	RegConsoleCmd("team_fate", Team_FATE);
	RegConsoleCmd("team_canids", Team_Canids);
	RegConsoleCmd("team_espada", Team_ESPADA);
	RegConsoleCmd("team_og", Team_OG);
	RegConsoleCmd("team_wizards", Team_Wizards);
	RegConsoleCmd("team_tricked", Team_Tricked);
	RegConsoleCmd("team_geng", Team_GenG);
	RegConsoleCmd("team_endpoint", Team_Endpoint);
	RegConsoleCmd("team_saw", Team_sAw);
	RegConsoleCmd("team_dig", Team_DIG);
	RegConsoleCmd("team_d13", Team_D13);
	RegConsoleCmd("team_zigma", Team_ZIGMA);
	RegConsoleCmd("team_ambush", Team_Ambush);
	RegConsoleCmd("team_kova", Team_KOVA);
	RegConsoleCmd("team_agf", Team_AGF);
	RegConsoleCmd("team_gameagents", Team_GameAgents);
	RegConsoleCmd("team_keyd", Team_Keyd);
	RegConsoleCmd("team_tiger", Team_TIGER);
	RegConsoleCmd("team_leisure", Team_LEISURE);
	RegConsoleCmd("team_lilmix", Team_Lilmix);
	RegConsoleCmd("team_ftw", Team_FTW);
	RegConsoleCmd("team_9ine", Team_9INE);
	RegConsoleCmd("team_qbf", Team_QBF);
	RegConsoleCmd("team_tigers", Team_Tigers);
	RegConsoleCmd("team_9z", Team_9z);
	RegConsoleCmd("team_sinister5", Team_Sinister5);
	RegConsoleCmd("team_sinners", Team_SINNERS);
	RegConsoleCmd("team_impact", Team_Impact);
	RegConsoleCmd("team_ern", Team_ERN);
	RegConsoleCmd("team_bl4ze", Team_BL4ZE);
	RegConsoleCmd("team_global", Team_Global);
	RegConsoleCmd("team_conquer", Team_Conquer);
	RegConsoleCmd("team_rooster", Team_Rooster);
	RegConsoleCmd("team_flames", Team_Flames);
	RegConsoleCmd("team_baecon", Team_Baecon);
	RegConsoleCmd("team_kpi", Team_KPI);
	RegConsoleCmd("team_hreds", Team_hREDS);
	RegConsoleCmd("team_lemondogs", Team_Lemondogs);
	RegConsoleCmd("team_cex", Team_CeX);
	RegConsoleCmd("team_havan", Team_Havan);
	RegConsoleCmd("team_sangal", Team_Sangal);
}

public Action Team_NiP(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "twist");
		ServerCommand("bot_add_ct %s", "hampus");
		ServerCommand("bot_add_ct %s", "nawwk");
		ServerCommand("bot_add_ct %s", "Plopski");
		ServerCommand("bot_add_ct %s", "REZ");
		ServerCommand("mp_teamlogo_1 nip");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "twist");
		ServerCommand("bot_add_t %s", "hampus");
		ServerCommand("bot_add_t %s", "nawwk");
		ServerCommand("bot_add_t %s", "Plopski");
		ServerCommand("bot_add_t %s", "REZ");
		ServerCommand("mp_teamlogo_2 nip");
	}
	
	return Plugin_Handled;
}

public Action Team_MIBR(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "kNgV-");
		ServerCommand("bot_add_ct %s", "leo_drk");
		ServerCommand("bot_add_ct %s", "v$m");
		ServerCommand("bot_add_ct %s", "LUCAS1");
		ServerCommand("bot_add_ct %s", "trk");
		ServerCommand("mp_teamlogo_1 mibr");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "kNgV-");
		ServerCommand("bot_add_t %s", "leo_drk");
		ServerCommand("bot_add_t %s", "v$m");
		ServerCommand("bot_add_t %s", "LUCAS1");
		ServerCommand("bot_add_t %s", "trk");
		ServerCommand("mp_teamlogo_2 mibr");
	}
	
	return Plugin_Handled;
}

public Action Team_FaZe(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Kjaerbye");
		ServerCommand("bot_add_ct %s", "broky");
		ServerCommand("bot_add_ct %s", "olofmeister");
		ServerCommand("bot_add_ct %s", "rain");
		ServerCommand("bot_add_ct %s", "coldzera");
		ServerCommand("mp_teamlogo_1 faze");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Kjaerbye");
		ServerCommand("bot_add_t %s", "broky");
		ServerCommand("bot_add_t %s", "olofmeister");
		ServerCommand("bot_add_t %s", "rain");
		ServerCommand("bot_add_t %s", "coldzera");
		ServerCommand("mp_teamlogo_2 faze");
	}
	
	return Plugin_Handled;
}

public Action Team_Astralis(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "gla1ve");
		ServerCommand("bot_add_ct %s", "device");
		ServerCommand("bot_add_ct %s", "Xyp9x");
		ServerCommand("bot_add_ct %s", "Magisk");
		ServerCommand("bot_add_ct %s", "dupreeh");
		ServerCommand("mp_teamlogo_1 astr");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "gla1ve");
		ServerCommand("bot_add_t %s", "device");
		ServerCommand("bot_add_t %s", "Xyp9x");
		ServerCommand("bot_add_t %s", "Magisk");
		ServerCommand("bot_add_t %s", "dupreeh");
		ServerCommand("mp_teamlogo_2 astr");
	}
	
	return Plugin_Handled;
}

public Action Team_C9(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "ALEX");
		ServerCommand("bot_add_ct %s", "es3tag");
		ServerCommand("bot_add_ct %s", "mezii");
		ServerCommand("bot_add_ct %s", "woxic");
		ServerCommand("bot_add_ct %s", "floppy");
		ServerCommand("mp_teamlogo_1 c9");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "ALEX");
		ServerCommand("bot_add_t %s", "es3tag");
		ServerCommand("bot_add_t %s", "mezii");
		ServerCommand("bot_add_t %s", "woxic");
		ServerCommand("bot_add_t %s", "floppy");
		ServerCommand("mp_teamlogo_2 c9");
	}
	
	return Plugin_Handled;
}

public Action Team_G2(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "huNter-");
		ServerCommand("bot_add_ct %s", "kennyS");
		ServerCommand("bot_add_ct %s", "nexa");
		ServerCommand("bot_add_ct %s", "NiKo");
		ServerCommand("bot_add_ct %s", "AmaNEk");
		ServerCommand("mp_teamlogo_1 g2");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "huNter-");
		ServerCommand("bot_add_t %s", "kennyS");
		ServerCommand("bot_add_t %s", "nexa");
		ServerCommand("bot_add_t %s", "NiKo");
		ServerCommand("bot_add_t %s", "AmaNEk");
		ServerCommand("mp_teamlogo_2 g2");
	}
	
	return Plugin_Handled;
}

public Action Team_fnatic(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "flusha");
		ServerCommand("bot_add_ct %s", "JW");
		ServerCommand("bot_add_ct %s", "KRIMZ");
		ServerCommand("bot_add_ct %s", "Brollan");
		ServerCommand("bot_add_ct %s", "Golden");
		ServerCommand("mp_teamlogo_1 fnatic");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "flusha");
		ServerCommand("bot_add_t %s", "JW");
		ServerCommand("bot_add_t %s", "KRIMZ");
		ServerCommand("bot_add_t %s", "Brollan");
		ServerCommand("bot_add_t %s", "Golden");
		ServerCommand("mp_teamlogo_2 fnatic");
	}
	
	return Plugin_Handled;
}

public Action Team_North(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "kreaz");
		ServerCommand("bot_add_ct %s", "Lekr0");
		ServerCommand("bot_add_ct %s", "kristou");
		ServerCommand("bot_add_ct %s", "cajunb");
		ServerCommand("bot_add_ct %s", "gade");
		ServerCommand("mp_teamlogo_1 north");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "kreaz");
		ServerCommand("bot_add_t %s", "Lekr0");
		ServerCommand("bot_add_t %s", "kristou");
		ServerCommand("bot_add_t %s", "cajunb");
		ServerCommand("bot_add_t %s", "gade");
		ServerCommand("mp_teamlogo_2 north");
	}
	
	return Plugin_Handled;
}

public Action Team_mouz(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "karrigan");
		ServerCommand("bot_add_ct %s", "chrisJ");
		ServerCommand("bot_add_ct %s", "Bymas");
		ServerCommand("bot_add_ct %s", "frozen");
		ServerCommand("bot_add_ct %s", "ropz");
		ServerCommand("mp_teamlogo_1 mss");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "karrigan");
		ServerCommand("bot_add_t %s", "chrisJ");
		ServerCommand("bot_add_t %s", "Bymas");
		ServerCommand("bot_add_t %s", "frozen");
		ServerCommand("bot_add_t %s", "ropz");
		ServerCommand("mp_teamlogo_2 mss");
	}
	
	return Plugin_Handled;
}

public Action Team_TYLOO(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Summer");
		ServerCommand("bot_add_ct %s", "Attacker");
		ServerCommand("bot_add_ct %s", "SLOWLY");
		ServerCommand("bot_add_ct %s", "somebody");
		ServerCommand("bot_add_ct %s", "DANK1NG");
		ServerCommand("mp_teamlogo_1 tyl");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Summer");
		ServerCommand("bot_add_t %s", "Attacker");
		ServerCommand("bot_add_t %s", "SLOWLY");
		ServerCommand("bot_add_t %s", "somebody");
		ServerCommand("bot_add_t %s", "DANK1NG");
		ServerCommand("mp_teamlogo_2 tyl");
	}
	
	return Plugin_Handled;
}

public Action Team_EG(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "stanislaw");
		ServerCommand("bot_add_ct %s", "tarik");
		ServerCommand("bot_add_ct %s", "Brehze");
		ServerCommand("bot_add_ct %s", "Ethan");
		ServerCommand("bot_add_ct %s", "CeRq");
		ServerCommand("mp_teamlogo_1 eg");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "stanislaw");
		ServerCommand("bot_add_t %s", "tarik");
		ServerCommand("bot_add_t %s", "Brehze");
		ServerCommand("bot_add_t %s", "Ethan");
		ServerCommand("bot_add_t %s", "CeRq");
		ServerCommand("mp_teamlogo_2 eg");
	}
	
	return Plugin_Handled;
}

public Action Team_NaVi(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "electronic");
		ServerCommand("bot_add_ct %s", "s1mple");
		ServerCommand("bot_add_ct %s", "flamie");
		ServerCommand("bot_add_ct %s", "Boombl4");
		ServerCommand("bot_add_ct %s", "Perfecto");
		ServerCommand("mp_teamlogo_1 navi");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "electronic");
		ServerCommand("bot_add_t %s", "s1mple");
		ServerCommand("bot_add_t %s", "flamie");
		ServerCommand("bot_add_t %s", "Boombl4");
		ServerCommand("bot_add_t %s", "Perfecto");
		ServerCommand("mp_teamlogo_2 navi");
	}
	
	return Plugin_Handled;
}

public Action Team_Liquid(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Stewie2K");
		ServerCommand("bot_add_ct %s", "NAF");
		ServerCommand("bot_add_ct %s", "Grim");
		ServerCommand("bot_add_ct %s", "ELiGE");
		ServerCommand("bot_add_ct %s", "Twistzz");
		ServerCommand("mp_teamlogo_1 liq");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Stewie2K");
		ServerCommand("bot_add_t %s", "NAF");
		ServerCommand("bot_add_t %s", "Grim");
		ServerCommand("bot_add_t %s", "ELiGE");
		ServerCommand("bot_add_t %s", "Twistzz");
		ServerCommand("mp_teamlogo_2 liq");
	}
	
	return Plugin_Handled;
}

public Action Team_AGO(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Furlan");
		ServerCommand("bot_add_ct %s", "GruBy");
		ServerCommand("bot_add_ct %s", "dgl");
		ServerCommand("bot_add_ct %s", "F1KU");
		ServerCommand("bot_add_ct %s", "leman");
		ServerCommand("mp_teamlogo_1 ago");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Furlan");
		ServerCommand("bot_add_t %s", "GruBy");
		ServerCommand("bot_add_t %s", "dgl");
		ServerCommand("bot_add_t %s", "F1KU");
		ServerCommand("bot_add_t %s", "leman");
		ServerCommand("mp_teamlogo_2 ago");
	}
	
	return Plugin_Handled;
}

public Action Team_ENCE(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "suNny");
		ServerCommand("bot_add_ct %s", "allu");
		ServerCommand("bot_add_ct %s", "sergej");
		ServerCommand("bot_add_ct %s", "Aerial");
		ServerCommand("bot_add_ct %s", "Jamppi");
		ServerCommand("mp_teamlogo_1 enc");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "suNny");
		ServerCommand("bot_add_t %s", "allu");
		ServerCommand("bot_add_t %s", "sergej");
		ServerCommand("bot_add_t %s", "Aerial");
		ServerCommand("bot_add_t %s", "Jamppi");
		ServerCommand("mp_teamlogo_2 enc");
	}
	
	return Plugin_Handled;
}

public Action Team_Vitality(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "shox");
		ServerCommand("bot_add_ct %s", "ZywOo");
		ServerCommand("bot_add_ct %s", "apEX");
		ServerCommand("bot_add_ct %s", "RpK");
		ServerCommand("bot_add_ct %s", "Misutaaa");
		ServerCommand("mp_teamlogo_1 vita");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "shox");
		ServerCommand("bot_add_t %s", "ZywOo");
		ServerCommand("bot_add_t %s", "apEX");
		ServerCommand("bot_add_t %s", "RpK");
		ServerCommand("bot_add_t %s", "Misutaaa");
		ServerCommand("mp_teamlogo_2 vita");
	}
	
	return Plugin_Handled;
}

public Action Team_BIG(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "tiziaN");
		ServerCommand("bot_add_ct %s", "syrsoN");
		ServerCommand("bot_add_ct %s", "XANTARES");
		ServerCommand("bot_add_ct %s", "tabseN");
		ServerCommand("bot_add_ct %s", "k1to");
		ServerCommand("mp_teamlogo_1 big");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "tiziaN");
		ServerCommand("bot_add_t %s", "syrsoN");
		ServerCommand("bot_add_t %s", "XANTARES");
		ServerCommand("bot_add_t %s", "tabseN");
		ServerCommand("bot_add_t %s", "k1to");
		ServerCommand("mp_teamlogo_2 big");
	}
	
	return Plugin_Handled;
}

public Action Team_FURIA(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "yuurih");
		ServerCommand("bot_add_ct %s", "arT");
		ServerCommand("bot_add_ct %s", "VINI");
		ServerCommand("bot_add_ct %s", "KSCERATO");
		ServerCommand("bot_add_ct %s", "HEN1");
		ServerCommand("mp_teamlogo_1 furi");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "yuurih");
		ServerCommand("bot_add_t %s", "arT");
		ServerCommand("bot_add_t %s", "VINI");
		ServerCommand("bot_add_t %s", "KSCERATO");
		ServerCommand("bot_add_t %s", "HEN1");
		ServerCommand("mp_teamlogo_2 furi");
	}
	
	return Plugin_Handled;
}

public Action Team_c0ntact(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Snappi");
		ServerCommand("bot_add_ct %s", "ottoNd");
		ServerCommand("bot_add_ct %s", "rigoN");
		ServerCommand("bot_add_ct %s", "Spinx");
		ServerCommand("bot_add_ct %s", "EspiranTo");
		ServerCommand("mp_teamlogo_1 c0n");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Snappi");
		ServerCommand("bot_add_t %s", "ottoNd");
		ServerCommand("bot_add_t %s", "rigoN");
		ServerCommand("bot_add_t %s", "Spinx");
		ServerCommand("bot_add_t %s", "EspiranTo");
		ServerCommand("mp_teamlogo_2 c0n");
	}
	
	return Plugin_Handled;
}

public Action Team_coL(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "k0nfig");
		ServerCommand("bot_add_ct %s", "poizon");
		ServerCommand("bot_add_ct %s", "jks");
		ServerCommand("bot_add_ct %s", "RUSH");
		ServerCommand("bot_add_ct %s", "blameF");
		ServerCommand("mp_teamlogo_1 col");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "k0nfig");
		ServerCommand("bot_add_t %s", "poizon");
		ServerCommand("bot_add_t %s", "jks");
		ServerCommand("bot_add_t %s", "RUSH");
		ServerCommand("bot_add_t %s", "blameF");
		ServerCommand("mp_teamlogo_2 col");
	}
	
	return Plugin_Handled;
}

public Action Team_ViCi(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "zhokiNg");
		ServerCommand("bot_add_ct %s", "kaze");
		ServerCommand("bot_add_ct %s", "aumaN");
		ServerCommand("bot_add_ct %s", "JamYoung");
		ServerCommand("bot_add_ct %s", "advent");
		ServerCommand("mp_teamlogo_1 vici");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "zhokiNg");
		ServerCommand("bot_add_t %s", "kaze");
		ServerCommand("bot_add_t %s", "aumaN");
		ServerCommand("bot_add_t %s", "JamYoung");
		ServerCommand("bot_add_t %s", "advent");
		ServerCommand("mp_teamlogo_2 vici");
	}
	
	return Plugin_Handled;
}

public Action Team_forZe(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "facecrack");
		ServerCommand("bot_add_ct %s", "xsepower");
		ServerCommand("bot_add_ct %s", "FL1T");
		ServerCommand("bot_add_ct %s", "almazer");
		ServerCommand("bot_add_ct %s", "Jerry");
		ServerCommand("mp_teamlogo_1 forz");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "facecrack");
		ServerCommand("bot_add_t %s", "xsepower");
		ServerCommand("bot_add_t %s", "FL1T");
		ServerCommand("bot_add_t %s", "almazer");
		ServerCommand("bot_add_t %s", "Jerry");
		ServerCommand("mp_teamlogo_2 forz");
	}
	
	return Plugin_Handled;
}

public Action Team_Winstrike(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Lack1");
		ServerCommand("bot_add_ct %s", "KrizzeN");
		ServerCommand("bot_add_ct %s", "NickelBack");
		ServerCommand("bot_add_ct %s", "El1an");
		ServerCommand("bot_add_ct %s", "bondik");
		ServerCommand("mp_teamlogo_1 win");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Lack1");
		ServerCommand("bot_add_t %s", "KrizzeN");
		ServerCommand("bot_add_t %s", "NickelBack");
		ServerCommand("bot_add_t %s", "El1an");
		ServerCommand("bot_add_t %s", "bondik");
		ServerCommand("mp_teamlogo_2 win");
	}
	
	return Plugin_Handled;
}

public Action Team_Sprout(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "snatchie");
		ServerCommand("bot_add_ct %s", "dycha");
		ServerCommand("bot_add_ct %s", "Spiidi");
		ServerCommand("bot_add_ct %s", "faveN");
		ServerCommand("bot_add_ct %s", "denis");
		ServerCommand("mp_teamlogo_1 spr");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "snatchie");
		ServerCommand("bot_add_t %s", "dycha");
		ServerCommand("bot_add_t %s", "Spiidi");
		ServerCommand("bot_add_t %s", "faveN");
		ServerCommand("bot_add_t %s", "denis");
		ServerCommand("mp_teamlogo_2 spr");
	}
	
	return Plugin_Handled;
}

public Action Team_Heroic(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "TeSeS");
		ServerCommand("bot_add_ct %s", "b0RUP");
		ServerCommand("bot_add_ct %s", "nikozan");
		ServerCommand("bot_add_ct %s", "cadiaN");
		ServerCommand("bot_add_ct %s", "stavn");
		ServerCommand("mp_teamlogo_1 heroi");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "TeSeS");
		ServerCommand("bot_add_t %s", "b0RUP");
		ServerCommand("bot_add_t %s", "nikozan");
		ServerCommand("bot_add_t %s", "cadiaN");
		ServerCommand("bot_add_t %s", "stavn");
		ServerCommand("mp_teamlogo_2 heroi");
	}
	
	return Plugin_Handled;
}

public Action Team_INTZ(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "guZERA");
		ServerCommand("bot_add_ct %s", "BALEROSTYLE");
		ServerCommand("bot_add_ct %s", "dukka");
		ServerCommand("bot_add_ct %s", "paredao");
		ServerCommand("bot_add_ct %s", "chara");
		ServerCommand("mp_teamlogo_1 intz");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "guZERA");
		ServerCommand("bot_add_t %s", "BALEROSTYLE");
		ServerCommand("bot_add_t %s", "dukka");
		ServerCommand("bot_add_t %s", "paredao");
		ServerCommand("bot_add_t %s", "chara");
		ServerCommand("mp_teamlogo_2 intz");
	}
	
	return Plugin_Handled;
}

public Action Team_VP(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "YEKINDAR");
		ServerCommand("bot_add_ct %s", "Jame");
		ServerCommand("bot_add_ct %s", "qikert");
		ServerCommand("bot_add_ct %s", "SANJI");
		ServerCommand("bot_add_ct %s", "buster");
		ServerCommand("mp_teamlogo_1 virtus");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "YEKINDAR");
		ServerCommand("bot_add_t %s", "Jame");
		ServerCommand("bot_add_t %s", "qikert");
		ServerCommand("bot_add_t %s", "SANJI");
		ServerCommand("bot_add_t %s", "buster");
		ServerCommand("mp_teamlogo_2 virtus");
	}
	
	return Plugin_Handled;
}

public Action Team_Apeks(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Marcelious");
		ServerCommand("bot_add_ct %s", "jkaem");
		ServerCommand("bot_add_ct %s", "Grusarn");
		ServerCommand("bot_add_ct %s", "Nasty");
		ServerCommand("bot_add_ct %s", "dennis");
		ServerCommand("mp_teamlogo_1 ape");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Marcelious");
		ServerCommand("bot_add_t %s", "jkaem");
		ServerCommand("bot_add_t %s", "Grusarn");
		ServerCommand("bot_add_t %s", "Nasty");
		ServerCommand("bot_add_t %s", "dennis");
		ServerCommand("mp_teamlogo_2 ape");
	}
	
	return Plugin_Handled;
}

public Action Team_aTTaX(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "stfN");
		ServerCommand("bot_add_ct %s", "slaxz");
		ServerCommand("bot_add_ct %s", "ScrunK");
		ServerCommand("bot_add_ct %s", "kressy");
		ServerCommand("bot_add_ct %s", "mirbit");
		ServerCommand("mp_teamlogo_1 alt");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "stfN");
		ServerCommand("bot_add_t %s", "slaxz");
		ServerCommand("bot_add_t %s", "ScrunK");
		ServerCommand("bot_add_t %s", "kressy");
		ServerCommand("bot_add_t %s", "mirbit");
		ServerCommand("mp_teamlogo_2 alt");
	}
	
	return Plugin_Handled;
}

public Action Team_Renegades(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "INS");
		ServerCommand("bot_add_ct %s", "sico");
		ServerCommand("bot_add_ct %s", "dexter");
		ServerCommand("bot_add_ct %s", "Hatz");
		ServerCommand("bot_add_ct %s", "malta");
		ServerCommand("mp_teamlogo_1 ren");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "INS");
		ServerCommand("bot_add_t %s", "sico");
		ServerCommand("bot_add_t %s", "dexter");
		ServerCommand("bot_add_t %s", "Hatz");
		ServerCommand("bot_add_t %s", "malta");
		ServerCommand("mp_teamlogo_2 ren");
	}
	
	return Plugin_Handled;
}

public Action Team_Envy(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Nifty");
		ServerCommand("bot_add_ct %s", "Thomas");
		ServerCommand("bot_add_ct %s", "Calyx");
		ServerCommand("bot_add_ct %s", "MICHU");
		ServerCommand("bot_add_ct %s", "LEGIJA");
		ServerCommand("mp_teamlogo_1 envy");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Nifty");
		ServerCommand("bot_add_t %s", "Thomas");
		ServerCommand("bot_add_t %s", "Calyx");
		ServerCommand("bot_add_t %s", "MICHU");
		ServerCommand("bot_add_t %s", "LEGIJA");
		ServerCommand("mp_teamlogo_2 envy");
	}
	
	return Plugin_Handled;
}

public Action Team_Spirit(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "mir");
		ServerCommand("bot_add_ct %s", "iDISBALANCE");
		ServerCommand("bot_add_ct %s", "somedieyoung");
		ServerCommand("bot_add_ct %s", "chopper");
		ServerCommand("bot_add_ct %s", "magixx");
		ServerCommand("mp_teamlogo_1 spir");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "mir");
		ServerCommand("bot_add_t %s", "iDISBALANCE");
		ServerCommand("bot_add_t %s", "somedieyoung");
		ServerCommand("bot_add_t %s", "chopper");
		ServerCommand("bot_add_t %s", "magixx");
		ServerCommand("mp_teamlogo_2 spir");
	}
	
	return Plugin_Handled;
}

public Action Team_LDLC(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "afroo");
		ServerCommand("bot_add_ct %s", "Lambert");
		ServerCommand("bot_add_ct %s", "hAdji");
		ServerCommand("bot_add_ct %s", "bodyy");
		ServerCommand("bot_add_ct %s", "SIXER");
		ServerCommand("mp_teamlogo_1 ldl");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "afroo");
		ServerCommand("bot_add_t %s", "Lambert");
		ServerCommand("bot_add_t %s", "hAdji");
		ServerCommand("bot_add_t %s", "bodyy");
		ServerCommand("bot_add_t %s", "SIXER");
		ServerCommand("mp_teamlogo_2 ldl");
	}
	
	return Plugin_Handled;
}

public Action Team_GamerLegion(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "dobbo");
		ServerCommand("bot_add_ct %s", "eraa");
		ServerCommand("bot_add_ct %s", "Zero");
		ServerCommand("bot_add_ct %s", "RuStY");
		ServerCommand("bot_add_ct %s", "Adam9130");
		ServerCommand("mp_teamlogo_1 glegion");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "dobbo");
		ServerCommand("bot_add_t %s", "eraa");
		ServerCommand("bot_add_t %s", "Zero");
		ServerCommand("bot_add_t %s", "RuStY");
		ServerCommand("bot_add_t %s", "Adam9130");
		ServerCommand("mp_teamlogo_2 glegion");
	}
	
	return Plugin_Handled;
}

public Action Team_Wolsung(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "hyskeee");
		ServerCommand("bot_add_ct %s", "rAW");
		ServerCommand("bot_add_ct %s", "Gekons");
		ServerCommand("bot_add_ct %s", "keen");
		ServerCommand("bot_add_ct %s", "shield");
		ServerCommand("mp_teamlogo_1 wols");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "hyskeee");
		ServerCommand("bot_add_t %s", "rAW");
		ServerCommand("bot_add_t %s", "Gekons");
		ServerCommand("bot_add_t %s", "keen");
		ServerCommand("bot_add_t %s", "shield");
		ServerCommand("mp_teamlogo_2 wols");
	}
	
	return Plugin_Handled;
}

public Action Team_PDucks(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "ChLo");
		ServerCommand("bot_add_ct %s", "sTaR");
		ServerCommand("bot_add_ct %s", "wizzem");
		ServerCommand("bot_add_ct %s", "maxz");
		ServerCommand("bot_add_ct %s", "Cl34v3rs");
		ServerCommand("mp_teamlogo_1 playin");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "ChLo");
		ServerCommand("bot_add_t %s", "sTaR");
		ServerCommand("bot_add_t %s", "wizzem");
		ServerCommand("bot_add_t %s", "maxz");
		ServerCommand("bot_add_t %s", "Cl34v3rs");
		ServerCommand("mp_teamlogo_2 playin");
	}
	
	return Plugin_Handled;
}

public Action Team_HAVU(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "ZOREE");
		ServerCommand("bot_add_ct %s", "sLowi");
		ServerCommand("bot_add_ct %s", "doto");
		ServerCommand("bot_add_ct %s", "xseveN");
		ServerCommand("bot_add_ct %s", "sAw");
		ServerCommand("mp_teamlogo_1 havu");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "ZOREE");
		ServerCommand("bot_add_t %s", "sLowi");
		ServerCommand("bot_add_t %s", "doto");
		ServerCommand("bot_add_t %s", "xseveN");
		ServerCommand("bot_add_t %s", "sAw");
		ServerCommand("mp_teamlogo_2 havu");
	}
	
	return Plugin_Handled;
}

public Action Team_Lyngby(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "birdfromsky");
		ServerCommand("bot_add_ct %s", "Twinx");
		ServerCommand("bot_add_ct %s", "Maccen");
		ServerCommand("bot_add_ct %s", "Raalz");
		ServerCommand("bot_add_ct %s", "Cabbi");
		ServerCommand("mp_teamlogo_1 lyng");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "birdfromsky");
		ServerCommand("bot_add_t %s", "Twinx");
		ServerCommand("bot_add_t %s", "Maccen");
		ServerCommand("bot_add_t %s", "Raalz");
		ServerCommand("bot_add_t %s", "Cabbi");
		ServerCommand("mp_teamlogo_2 lyng");
	}
	
	return Plugin_Handled;
}

public Action Team_GODSENT(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "maden");
		ServerCommand("bot_add_ct %s", "farlig");
		ServerCommand("bot_add_ct %s", "kRYSTAL");
		ServerCommand("bot_add_ct %s", "zehN");
		ServerCommand("bot_add_ct %s", "STYKO");
		ServerCommand("mp_teamlogo_1 god");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "maden");
		ServerCommand("bot_add_t %s", "farlig");
		ServerCommand("bot_add_t %s", "kRYSTAL");
		ServerCommand("bot_add_t %s", "zehN");
		ServerCommand("bot_add_t %s", "STYKO");
		ServerCommand("mp_teamlogo_2 god");
	}
	
	return Plugin_Handled;
}

public Action Team_Nordavind(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "bfr");
		ServerCommand("bot_add_ct %s", "NaToSaphiX");
		ServerCommand("bot_add_ct %s", "sense");
		ServerCommand("bot_add_ct %s", "Rytter");
		ServerCommand("bot_add_ct %s", "cromen");
		ServerCommand("mp_teamlogo_1 nord");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "bfr");
		ServerCommand("bot_add_t %s", "NaToSaphiX");
		ServerCommand("bot_add_t %s", "sense");
		ServerCommand("bot_add_t %s", "Rytter");
		ServerCommand("bot_add_t %s", "cromen");
		ServerCommand("mp_teamlogo_2 nord");
	}
	
	return Plugin_Handled;
}

public Action Team_SJ(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "arvid");
		ServerCommand("bot_add_ct %s", "LYNXi");
		ServerCommand("bot_add_ct %s", "SADDYX");
		ServerCommand("bot_add_ct %s", "KHRN");
		ServerCommand("bot_add_ct %s", "jemi");
		ServerCommand("mp_teamlogo_1 sjg");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "arvid");
		ServerCommand("bot_add_t %s", "LYNXi");
		ServerCommand("bot_add_t %s", "SADDYX");
		ServerCommand("bot_add_t %s", "KHRN");
		ServerCommand("bot_add_t %s", "jemi");
		ServerCommand("mp_teamlogo_2 sjg");
	}
	
	return Plugin_Handled;
}

public Action Team_Bren(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Papichulo");
		ServerCommand("bot_add_ct %s", "witz");
		ServerCommand("bot_add_ct %s", "Pro.");
		ServerCommand("bot_add_ct %s", "JA");
		ServerCommand("bot_add_ct %s", "Derek");
		ServerCommand("mp_teamlogo_1 bren");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Papichulo");
		ServerCommand("bot_add_t %s", "witz");
		ServerCommand("bot_add_t %s", "Pro.");
		ServerCommand("bot_add_t %s", "JA");
		ServerCommand("bot_add_t %s", "Derek");
		ServerCommand("mp_teamlogo_2 bren");
	}
	
	return Plugin_Handled;
}

public Action Team_Giants(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "NOPEEj");
		ServerCommand("bot_add_ct %s", "fox");
		ServerCommand("bot_add_ct %s", "pr");
		ServerCommand("bot_add_ct %s", "obj");
		ServerCommand("bot_add_ct %s", "RIZZ");
		ServerCommand("mp_teamlogo_1 giant");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "NOPEEj");
		ServerCommand("bot_add_t %s", "fox");
		ServerCommand("bot_add_t %s", "pr");
		ServerCommand("bot_add_t %s", "obj");
		ServerCommand("bot_add_t %s", "RIZZ");
		ServerCommand("mp_teamlogo_2 giant");
	}
	
	return Plugin_Handled;
}

public Action Team_Lions(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "HooXi");
		ServerCommand("bot_add_ct %s", "acoR");
		ServerCommand("bot_add_ct %s", "Sjuush");
		ServerCommand("bot_add_ct %s", "refrezh");
		ServerCommand("bot_add_ct %s", "roeJ");
		ServerCommand("mp_teamlogo_1 lion");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "HooXi");
		ServerCommand("bot_add_t %s", "acoR");
		ServerCommand("bot_add_t %s", "Sjuush");
		ServerCommand("bot_add_t %s", "refrezh");
		ServerCommand("bot_add_t %s", "roeJ");
		ServerCommand("mp_teamlogo_2 lion");
	}
	
	return Plugin_Handled;
}

public Action Team_Riders(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "mopoz");
		ServerCommand("bot_add_ct %s", "shokz");
		ServerCommand("bot_add_ct %s", "steel");
		ServerCommand("bot_add_ct %s", "\"alex*\"");
		ServerCommand("bot_add_ct %s", "larsen");
		ServerCommand("mp_teamlogo_1 movis");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "mopoz");
		ServerCommand("bot_add_t %s", "shokz");
		ServerCommand("bot_add_t %s", "steel");
		ServerCommand("bot_add_t %s", "\"alex*\"");
		ServerCommand("bot_add_t %s", "larsen");
		ServerCommand("mp_teamlogo_2 movis");
	}
	
	return Plugin_Handled;
}

public Action Team_OFFSET(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "rafaxF");
		ServerCommand("bot_add_ct %s", "KILLDREAM");
		ServerCommand("bot_add_ct %s", "EasTor");
		ServerCommand("bot_add_ct %s", "ZELIN");
		ServerCommand("bot_add_ct %s", "drifking");
		ServerCommand("mp_teamlogo_1 offs");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "rafaxF");
		ServerCommand("bot_add_t %s", "KILLDREAM");
		ServerCommand("bot_add_t %s", "EasTor");
		ServerCommand("bot_add_t %s", "ZELIN");
		ServerCommand("bot_add_t %s", "drifking");
		ServerCommand("mp_teamlogo_2 offs");
	}
	
	return Plugin_Handled;
}

public Action Team_eSuba(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "NIO");
		ServerCommand("bot_add_ct %s", "Levi");
		ServerCommand("bot_add_ct %s", "\"The eLiVe\"");
		ServerCommand("bot_add_ct %s", "Blogg1s");
		ServerCommand("bot_add_ct %s", "luko");
		ServerCommand("mp_teamlogo_1 esu");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "NIO");
		ServerCommand("bot_add_t %s", "Levi");
		ServerCommand("bot_add_t %s", "\"The eLiVe\"");
		ServerCommand("bot_add_t %s", "Blogg1s");
		ServerCommand("bot_add_t %s", "luko");
		ServerCommand("mp_teamlogo_2 esu");
	}
	
	return Plugin_Handled;
}

public Action Team_Nexus(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "BTN");
		ServerCommand("bot_add_ct %s", "XELLOW");
		ServerCommand("bot_add_ct %s", "SEMINTE");
		ServerCommand("bot_add_ct %s", "iM");
		ServerCommand("bot_add_ct %s", "sXe");
		ServerCommand("mp_teamlogo_1 nex");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "BTN");
		ServerCommand("bot_add_t %s", "XELLOW");
		ServerCommand("bot_add_t %s", "SEMINTE");
		ServerCommand("bot_add_t %s", "iM");
		ServerCommand("bot_add_t %s", "sXe");
		ServerCommand("mp_teamlogo_2 nex");
	}
	
	return Plugin_Handled;
}

public Action Team_PACT(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "darko");
		ServerCommand("bot_add_ct %s", "lunAtic");
		ServerCommand("bot_add_ct %s", "Goofy");
		ServerCommand("bot_add_ct %s", "MINISE");
		ServerCommand("bot_add_ct %s", "Sobol");
		ServerCommand("mp_teamlogo_1 pact");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "darko");
		ServerCommand("bot_add_t %s", "lunAtic");
		ServerCommand("bot_add_t %s", "Goofy");
		ServerCommand("bot_add_t %s", "MINISE");
		ServerCommand("bot_add_t %s", "Sobol");
		ServerCommand("mp_teamlogo_2 pact");
	}
	
	return Plugin_Handled;
}

public Action Team_Heretics(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Python");
		ServerCommand("bot_add_ct %s", "Maka");
		ServerCommand("bot_add_ct %s", "DEVIL");
		ServerCommand("bot_add_ct %s", "kioShiMa");
		ServerCommand("bot_add_ct %s", "Lucky");
		ServerCommand("mp_teamlogo_1 here");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Python");
		ServerCommand("bot_add_t %s", "Maka");
		ServerCommand("bot_add_t %s", "DEVIL");
		ServerCommand("bot_add_t %s", "kioShiMa");
		ServerCommand("bot_add_t %s", "Lucky");
		ServerCommand("mp_teamlogo_2 here");
	}
	
	return Plugin_Handled;
}

public Action Team_Nemiga(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "speed4k");
		ServerCommand("bot_add_ct %s", "mds");
		ServerCommand("bot_add_ct %s", "lollipop21k");
		ServerCommand("bot_add_ct %s", "Jyo");
		ServerCommand("bot_add_ct %s", "boX");
		ServerCommand("mp_teamlogo_1 nem");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "speed4k");
		ServerCommand("bot_add_t %s", "mds");
		ServerCommand("bot_add_t %s", "lollipop21k");
		ServerCommand("bot_add_t %s", "Jyo");
		ServerCommand("bot_add_t %s", "boX");
		ServerCommand("mp_teamlogo_2 nem");
	}
	
	return Plugin_Handled;
}

public Action Team_pro100(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "dimasick");
		ServerCommand("bot_add_ct %s", "WorldEdit");
		ServerCommand("bot_add_ct %s", "pipsoN");
		ServerCommand("bot_add_ct %s", "wayLander");
		ServerCommand("bot_add_ct %s", "AiyvaN");
		ServerCommand("mp_teamlogo_1 pro");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "dimasick");
		ServerCommand("bot_add_t %s", "WorldEdit");
		ServerCommand("bot_add_t %s", "pipsoN");
		ServerCommand("bot_add_t %s", "wayLander");
		ServerCommand("bot_add_t %s", "AiyvaN");
		ServerCommand("mp_teamlogo_2 pro");
	}
	
	return Plugin_Handled;
}

public Action Team_YaLLa(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Remind");
		ServerCommand("bot_add_ct %s", "eku");
		ServerCommand("bot_add_ct %s", "Kheops");
		ServerCommand("bot_add_ct %s", "Senpai");
		ServerCommand("bot_add_ct %s", "Lyhn");
		ServerCommand("mp_teamlogo_1 yall");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Remind");
		ServerCommand("bot_add_t %s", "eku");
		ServerCommand("bot_add_t %s", "Kheops");
		ServerCommand("bot_add_t %s", "Senpai");
		ServerCommand("bot_add_t %s", "Lyhn");
		ServerCommand("mp_teamlogo_2 yall");
	}
	
	return Plugin_Handled;
}

public Action Team_Yeah(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "bew");
		ServerCommand("bot_add_ct %s", "RCF");
		ServerCommand("bot_add_ct %s", "f4stzin");
		ServerCommand("bot_add_ct %s", "Swisher");
		ServerCommand("bot_add_ct %s", "dumau");
		ServerCommand("mp_teamlogo_1 yeah");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "bew");
		ServerCommand("bot_add_t %s", "RCF");
		ServerCommand("bot_add_t %s", "f4stzin");
		ServerCommand("bot_add_t %s", "Swisher");
		ServerCommand("bot_add_t %s", "dumau");
		ServerCommand("mp_teamlogo_2 yeah");
	}
	
	return Plugin_Handled;
}

public Action Team_Singularity(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Casle");
		ServerCommand("bot_add_ct %s", "notaN");
		ServerCommand("bot_add_ct %s", "Remoy");
		ServerCommand("bot_add_ct %s", "TOBIZ");
		ServerCommand("bot_add_ct %s", "Celrate");
		ServerCommand("mp_teamlogo_1 sing");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Casle");
		ServerCommand("bot_add_t %s", "notaN");
		ServerCommand("bot_add_t %s", "Remoy");
		ServerCommand("bot_add_t %s", "TOBIZ");
		ServerCommand("bot_add_t %s", "Celrate");
		ServerCommand("mp_teamlogo_2 sing");
	}
	
	return Plugin_Handled;
}

public Action Team_DETONA(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "nak");
		ServerCommand("bot_add_ct %s", "piria");
		ServerCommand("bot_add_ct %s", "rikz");
		ServerCommand("bot_add_ct %s", "tiburci0");
		ServerCommand("bot_add_ct %s", "zevy");
		ServerCommand("mp_teamlogo_1 deto");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "nak");
		ServerCommand("bot_add_t %s", "piria");
		ServerCommand("bot_add_t %s", "rikz");
		ServerCommand("bot_add_t %s", "tiburci0");
		ServerCommand("bot_add_t %s", "zevy");
		ServerCommand("mp_teamlogo_2 deto");
	}
	
	return Plugin_Handled;
}

public Action Team_Infinity(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "k1Nky");
		ServerCommand("bot_add_ct %s", "tor1towOw");
		ServerCommand("bot_add_ct %s", "spamzzy");
		ServerCommand("bot_add_ct %s", "chuti");
		ServerCommand("bot_add_ct %s", "points");
		ServerCommand("mp_teamlogo_1 infi");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "k1Nky");
		ServerCommand("bot_add_t %s", "tor1towOw");
		ServerCommand("bot_add_t %s", "spamzzy");
		ServerCommand("bot_add_t %s", "chuti");
		ServerCommand("bot_add_t %s", "points");
		ServerCommand("mp_teamlogo_2 infi");
	}
	
	return Plugin_Handled;
}

public Action Team_Isurus(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "\"JonY BoY\"");
		ServerCommand("bot_add_ct %s", "Noktse");
		ServerCommand("bot_add_ct %s", "Reversive");
		ServerCommand("bot_add_ct %s", "decov9jse");
		ServerCommand("bot_add_ct %s", "caike");
		ServerCommand("mp_teamlogo_1 isu");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "\"JonY BoY\"");
		ServerCommand("bot_add_t %s", "Noktse");
		ServerCommand("bot_add_t %s", "Reversive");
		ServerCommand("bot_add_t %s", "decov9jse");
		ServerCommand("bot_add_t %s", "caike");
		ServerCommand("mp_teamlogo_2 isu");
	}
	
	return Plugin_Handled;
}

public Action Team_paiN(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "PKL");
		ServerCommand("bot_add_ct %s", "saffee");
		ServerCommand("bot_add_ct %s", "NEKIZ");
		ServerCommand("bot_add_ct %s", "biguzera");
		ServerCommand("bot_add_ct %s", "hardzao");
		ServerCommand("mp_teamlogo_1 pain");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "PKL");
		ServerCommand("bot_add_t %s", "saffee");
		ServerCommand("bot_add_t %s", "NEKIZ");
		ServerCommand("bot_add_t %s", "biguzera");
		ServerCommand("bot_add_t %s", "hardzao");
		ServerCommand("mp_teamlogo_2 pain");
	}
	
	return Plugin_Handled;
}

public Action Team_Sharks(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "pancc");
		ServerCommand("bot_add_ct %s", "jnt");
		ServerCommand("bot_add_ct %s", "Lucaozy");
		ServerCommand("bot_add_ct %s", "exit");
		ServerCommand("bot_add_ct %s", "danoco");
		ServerCommand("mp_teamlogo_1 shark");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "pancc");
		ServerCommand("bot_add_t %s", "jnt");
		ServerCommand("bot_add_t %s", "Lucaozy");
		ServerCommand("bot_add_t %s", "exit");
		ServerCommand("bot_add_t %s", "danoco");
		ServerCommand("mp_teamlogo_2 shark");
	}
	
	return Plugin_Handled;
}

public Action Team_One(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "prt");
		ServerCommand("bot_add_ct %s", "Maluk3");
		ServerCommand("bot_add_ct %s", "malbsMd");
		ServerCommand("bot_add_ct %s", "pesadelo");
		ServerCommand("bot_add_ct %s", "b4rtiN");
		ServerCommand("mp_teamlogo_1 tone");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "prt");
		ServerCommand("bot_add_t %s", "Maluk3");
		ServerCommand("bot_add_t %s", "malbsMd");
		ServerCommand("bot_add_t %s", "pesadelo");
		ServerCommand("bot_add_t %s", "b4rtiN");
		ServerCommand("mp_teamlogo_2 tone");
	}
	
	return Plugin_Handled;
}

public Action Team_W7M(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "skullz");
		ServerCommand("bot_add_ct %s", "raafa");
		ServerCommand("bot_add_ct %s", "cass1n");
		ServerCommand("bot_add_ct %s", "tatazin");
		ServerCommand("bot_add_ct %s", "realziN");
		ServerCommand("mp_teamlogo_1 w7m");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "skullz");
		ServerCommand("bot_add_t %s", "raafa");
		ServerCommand("bot_add_t %s", "cass1n");
		ServerCommand("bot_add_t %s", "tatazin");
		ServerCommand("bot_add_t %s", "realziN");
		ServerCommand("mp_teamlogo_2 w7m");
	}
	
	return Plugin_Handled;
}

public Action Team_Avant(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "BL1TZ");
		ServerCommand("bot_add_ct %s", "sterling");
		ServerCommand("bot_add_ct %s", "apoc");
		ServerCommand("bot_add_ct %s", "ofnu");
		ServerCommand("bot_add_ct %s", "HaZR");
		ServerCommand("mp_teamlogo_1 avant");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "BL1TZ");
		ServerCommand("bot_add_t %s", "sterling");
		ServerCommand("bot_add_t %s", "apoc");
		ServerCommand("bot_add_t %s", "ofnu");
		ServerCommand("bot_add_t %s", "HaZR");
		ServerCommand("mp_teamlogo_2 avant");
	}
	
	return Plugin_Handled;
}

public Action Team_Chiefs(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "HUGHMUNGUS");
		ServerCommand("bot_add_ct %s", "Vexite");
		ServerCommand("bot_add_ct %s", "apocdud");
		ServerCommand("bot_add_ct %s", "zeph");
		ServerCommand("bot_add_ct %s", "soju_j");
		ServerCommand("mp_teamlogo_1 chief");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "HUGHMUNGUS");
		ServerCommand("bot_add_t %s", "Vexite");
		ServerCommand("bot_add_t %s", "apocdud");
		ServerCommand("bot_add_t %s", "zeph");
		ServerCommand("bot_add_t %s", "soju_j");
		ServerCommand("mp_teamlogo_2 chief");
	}
	
	return Plugin_Handled;
}

public Action Team_ORDER(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "J1rah");
		ServerCommand("bot_add_ct %s", "aliStair");
		ServerCommand("bot_add_ct %s", "Rickeh");
		ServerCommand("bot_add_ct %s", "USTILO");
		ServerCommand("bot_add_ct %s", "Valiance");
		ServerCommand("mp_teamlogo_1 order");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "J1rah");
		ServerCommand("bot_add_t %s", "aliStair");
		ServerCommand("bot_add_t %s", "Rickeh");
		ServerCommand("bot_add_t %s", "USTILO");
		ServerCommand("bot_add_t %s", "Valiance");
		ServerCommand("mp_teamlogo_2 order");
	}
	
	return Plugin_Handled;
}

public Action Team_SKADE(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Duplicate");
		ServerCommand("bot_add_ct %s", "dennyslaw");
		ServerCommand("bot_add_ct %s", "Oxygen");
		ServerCommand("bot_add_ct %s", "Rainwaker");
		ServerCommand("bot_add_ct %s", "SPELLAN");
		ServerCommand("mp_teamlogo_1 ska");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Duplicate");
		ServerCommand("bot_add_t %s", "dennyslaw");
		ServerCommand("bot_add_t %s", "Oxygen");
		ServerCommand("bot_add_t %s", "Rainwaker");
		ServerCommand("bot_add_t %s", "SPELLAN");
		ServerCommand("mp_teamlogo_2 ska");
	}
	
	return Plugin_Handled;
}

public Action Team_Paradox(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "rbz");
		ServerCommand("bot_add_ct %s", "Versa");
		ServerCommand("bot_add_ct %s", "ekul");
		ServerCommand("bot_add_ct %s", "bedonka");
		ServerCommand("bot_add_ct %s", "dangeR");
		ServerCommand("mp_teamlogo_1 para");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "rbz");
		ServerCommand("bot_add_t %s", "Versa");
		ServerCommand("bot_add_t %s", "ekul");
		ServerCommand("bot_add_t %s", "bedonka");
		ServerCommand("bot_add_t %s", "dangeR");
		ServerCommand("mp_teamlogo_2 para");
	}
	
	return Plugin_Handled;
}

public Action Team_Beyond(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "MAIROLLS");
		ServerCommand("bot_add_ct %s", "Olivia");
		ServerCommand("bot_add_ct %s", "Kntz");
		ServerCommand("bot_add_ct %s", "stk");
		ServerCommand("bot_add_ct %s", "Geniuss");
		ServerCommand("mp_teamlogo_1 bey");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "MAIROLLS");
		ServerCommand("bot_add_t %s", "Olivia");
		ServerCommand("bot_add_t %s", "Kntz");
		ServerCommand("bot_add_t %s", "stk");
		ServerCommand("bot_add_t %s", "Geniuss");
		ServerCommand("mp_teamlogo_2 bey");
	}
	
	return Plugin_Handled;
}

public Action Team_BOOM(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "chelo");
		ServerCommand("bot_add_ct %s", "yeL");
		ServerCommand("bot_add_ct %s", "shz");
		ServerCommand("bot_add_ct %s", "boltz");
		ServerCommand("bot_add_ct %s", "felps");
		ServerCommand("mp_teamlogo_1 boom");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "chelo");
		ServerCommand("bot_add_t %s", "yeL");
		ServerCommand("bot_add_t %s", "shz");
		ServerCommand("bot_add_t %s", "boltz");
		ServerCommand("bot_add_t %s", "felps");
		ServerCommand("mp_teamlogo_2 boom");
	}
	
	return Plugin_Handled;
}

public Action Team_NASR(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "proxyyb");
		ServerCommand("bot_add_ct %s", "Real1ze");
		ServerCommand("bot_add_ct %s", "BOROS");
		ServerCommand("bot_add_ct %s", "Dementor");
		ServerCommand("bot_add_ct %s", "Just1ce");
		ServerCommand("mp_teamlogo_1 nasr");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "proxyyb");
		ServerCommand("bot_add_t %s", "Real1ze");
		ServerCommand("bot_add_t %s", "BOROS");
		ServerCommand("bot_add_t %s", "Dementor");
		ServerCommand("bot_add_t %s", "Just1ce");
		ServerCommand("mp_teamlogo_2 nasr");
	}
	
	return Plugin_Handled;
}

public Action Team_TTT(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "dukiiii");
		ServerCommand("bot_add_ct %s", "powerYY");
		ServerCommand("bot_add_ct %s", "KrowNii");
		ServerCommand("bot_add_ct %s", "pulzG");
		ServerCommand("bot_add_ct %s", "syncD");
		ServerCommand("mp_teamlogo_1 ttt");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "dukiiii");
		ServerCommand("bot_add_t %s", "powerYY");
		ServerCommand("bot_add_t %s", "KrowNii");
		ServerCommand("bot_add_t %s", "pulzG");
		ServerCommand("bot_add_t %s", "syncD");
		ServerCommand("mp_teamlogo_2 ttt");
	}
	
	return Plugin_Handled;
}

public Action Team_PX(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "mindfreak");
		ServerCommand("bot_add_ct %s", "d4v41");
		ServerCommand("bot_add_ct %s", "Benkai");
		ServerCommand("bot_add_ct %s", "Tommy");
		ServerCommand("bot_add_ct %s", "f0rsakeN");
		ServerCommand("mp_teamlogo_1 px");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "mindfreak");
		ServerCommand("bot_add_t %s", "d4v41");
		ServerCommand("bot_add_t %s", "Benkai");
		ServerCommand("bot_add_t %s", "Tommy");
		ServerCommand("bot_add_t %s", "f0rsakeN");
		ServerCommand("mp_teamlogo_2 px");
	}
	
	return Plugin_Handled;
}

public Action Team_nxl(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "soifong");
		ServerCommand("bot_add_ct %s", "Foscmorc");
		ServerCommand("bot_add_ct %s", "frgd[ibtJ]");
		ServerCommand("bot_add_ct %s", "Lmemore");
		ServerCommand("bot_add_ct %s", "xera");
		ServerCommand("mp_teamlogo_1 nxl");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "soifong");
		ServerCommand("bot_add_t %s", "Foscmorc");
		ServerCommand("bot_add_t %s", "frgd[ibtJ]");
		ServerCommand("bot_add_t %s", "Lmemore");
		ServerCommand("bot_add_t %s", "xera");
		ServerCommand("mp_teamlogo_2 nxl");
	}
	
	return Plugin_Handled;
}

public Action Team_DV(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "TTyke");
		ServerCommand("bot_add_ct %s", "DVDOV");
		ServerCommand("bot_add_ct %s", "PokemoN");
		ServerCommand("bot_add_ct %s", "Ejram");
		ServerCommand("bot_add_ct %s", "Pogba");
		ServerCommand("mp_teamlogo_1 dv");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "TTyke");
		ServerCommand("bot_add_t %s", "DVDOV");
		ServerCommand("bot_add_t %s", "PokemoN");
		ServerCommand("bot_add_t %s", "Ejram");
		ServerCommand("bot_add_t %s", "Pogba");
		ServerCommand("mp_teamlogo_2 dv");
	}
	
	return Plugin_Handled;
}

public Action Team_energy(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "pnd");
		ServerCommand("bot_add_ct %s", "disTroiT");
		ServerCommand("bot_add_ct %s", "Lichl0rd");
		ServerCommand("bot_add_ct %s", "Tiaantije");
		ServerCommand("bot_add_ct %s", "mango");
		ServerCommand("mp_teamlogo_1 ener");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "pnd");
		ServerCommand("bot_add_t %s", "disTroiT");
		ServerCommand("bot_add_t %s", "Lichl0rd");
		ServerCommand("bot_add_t %s", "Tiaantije");
		ServerCommand("bot_add_t %s", "mango");
		ServerCommand("mp_teamlogo_2 ener");
	}
	
	return Plugin_Handled;
}

public Action Team_Furious(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "nbl");
		ServerCommand("bot_add_ct %s", "tom1");
		ServerCommand("bot_add_ct %s", "Owensinho");
		ServerCommand("bot_add_ct %s", "iKrystal");
		ServerCommand("bot_add_ct %s", "pablek");
		ServerCommand("mp_teamlogo_1 furio");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "nbl");
		ServerCommand("bot_add_t %s", "tom1");
		ServerCommand("bot_add_t %s", "Owensinho");
		ServerCommand("bot_add_t %s", "iKrystal");
		ServerCommand("bot_add_t %s", "pablek");
		ServerCommand("mp_teamlogo_2 furio");
	}
	
	return Plugin_Handled;
}

public Action Team_GroundZero(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "BURNRUOk");
		ServerCommand("bot_add_ct %s", "Laes");
		ServerCommand("bot_add_ct %s", "Llamas");
		ServerCommand("bot_add_ct %s", "Noobster");
		ServerCommand("bot_add_ct %s", "Mayker");
		ServerCommand("mp_teamlogo_1 ground");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "BURNRUOk");
		ServerCommand("bot_add_t %s", "Laes");
		ServerCommand("bot_add_t %s", "Llamas");
		ServerCommand("bot_add_t %s", "Noobster");
		ServerCommand("bot_add_t %s", "Mayker");
		ServerCommand("mp_teamlogo_2 ground");
	}
	
	return Plugin_Handled;
}

public Action Team_AVEZ(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Riczi");
		ServerCommand("bot_add_ct %s", "\"Markoś\"");
		ServerCommand("bot_add_ct %s", "KEi");
		ServerCommand("bot_add_ct %s", "Kylar");
		ServerCommand("bot_add_ct %s", "nawrot");
		ServerCommand("mp_teamlogo_1 avez");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Riczi");
		ServerCommand("bot_add_t %s", "\"Markoś\"");
		ServerCommand("bot_add_t %s", "KEi");
		ServerCommand("bot_add_t %s", "Kylar");
		ServerCommand("bot_add_t %s", "nawrot");
		ServerCommand("mp_teamlogo_2 avez");
	}
	
	return Plugin_Handled;
}

public Action Team_GTZ(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "StepA");
		ServerCommand("bot_add_ct %s", "snapy");
		ServerCommand("bot_add_ct %s", "slaxx");
		ServerCommand("bot_add_ct %s", "Dante");
		ServerCommand("bot_add_ct %s", "fakes2");
		ServerCommand("mp_teamlogo_1 gtz");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "StepA");
		ServerCommand("bot_add_t %s", "snapy");
		ServerCommand("bot_add_t %s", "slaxx");
		ServerCommand("bot_add_t %s", "Dante");
		ServerCommand("bot_add_t %s", "fakes2");
		ServerCommand("mp_teamlogo_2 gtz");
	}
	
	return Plugin_Handled;
}

public Action Team_x6tence(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Queenix");
		ServerCommand("bot_add_ct %s", "tenzki");
		ServerCommand("bot_add_ct %s", "maNkz");
		ServerCommand("bot_add_ct %s", "mertz");
		ServerCommand("bot_add_ct %s", "Nodios");
		ServerCommand("mp_teamlogo_1 x6t");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Queenix");
		ServerCommand("bot_add_t %s", "tenzki");
		ServerCommand("bot_add_t %s", "maNkz");
		ServerCommand("bot_add_t %s", "mertz");
		ServerCommand("bot_add_t %s", "Nodios");
		ServerCommand("mp_teamlogo_2 x6t");
	}
	
	return Plugin_Handled;
}

public Action Team_K23(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "neaLaN");
		ServerCommand("bot_add_ct %s", "mou");
		ServerCommand("bot_add_ct %s", "n0rb3r7");
		ServerCommand("bot_add_ct %s", "kade0");
		ServerCommand("bot_add_ct %s", "Keoz");
		ServerCommand("mp_teamlogo_1 k23");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "neaLaN");
		ServerCommand("bot_add_t %s", "mou");
		ServerCommand("bot_add_t %s", "n0rb3r7");
		ServerCommand("bot_add_t %s", "kade0");
		ServerCommand("bot_add_t %s", "Keoz");
		ServerCommand("mp_teamlogo_2 k23");
	}
	
	return Plugin_Handled;
}

public Action Team_Goliath(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "massacRe");
		ServerCommand("bot_add_ct %s", "Dweezil");
		ServerCommand("bot_add_ct %s", "adM");
		ServerCommand("bot_add_ct %s", "ELUSIVE");
		ServerCommand("bot_add_ct %s", "ZipZip");
		ServerCommand("mp_teamlogo_1 gol");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "massacRe");
		ServerCommand("bot_add_t %s", "Dweezil");
		ServerCommand("bot_add_t %s", "adM");
		ServerCommand("bot_add_t %s", "ELUSIVE");
		ServerCommand("bot_add_t %s", "ZipZip");
		ServerCommand("mp_teamlogo_2 gol");
	}
	
	return Plugin_Handled;
}

public Action Team_UOL(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "crisby");
		ServerCommand("bot_add_ct %s", "kzy");
		ServerCommand("bot_add_ct %s", "Andyy");
		ServerCommand("bot_add_ct %s", "JDC");
		ServerCommand("bot_add_ct %s", "P4TriCK");
		ServerCommand("mp_teamlogo_1 uni");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "crisby");
		ServerCommand("bot_add_t %s", "kzy");
		ServerCommand("bot_add_t %s", "Andyy");
		ServerCommand("bot_add_t %s", "JDC");
		ServerCommand("bot_add_t %s", "P4TriCK");
		ServerCommand("mp_teamlogo_2 uni");
	}
	
	return Plugin_Handled;
}

public Action Team_RADIX(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "mrhui");
		ServerCommand("bot_add_ct %s", "joss");
		ServerCommand("bot_add_ct %s", "brky");
		ServerCommand("bot_add_ct %s", "entz");
		ServerCommand("bot_add_ct %s", "eZo");
		ServerCommand("mp_teamlogo_1 radix");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "mrhui");
		ServerCommand("bot_add_t %s", "joss");
		ServerCommand("bot_add_t %s", "brky");
		ServerCommand("bot_add_t %s", "entz");
		ServerCommand("bot_add_t %s", "eZo");
		ServerCommand("mp_teamlogo_2 radix");
	}
	
	return Plugin_Handled;
}

public Action Team_Illuminar(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Vegi");
		ServerCommand("bot_add_ct %s", "Snax");
		ServerCommand("bot_add_ct %s", "mouz");
		ServerCommand("bot_add_ct %s", "reatz");
		ServerCommand("bot_add_ct %s", "phr");
		ServerCommand("mp_teamlogo_1 illu");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Vegi");
		ServerCommand("bot_add_t %s", "Snax");
		ServerCommand("bot_add_t %s", "mouz");
		ServerCommand("bot_add_t %s", "reatz");
		ServerCommand("bot_add_t %s", "phr");
		ServerCommand("mp_teamlogo_2 illu");
	}
	
	return Plugin_Handled;
}

public Action Team_Queso(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "TheClaran");
		ServerCommand("bot_add_ct %s", "thinkii");
		ServerCommand("bot_add_ct %s", "HUMANZ");
		ServerCommand("bot_add_ct %s", "mik");
		ServerCommand("bot_add_ct %s", "Yaba");
		ServerCommand("mp_teamlogo_1 ques");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "TheClaran");
		ServerCommand("bot_add_t %s", "thinkii");
		ServerCommand("bot_add_t %s", "HUMANZ");
		ServerCommand("bot_add_t %s", "mik");
		ServerCommand("bot_add_t %s", "Yaba");
		ServerCommand("mp_teamlogo_2 ques");
	}
	
	return Plugin_Handled;
}

public Action Team_IG(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "bottle");
		ServerCommand("bot_add_ct %s", "DeStRoYeR");
		ServerCommand("bot_add_ct %s", "flying");
		ServerCommand("bot_add_ct %s", "Viva");
		ServerCommand("bot_add_ct %s", "XiaosaGe");
		ServerCommand("mp_teamlogo_1 ig");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "bottle");
		ServerCommand("bot_add_t %s", "DeStRoYeR");
		ServerCommand("bot_add_t %s", "flying");
		ServerCommand("bot_add_t %s", "Viva");
		ServerCommand("bot_add_t %s", "XiaosaGe");
		ServerCommand("mp_teamlogo_2 ig");
	}
	
	return Plugin_Handled;
}

public Action Team_HR(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "kAliNkA");
		ServerCommand("bot_add_ct %s", "jR");
		ServerCommand("bot_add_ct %s", "Flarich");
		ServerCommand("bot_add_ct %s", "ProbLeM");
		ServerCommand("bot_add_ct %s", "JIaYm");
		ServerCommand("mp_teamlogo_1 hr");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "kAliNkA");
		ServerCommand("bot_add_t %s", "jR");
		ServerCommand("bot_add_t %s", "Flarich");
		ServerCommand("bot_add_t %s", "ProbLeM");
		ServerCommand("bot_add_t %s", "JIaYm");
		ServerCommand("mp_teamlogo_2 hr");
	}
	
	return Plugin_Handled;
}

public Action Team_Dice(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "XpG");
		ServerCommand("bot_add_ct %s", "nonick");
		ServerCommand("bot_add_ct %s", "Kan4");
		ServerCommand("bot_add_ct %s", "Polox");
		ServerCommand("bot_add_ct %s", "Djoko");
		ServerCommand("mp_teamlogo_1 dice");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "XpG");
		ServerCommand("bot_add_t %s", "nonick");
		ServerCommand("bot_add_t %s", "Kan4");
		ServerCommand("bot_add_t %s", "Polox");
		ServerCommand("bot_add_t %s", "Djoko");
		ServerCommand("mp_teamlogo_2 dice");
	}
	
	return Plugin_Handled;
}

public Action Team_PlanetKey(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "LapeX");
		ServerCommand("bot_add_ct %s", "Printek");
		ServerCommand("bot_add_ct %s", "glaVed");
		ServerCommand("bot_add_ct %s", "ND");
		ServerCommand("bot_add_ct %s", "impulsG");
		ServerCommand("mp_teamlogo_1 planet");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "LapeX");
		ServerCommand("bot_add_t %s", "Printek");
		ServerCommand("bot_add_t %s", "glaVed");
		ServerCommand("bot_add_t %s", "ND");
		ServerCommand("bot_add_t %s", "impulsG");
		ServerCommand("mp_teamlogo_2 planet");
	}
	
	return Plugin_Handled;
}

public Action Team_Vexed(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "dox");
		ServerCommand("bot_add_ct %s", "shyyne");
		ServerCommand("bot_add_ct %s", "leafy");
		ServerCommand("bot_add_ct %s", "EIZA");
		ServerCommand("bot_add_ct %s", "volt");
		ServerCommand("mp_teamlogo_1 vex");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "dox");
		ServerCommand("bot_add_t %s", "shyyne");
		ServerCommand("bot_add_t %s", "leafy");
		ServerCommand("bot_add_t %s", "EIZA");
		ServerCommand("bot_add_t %s", "volt");
		ServerCommand("mp_teamlogo_2 vex");
	}
	
	return Plugin_Handled;
}

public Action Team_HLE(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "d1Ledez");
		ServerCommand("bot_add_ct %s", "DrobnY");
		ServerCommand("bot_add_ct %s", "Raijin");
		ServerCommand("bot_add_ct %s", "dekzz");
		ServerCommand("bot_add_ct %s", "svyat");
		ServerCommand("mp_teamlogo_1 hle");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "d1Ledez");
		ServerCommand("bot_add_t %s", "DrobnY");
		ServerCommand("bot_add_t %s", "Raijin");
		ServerCommand("bot_add_t %s", "dekzz");
		ServerCommand("bot_add_t %s", "svyat");
		ServerCommand("mp_teamlogo_2 hle");
	}
	
	return Plugin_Handled;
}

public Action Team_Gambit(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "nafany");
		ServerCommand("bot_add_ct %s", "sh1ro");
		ServerCommand("bot_add_ct %s", "interz");
		ServerCommand("bot_add_ct %s", "Ax1Le");
		ServerCommand("bot_add_ct %s", "Hobbit");
		ServerCommand("mp_teamlogo_1 gambit");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "nafany");
		ServerCommand("bot_add_t %s", "sh1ro");
		ServerCommand("bot_add_t %s", "interz");
		ServerCommand("bot_add_t %s", "Ax1Le");
		ServerCommand("bot_add_t %s", "Hobbit");
		ServerCommand("mp_teamlogo_2 gambit");
	}
	
	return Plugin_Handled;
}

public Action Team_Wisla(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "hades");
		ServerCommand("bot_add_ct %s", "SZPERO");
		ServerCommand("bot_add_ct %s", "mynio");
		ServerCommand("bot_add_ct %s", "ponczek");
		ServerCommand("bot_add_ct %s", "jedqr");
		ServerCommand("mp_teamlogo_1 wisla");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "hades");
		ServerCommand("bot_add_t %s", "SZPERO");
		ServerCommand("bot_add_t %s", "mynio");
		ServerCommand("bot_add_t %s", "ponczek");
		ServerCommand("bot_add_t %s", "jedqr");
		ServerCommand("mp_teamlogo_2 wisla");
	}
	
	return Plugin_Handled;
}

public Action Team_Imperial(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "fnx");
		ServerCommand("bot_add_ct %s", "zqk");
		ServerCommand("bot_add_ct %s", "togs");
		ServerCommand("bot_add_ct %s", "iDk");
		ServerCommand("bot_add_ct %s", "SHOOWTiME");
		ServerCommand("mp_teamlogo_1 imp");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "fnx");
		ServerCommand("bot_add_t %s", "zqk");
		ServerCommand("bot_add_t %s", "togs");
		ServerCommand("bot_add_t %s", "iDk");
		ServerCommand("bot_add_t %s", "SHOOWTiME");
		ServerCommand("mp_teamlogo_2 imp");
	}
	
	return Plugin_Handled;
}

public Action Team_Pompa(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "bnox");
		ServerCommand("bot_add_ct %s", "Grashog");
		ServerCommand("bot_add_ct %s", "fr3nd");
		ServerCommand("bot_add_ct %s", "Miki Z Afryki");
		ServerCommand("bot_add_ct %s", "koyot");
		ServerCommand("mp_teamlogo_1 pompa");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "bnox");
		ServerCommand("bot_add_t %s", "Grashog");
		ServerCommand("bot_add_t %s", "fr3nd");
		ServerCommand("bot_add_t %s", "Miki Z Afryki");
		ServerCommand("bot_add_t %s", "koyot");
		ServerCommand("mp_teamlogo_2 pompa");
	}
	
	return Plugin_Handled;
}

public Action Team_Unique(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "crush");
		ServerCommand("bot_add_ct %s", "Kre1N");
		ServerCommand("bot_add_ct %s", "shalfey");
		ServerCommand("bot_add_ct %s", "SELLTER");
		ServerCommand("bot_add_ct %s", "floweaN");
		ServerCommand("mp_teamlogo_1 uniq");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "crush");
		ServerCommand("bot_add_t %s", "Kre1N");
		ServerCommand("bot_add_t %s", "shalfey");
		ServerCommand("bot_add_t %s", "SELLTER");
		ServerCommand("bot_add_t %s", "floweaN");
		ServerCommand("mp_teamlogo_2 uniq");
	}
	
	return Plugin_Handled;
}

public Action Team_Izako(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Siuhy");
		ServerCommand("bot_add_ct %s", "szejn");
		ServerCommand("bot_add_ct %s", "EXUS");
		ServerCommand("bot_add_ct %s", "avis");
		ServerCommand("bot_add_ct %s", "TOAO");
		ServerCommand("mp_teamlogo_1 izak");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Siuhy");
		ServerCommand("bot_add_t %s", "szejn");
		ServerCommand("bot_add_t %s", "EXUS");
		ServerCommand("bot_add_t %s", "avis");
		ServerCommand("bot_add_t %s", "TOAO");
		ServerCommand("mp_teamlogo_2 izak");
	}
	
	return Plugin_Handled;
}

public Action Team_ATK(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "bLazE");
		ServerCommand("bot_add_ct %s", "MisteM");
		ServerCommand("bot_add_ct %s", "SloWye");
		ServerCommand("bot_add_ct %s", "Fadey");
		ServerCommand("bot_add_ct %s", "Doru");
		ServerCommand("mp_teamlogo_1 atk");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "bLazE");
		ServerCommand("bot_add_t %s", "MisteM");
		ServerCommand("bot_add_t %s", "SloWye");
		ServerCommand("bot_add_t %s", "Fadey");
		ServerCommand("bot_add_t %s", "Doru");
		ServerCommand("mp_teamlogo_2 atk");
	}
	
	return Plugin_Handled;
}

public Action Team_Chaos(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Xeppaa");
		ServerCommand("bot_add_ct %s", "vanity");
		ServerCommand("bot_add_ct %s", "leaf");
		ServerCommand("bot_add_ct %s", "MarKE");
		ServerCommand("bot_add_ct %s", "Jonji");
		ServerCommand("mp_teamlogo_1 chaos");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Xeppaa");
		ServerCommand("bot_add_t %s", "vanity");
		ServerCommand("bot_add_t %s", "leaf");
		ServerCommand("bot_add_t %s", "MarKE");
		ServerCommand("bot_add_t %s", "Jonji");
		ServerCommand("mp_teamlogo_2 chaos");
	}
	
	return Plugin_Handled;
}

public Action Team_Wings(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "ChildKing");
		ServerCommand("bot_add_ct %s", "lan");
		ServerCommand("bot_add_ct %s", "MarT1n");
		ServerCommand("bot_add_ct %s", "DD");
		ServerCommand("bot_add_ct %s", "gas");
		ServerCommand("mp_teamlogo_1 wings");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "ChildKing");
		ServerCommand("bot_add_t %s", "lan");
		ServerCommand("bot_add_t %s", "MarT1n");
		ServerCommand("bot_add_t %s", "DD");
		ServerCommand("bot_add_t %s", "gas");
		ServerCommand("mp_teamlogo_2 wings");
	}
	
	return Plugin_Handled;
}

public Action Team_Lynn(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "XG");
		ServerCommand("bot_add_ct %s", "mitsuha");
		ServerCommand("bot_add_ct %s", "Aree");
		ServerCommand("bot_add_ct %s", "EXPRO");
		ServerCommand("bot_add_ct %s", "XinKoiNg");
		ServerCommand("mp_teamlogo_1 lynn");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "XG");
		ServerCommand("bot_add_t %s", "mitsuha");
		ServerCommand("bot_add_t %s", "Aree");
		ServerCommand("bot_add_t %s", "EXPRO");
		ServerCommand("bot_add_t %s", "XinKoiNg");
		ServerCommand("mp_teamlogo_2 lynn");
	}
	
	return Plugin_Handled;
}

public Action Team_Triumph(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Shakezullah");
		ServerCommand("bot_add_ct %s", "Junior");
		ServerCommand("bot_add_ct %s", "ryann");
		ServerCommand("bot_add_ct %s", "penny");
		ServerCommand("bot_add_ct %s", "moose");
		ServerCommand("mp_teamlogo_1 tri");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Shakezullah");
		ServerCommand("bot_add_t %s", "Junior");
		ServerCommand("bot_add_t %s", "ryann");
		ServerCommand("bot_add_t %s", "penny");
		ServerCommand("bot_add_t %s", "moose");
		ServerCommand("mp_teamlogo_2 tri");
	}
	
	return Plugin_Handled;
}

public Action Team_FATE(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "blocker");
		ServerCommand("bot_add_ct %s", "Patrick");
		ServerCommand("bot_add_ct %s", "harn");
		ServerCommand("bot_add_ct %s", "Mar");
		ServerCommand("bot_add_ct %s", "niki1");
		ServerCommand("mp_teamlogo_1 fate");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "blocker");
		ServerCommand("bot_add_t %s", "Patrick");
		ServerCommand("bot_add_t %s", "harn");
		ServerCommand("bot_add_t %s", "Mar");
		ServerCommand("bot_add_t %s", "niki1");
		ServerCommand("mp_teamlogo_2 fate");
	}
	
	return Plugin_Handled;
}

public Action Team_Canids(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "DeStiNy");
		ServerCommand("bot_add_ct %s", "nythonzinho");
		ServerCommand("bot_add_ct %s", "dav1d");
		ServerCommand("bot_add_ct %s", "latto");
		ServerCommand("bot_add_ct %s", "KHTEX");
		ServerCommand("mp_teamlogo_1 red");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "DeStiNy");
		ServerCommand("bot_add_t %s", "nythonzinho");
		ServerCommand("bot_add_t %s", "dav1d");
		ServerCommand("bot_add_t %s", "latto");
		ServerCommand("bot_add_t %s", "KHTEX");
		ServerCommand("mp_teamlogo_2 red");
	}
	
	return Plugin_Handled;
}

public Action Team_ESPADA(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Patsanchick");
		ServerCommand("bot_add_ct %s", "degster");
		ServerCommand("bot_add_ct %s", "FinigaN");
		ServerCommand("bot_add_ct %s", "S0tF1k");
		ServerCommand("bot_add_ct %s", "Dima");
		ServerCommand("mp_teamlogo_1 esp");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Patsanchick");
		ServerCommand("bot_add_t %s", "degster");
		ServerCommand("bot_add_t %s", "FinigaN");
		ServerCommand("bot_add_t %s", "S0tF1k");
		ServerCommand("bot_add_t %s", "Dima");
		ServerCommand("mp_teamlogo_2 esp");
	}
	
	return Plugin_Handled;
}

public Action Team_OG(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "NBK-");
		ServerCommand("bot_add_ct %s", "mantuu");
		ServerCommand("bot_add_ct %s", "Aleksib");
		ServerCommand("bot_add_ct %s", "valde");
		ServerCommand("bot_add_ct %s", "ISSAA");
		ServerCommand("mp_teamlogo_1 og");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "NBK-");
		ServerCommand("bot_add_t %s", "mantuu");
		ServerCommand("bot_add_t %s", "Aleksib");
		ServerCommand("bot_add_t %s", "valde");
		ServerCommand("bot_add_t %s", "ISSAA");
		ServerCommand("mp_teamlogo_2 og");
	}
	
	return Plugin_Handled;
}

public Action Team_Wizards(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Bernard");
		ServerCommand("bot_add_ct %s", "blackie");
		ServerCommand("bot_add_ct %s", "kzealos");
		ServerCommand("bot_add_ct %s", "eneshan");
		ServerCommand("bot_add_ct %s", "dreez");
		ServerCommand("mp_teamlogo_1 wiz");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Bernard");
		ServerCommand("bot_add_t %s", "blackie");
		ServerCommand("bot_add_t %s", "kzealos");
		ServerCommand("bot_add_t %s", "eneshan");
		ServerCommand("bot_add_t %s", "dreez");
		ServerCommand("mp_teamlogo_2 wiz");
	}
	
	return Plugin_Handled;
}

public Action Team_Tricked(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "kiR");
		ServerCommand("bot_add_ct %s", "kwezz");
		ServerCommand("bot_add_ct %s", "Luckyv1");
		ServerCommand("bot_add_ct %s", "sycrone");
		ServerCommand("bot_add_ct %s", "PR1mE");
		ServerCommand("mp_teamlogo_1 trick");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "kiR");
		ServerCommand("bot_add_t %s", "kwezz");
		ServerCommand("bot_add_t %s", "Luckyv1");
		ServerCommand("bot_add_t %s", "sycrone");
		ServerCommand("bot_add_t %s", "PR1mE");
		ServerCommand("mp_teamlogo_2 trick");
	}
	
	return Plugin_Handled;
}

public Action Team_GenG(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "autimatic");
		ServerCommand("bot_add_ct %s", "koosta");
		ServerCommand("bot_add_ct %s", "daps");
		ServerCommand("bot_add_ct %s", "s0m");
		ServerCommand("bot_add_ct %s", "BnTeT");
		ServerCommand("mp_teamlogo_1 gen");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "autimatic");
		ServerCommand("bot_add_t %s", "koosta");
		ServerCommand("bot_add_t %s", "daps");
		ServerCommand("bot_add_t %s", "s0m");
		ServerCommand("bot_add_t %s", "BnTeT");
		ServerCommand("mp_teamlogo_2 gen");
	}
	
	return Plugin_Handled;
}

public Action Team_Endpoint(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Surreal");
		ServerCommand("bot_add_ct %s", "CRUC1AL");
		ServerCommand("bot_add_ct %s", "MiGHTYMAX");
		ServerCommand("bot_add_ct %s", "robiin");
		ServerCommand("bot_add_ct %s", "flameZ");
		ServerCommand("mp_teamlogo_1 endp");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Surreal");
		ServerCommand("bot_add_t %s", "CRUC1AL");
		ServerCommand("bot_add_t %s", "MiGHTYMAX");
		ServerCommand("bot_add_t %s", "robiin");
		ServerCommand("bot_add_t %s", "flameZ");
		ServerCommand("mp_teamlogo_2 endp");
	}
	
	return Plugin_Handled;
}

public Action Team_sAw(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "arki");
		ServerCommand("bot_add_ct %s", "stadodo");
		ServerCommand("bot_add_ct %s", "JUST");
		ServerCommand("bot_add_ct %s", "MUTiRiS");
		ServerCommand("bot_add_ct %s", "rmn");
		ServerCommand("mp_teamlogo_1 saw");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "arki");
		ServerCommand("bot_add_t %s", "stadodo");
		ServerCommand("bot_add_t %s", "JUST");
		ServerCommand("bot_add_t %s", "MUTiRiS");
		ServerCommand("bot_add_t %s", "rmn");
		ServerCommand("mp_teamlogo_2 saw");
	}
	
	return Plugin_Handled;
}

public Action Team_DIG(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "H4RR3");
		ServerCommand("bot_add_ct %s", "hallzerk");
		ServerCommand("bot_add_ct %s", "f0rest");
		ServerCommand("bot_add_ct %s", "friberg");
		ServerCommand("bot_add_ct %s", "HEAP");
		ServerCommand("mp_teamlogo_1 dign");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "H4RR3");
		ServerCommand("bot_add_t %s", "hallzerk");
		ServerCommand("bot_add_t %s", "f0rest");
		ServerCommand("bot_add_t %s", "friberg");
		ServerCommand("bot_add_t %s", "HEAP");
		ServerCommand("mp_teamlogo_2 dign");
	}
	
	return Plugin_Handled;
}

public Action Team_D13(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Tamiraarita");
		ServerCommand("bot_add_ct %s", "hasteka");
		ServerCommand("bot_add_ct %s", "shinobi");
		ServerCommand("bot_add_ct %s", "sK0R");
		ServerCommand("bot_add_ct %s", "ANNIHILATION");
		ServerCommand("mp_teamlogo_1 d13");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Tamiraarita");
		ServerCommand("bot_add_t %s", "hasteka");
		ServerCommand("bot_add_t %s", "shinobi");
		ServerCommand("bot_add_t %s", "sK0R");
		ServerCommand("bot_add_t %s", "ANNIHILATION");
		ServerCommand("mp_teamlogo_2 d13");
	}
	
	return Plugin_Handled;
}

public Action Team_ZIGMA(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "NIFFY");
		ServerCommand("bot_add_ct %s", "Reality");
		ServerCommand("bot_add_ct %s", "JUSTCAUSE");
		ServerCommand("bot_add_ct %s", "PPOverdose");
		ServerCommand("bot_add_ct %s", "RoLEX");
		ServerCommand("mp_teamlogo_1 zigma");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "NIFFY");
		ServerCommand("bot_add_t %s", "Reality");
		ServerCommand("bot_add_t %s", "JUSTCAUSE");
		ServerCommand("bot_add_t %s", "PPOverdose");
		ServerCommand("bot_add_t %s", "RoLEX");
		ServerCommand("mp_teamlogo_2 zigma");
	}
	
	return Plugin_Handled;
}

public Action Team_Ambush(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Inzta");
		ServerCommand("bot_add_ct %s", "Ryxxo");
		ServerCommand("bot_add_ct %s", "zeq");
		ServerCommand("bot_add_ct %s", "Typos");
		ServerCommand("bot_add_ct %s", "IceBerg");
		ServerCommand("mp_teamlogo_1 ambu");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Inzta");
		ServerCommand("bot_add_t %s", "Ryxxo");
		ServerCommand("bot_add_t %s", "zeq");
		ServerCommand("bot_add_t %s", "Typos");
		ServerCommand("bot_add_t %s", "IceBerg");
		ServerCommand("mp_teamlogo_2 ambu");
	}
	
	return Plugin_Handled;
}

public Action Team_KOVA(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "pietola");
		ServerCommand("bot_add_ct %s", "spargo");
		ServerCommand("bot_add_ct %s", "uli");
		ServerCommand("bot_add_ct %s", "peku");
		ServerCommand("bot_add_ct %s", "Twixie");
		ServerCommand("mp_teamlogo_1 kova");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "pietola");
		ServerCommand("bot_add_t %s", "spargo");
		ServerCommand("bot_add_t %s", "uli");
		ServerCommand("bot_add_t %s", "peku");
		ServerCommand("bot_add_t %s", "Twixie");
		ServerCommand("mp_teamlogo_2 kova");
	}
	
	return Plugin_Handled;
}

public Action Team_AGF(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "fr0slev");
		ServerCommand("bot_add_ct %s", "FaagaN");
		ServerCommand("bot_add_ct %s", "netrick");
		ServerCommand("bot_add_ct %s", "TMB");
		ServerCommand("bot_add_ct %s", "Lukki");
		ServerCommand("mp_teamlogo_1 agf");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "fr0slev");
		ServerCommand("bot_add_t %s", "FaagaN");
		ServerCommand("bot_add_t %s", "netrick");
		ServerCommand("bot_add_t %s", "TMB");
		ServerCommand("bot_add_t %s", "Lukki");
		ServerCommand("mp_teamlogo_2 agf");
	}
	
	return Plugin_Handled;
}

public Action Team_GameAgents(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "markk");
		ServerCommand("bot_add_ct %s", "renne");
		ServerCommand("bot_add_ct %s", "s0und");
		ServerCommand("bot_add_ct %s", "regali");
		ServerCommand("bot_add_ct %s", "smekk-");
		ServerCommand("mp_teamlogo_1 game");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "markk");
		ServerCommand("bot_add_t %s", "renne");
		ServerCommand("bot_add_t %s", "s0und");
		ServerCommand("bot_add_t %s", "regali");
		ServerCommand("bot_add_t %s", "smekk-");
		ServerCommand("mp_teamlogo_2 game");
	}
	
	return Plugin_Handled;
}

public Action Team_Keyd(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "bnc");
		ServerCommand("bot_add_ct %s", "mawth");
		ServerCommand("bot_add_ct %s", "tifa");
		ServerCommand("bot_add_ct %s", "jota");
		ServerCommand("bot_add_ct %s", "puni");
		ServerCommand("mp_teamlogo_1 keyds");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "bnc");
		ServerCommand("bot_add_t %s", "mawth");
		ServerCommand("bot_add_t %s", "tifa");
		ServerCommand("bot_add_t %s", "jota");
		ServerCommand("bot_add_t %s", "puni");
		ServerCommand("mp_teamlogo_2 keyds");
	}
	
	return Plugin_Handled;
}

public Action Team_TIGER(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "erkaSt");
		ServerCommand("bot_add_ct %s", "nin9");
		ServerCommand("bot_add_ct %s", "dobu");
		ServerCommand("bot_add_ct %s", "kabal");
		ServerCommand("bot_add_ct %s", "rate");
		ServerCommand("mp_teamlogo_1 tiger");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "erkaSt");
		ServerCommand("bot_add_t %s", "nin9");
		ServerCommand("bot_add_t %s", "dobu");
		ServerCommand("bot_add_t %s", "kabal");
		ServerCommand("bot_add_t %s", "rate");
		ServerCommand("mp_teamlogo_2 tiger");
	}
	
	return Plugin_Handled;
}

public Action Team_LEISURE(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "stefank0k0");
		ServerCommand("bot_add_ct %s", "BischeR");
		ServerCommand("bot_add_ct %s", "farmaG");
		ServerCommand("bot_add_ct %s", "FabeeN");
		ServerCommand("bot_add_ct %s", "bustrex");
		ServerCommand("mp_teamlogo_1 leis");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "stefank0k0");
		ServerCommand("bot_add_t %s", "BischeR");
		ServerCommand("bot_add_t %s", "farmaG");
		ServerCommand("bot_add_t %s", "FabeeN");
		ServerCommand("bot_add_t %s", "bustrex");
		ServerCommand("mp_teamlogo_2 leis");
	}
	
	return Plugin_Handled;
}

public Action Team_Lilmix(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "quix");
		ServerCommand("bot_add_ct %s", "b0denmaster");
		ServerCommand("bot_add_ct %s", "bq");
		ServerCommand("bot_add_ct %s", "Svedjehed");
		ServerCommand("bot_add_ct %s", "isak");
		ServerCommand("mp_teamlogo_1 lil");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "quix");
		ServerCommand("bot_add_t %s", "b0denmaster");
		ServerCommand("bot_add_t %s", "bq");
		ServerCommand("bot_add_t %s", "Svedjehed");
		ServerCommand("bot_add_t %s", "isak");
		ServerCommand("mp_teamlogo_2 lil");
	}
	
	return Plugin_Handled;
}

public Action Team_FTW(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "NABOWOW");
		ServerCommand("bot_add_ct %s", "Jaepe");
		ServerCommand("bot_add_ct %s", "brA");
		ServerCommand("bot_add_ct %s", "plat");
		ServerCommand("bot_add_ct %s", "Cunha");
		ServerCommand("mp_teamlogo_1 ftw");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "NABOWOW");
		ServerCommand("bot_add_t %s", "Jaepe");
		ServerCommand("bot_add_t %s", "brA");
		ServerCommand("bot_add_t %s", "plat");
		ServerCommand("bot_add_t %s", "Cunha");
		ServerCommand("mp_teamlogo_2 ftw");
	}
	
	return Plugin_Handled;
}

public Action Team_9INE(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "CyderX");
		ServerCommand("bot_add_ct %s", "xfl0ud");
		ServerCommand("bot_add_ct %s", "qRaxs");
		ServerCommand("bot_add_ct %s", "Izzy");
		ServerCommand("bot_add_ct %s", "QutionerX");
		ServerCommand("mp_teamlogo_1 9ine");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "CyderX");
		ServerCommand("bot_add_t %s", "xfl0ud");
		ServerCommand("bot_add_t %s", "qRaxs");
		ServerCommand("bot_add_t %s", "Izzy");
		ServerCommand("bot_add_t %s", "QutionerX");
		ServerCommand("mp_teamlogo_2 9ine");
	}
	
	return Plugin_Handled;
}

public Action Team_QBF(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "JACKPOT");
		ServerCommand("bot_add_ct %s", "Quantium");
		ServerCommand("bot_add_ct %s", "Kas9k");
		ServerCommand("bot_add_ct %s", "hiji");
		ServerCommand("bot_add_ct %s", "lesswill");
		ServerCommand("mp_teamlogo_1 qbf");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "JACKPOT");
		ServerCommand("bot_add_t %s", "Quantium");
		ServerCommand("bot_add_t %s", "Kas9k");
		ServerCommand("bot_add_t %s", "hiji");
		ServerCommand("bot_add_t %s", "lesswill");
		ServerCommand("mp_teamlogo_2 qbf");
	}
	
	return Plugin_Handled;
}

public Action Team_Tigers(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "MAXX");
		ServerCommand("bot_add_ct %s", "Lastík");
		ServerCommand("bot_add_ct %s", "zyored");
		ServerCommand("bot_add_ct %s", "wEAMO");
		ServerCommand("bot_add_ct %s", "manguss");
		ServerCommand("mp_teamlogo_1 tigers");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "MAXX");
		ServerCommand("bot_add_t %s", "Lastík");
		ServerCommand("bot_add_t %s", "zyored");
		ServerCommand("bot_add_t %s", "wEAMO");
		ServerCommand("bot_add_t %s", "manguss");
		ServerCommand("mp_teamlogo_2 tigers");
	}
	
	return Plugin_Handled;
}

public Action Team_9z(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "dgt");
		ServerCommand("bot_add_ct %s", "try");
		ServerCommand("bot_add_ct %s", "maxujas");
		ServerCommand("bot_add_ct %s", "bit");
		ServerCommand("bot_add_ct %s", "meyern");
		ServerCommand("mp_teamlogo_1 9z");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "dgt");
		ServerCommand("bot_add_t %s", "try");
		ServerCommand("bot_add_t %s", "maxujas");
		ServerCommand("bot_add_t %s", "bit");
		ServerCommand("bot_add_t %s", "meyern");
		ServerCommand("mp_teamlogo_2 9z");
	}
	
	return Plugin_Handled;
}

public Action Team_Sinister5(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "zerOchaNce");
		ServerCommand("bot_add_ct %s", "FreakY");
		ServerCommand("bot_add_ct %s", "deviaNt");
		ServerCommand("bot_add_ct %s", "Lately");
		ServerCommand("bot_add_ct %s", "slayeRyEyE");
		ServerCommand("mp_teamlogo_1 sini");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "zerOchaNce");
		ServerCommand("bot_add_t %s", "FreakY");
		ServerCommand("bot_add_t %s", "deviaNt");
		ServerCommand("bot_add_t %s", "Lately");
		ServerCommand("bot_add_t %s", "slayeRyEyE");
		ServerCommand("mp_teamlogo_2 sini");
	}
	
	return Plugin_Handled;
}

public Action Team_SINNERS(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "ZEDKO");
		ServerCommand("bot_add_ct %s", "oskar");
		ServerCommand("bot_add_ct %s", "SHOCK");
		ServerCommand("bot_add_ct %s", "beastik");
		ServerCommand("bot_add_ct %s", "NEOFRAG");
		ServerCommand("mp_teamlogo_1 sinn");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "ZEDKO");
		ServerCommand("bot_add_t %s", "oskar");
		ServerCommand("bot_add_t %s", "SHOCK");
		ServerCommand("bot_add_t %s", "beastik");
		ServerCommand("bot_add_t %s", "NEOFRAG");
		ServerCommand("mp_teamlogo_2 sinn");
	}
	
	return Plugin_Handled;
}

public Action Team_Impact(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (StrEqual(arg, "ct"))
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "DaneJoris");
		ServerCommand("bot_add_ct %s", "walker");
		ServerCommand("bot_add_ct %s", "brett");
		ServerCommand("bot_add_ct %s", "Koalanoob");
		ServerCommand("bot_add_ct %s", "insane");
		ServerCommand("mp_teamlogo_1 impa");
	}
	
	if (StrEqual(arg, "t"))
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "DaneJoris");
		ServerCommand("bot_add_t %s", "walker");
		ServerCommand("bot_add_t %s", "brett");
		ServerCommand("bot_add_t %s", "Koalanoob");
		ServerCommand("bot_add_t %s", "insane");
		ServerCommand("mp_teamlogo_2 impa");
	}
	
	return Plugin_Handled;
}

public Action Team_ERN(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "j1NZO");
		ServerCommand("bot_add_ct %s", "preet");
		ServerCommand("bot_add_ct %s", "ReacTioNNN");
		ServerCommand("bot_add_ct %s", "FreeZe");
		ServerCommand("bot_add_ct %s", "S3NSEY");
		ServerCommand("mp_teamlogo_1 ern");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "j1NZO");
		ServerCommand("bot_add_t %s", "preet");
		ServerCommand("bot_add_t %s", "ReacTioNNN");
		ServerCommand("bot_add_t %s", "FreeZe");
		ServerCommand("bot_add_t %s", "S3NSEY");
		ServerCommand("mp_teamlogo_2 ern");
	}
	
	return Plugin_Handled;
}

public Action Team_BL4ZE(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Rossi");
		ServerCommand("bot_add_ct %s", "Marzil");
		ServerCommand("bot_add_ct %s", "SkRossi");
		ServerCommand("bot_add_ct %s", "Raph");
		ServerCommand("bot_add_ct %s", "cara");
		ServerCommand("mp_teamlogo_1 bl4ze");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Rossi");
		ServerCommand("bot_add_t %s", "Marzil");
		ServerCommand("bot_add_t %s", "SkRossi");
		ServerCommand("bot_add_t %s", "Raph");
		ServerCommand("bot_add_t %s", "cara");
		ServerCommand("mp_teamlogo_2 bl4ze");
	}
	
	return Plugin_Handled;
}

public Action Team_Global(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "HellrangeR");
		ServerCommand("bot_add_ct %s", "Karam1L");
		ServerCommand("bot_add_ct %s", "hellff");
		ServerCommand("bot_add_ct %s", "DEATHMAKER");
		ServerCommand("bot_add_ct %s", "Lightningfast");
		ServerCommand("mp_teamlogo_1 global");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "HellrangeR");
		ServerCommand("bot_add_t %s", "Karam1L");
		ServerCommand("bot_add_t %s", "hellff");
		ServerCommand("bot_add_t %s", "DEATHMAKER");
		ServerCommand("bot_add_t %s", "Lightningfast");
		ServerCommand("mp_teamlogo_2 global");
	}
	
	return Plugin_Handled;
}

public Action Team_Conquer(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "NiNLeX");
		ServerCommand("bot_add_ct %s", "RONDE");
		ServerCommand("bot_add_ct %s", "S1rva");
		ServerCommand("bot_add_ct %s", "jelo");
		ServerCommand("bot_add_ct %s", "KonZero");
		ServerCommand("mp_teamlogo_1 conq");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "NiNLeX");
		ServerCommand("bot_add_t %s", "RONDE");
		ServerCommand("bot_add_t %s", "S1rva");
		ServerCommand("bot_add_t %s", "jelo");
		ServerCommand("bot_add_t %s", "KonZero");
		ServerCommand("mp_teamlogo_2 conq");
	}
	
	return Plugin_Handled;
}

public Action Team_Rooster(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "DannyG");
		ServerCommand("bot_add_ct %s", "nettik");
		ServerCommand("bot_add_ct %s", "chelleos");
		ServerCommand("bot_add_ct %s", "ADK");
		ServerCommand("bot_add_ct %s", "asap");
		ServerCommand("mp_teamlogo_1 roos");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "DannyG");
		ServerCommand("bot_add_t %s", "nettik");
		ServerCommand("bot_add_t %s", "chelleos");
		ServerCommand("bot_add_t %s", "ADK");
		ServerCommand("bot_add_t %s", "asap");
		ServerCommand("mp_teamlogo_2 roos");
	}
	
	return Plugin_Handled;
}

public Action Team_Flames(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "nicoodoz");
		ServerCommand("bot_add_ct %s", "AcilioN");
		ServerCommand("bot_add_ct %s", "Basso");
		ServerCommand("bot_add_ct %s", "Jabbi");
		ServerCommand("bot_add_ct %s", "Daffu");
		ServerCommand("mp_teamlogo_1 flames");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "nicoodoz");
		ServerCommand("bot_add_t %s", "AcilioN");
		ServerCommand("bot_add_t %s", "Basso");
		ServerCommand("bot_add_t %s", "Jabbi");
		ServerCommand("bot_add_t %s", "Daffu");
		ServerCommand("mp_teamlogo_2 flames");
	}
	
	return Plugin_Handled;
}

public Action Team_Baecon(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "emp");
		ServerCommand("bot_add_ct %s", "vts");
		ServerCommand("bot_add_ct %s", "kst");
		ServerCommand("bot_add_ct %s", "whatz");
		ServerCommand("bot_add_ct %s", "shellzi");
		ServerCommand("mp_teamlogo_1 baec");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "emp");
		ServerCommand("bot_add_t %s", "vts");
		ServerCommand("bot_add_t %s", "kst");
		ServerCommand("bot_add_t %s", "whatz");
		ServerCommand("bot_add_t %s", "shellzi");
		ServerCommand("mp_teamlogo_2 baec");
	}
	
	return Plugin_Handled;
}

public Action Team_KPI(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "pounh");
		ServerCommand("bot_add_ct %s", "SAYN");
		ServerCommand("bot_add_ct %s", "Aaron");
		ServerCommand("bot_add_ct %s", "Butters");
		ServerCommand("bot_add_ct %s", "ztr");
		ServerCommand("mp_teamlogo_1 kpi");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "pounh");
		ServerCommand("bot_add_t %s", "SAYN");
		ServerCommand("bot_add_t %s", "Aaron");
		ServerCommand("bot_add_t %s", "Butters");
		ServerCommand("bot_add_t %s", "ztr");
		ServerCommand("mp_teamlogo_2 kpi");
	}
	
	return Plugin_Handled;
}

public Action Team_hREDS(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "eDi");
		ServerCommand("bot_add_ct %s", "oopee");
		ServerCommand("bot_add_ct %s", "VORMISTO");
		ServerCommand("bot_add_ct %s", "Samppa");
		ServerCommand("bot_add_ct %s", "xartE");
		ServerCommand("mp_teamlogo_1 hreds");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "eDi");
		ServerCommand("bot_add_t %s", "oopee");
		ServerCommand("bot_add_t %s", "VORMISTO");
		ServerCommand("bot_add_t %s", "Samppa");
		ServerCommand("bot_add_t %s", "xartE");
		ServerCommand("mp_teamlogo_2 hreds");
	}
	
	return Plugin_Handled;
}

public Action Team_Lemondogs(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "xelos");
		ServerCommand("bot_add_ct %s", "kaktus");
		ServerCommand("bot_add_ct %s", "hemzk9");
		ServerCommand("bot_add_ct %s", "Mann3n");
		ServerCommand("bot_add_ct %s", "gamersdont");
		ServerCommand("mp_teamlogo_1 lemon");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "xelos");
		ServerCommand("bot_add_t %s", "kaktus");
		ServerCommand("bot_add_t %s", "hemzk9");
		ServerCommand("bot_add_t %s", "Mann3n");
		ServerCommand("bot_add_t %s", "gamersdont");
		ServerCommand("mp_teamlogo_2 lemon");
	}
	
	return Plugin_Handled;
}

public Action Team_CeX(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "JackB");
		ServerCommand("bot_add_ct %s", "Impact");
		ServerCommand("bot_add_ct %s", "RezzeD");
		ServerCommand("bot_add_ct %s", "fluFFS");
		ServerCommand("bot_add_ct %s", "ifan");
		ServerCommand("mp_teamlogo_1 cex");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "JackB");
		ServerCommand("bot_add_t %s", "Impact");
		ServerCommand("bot_add_t %s", "RezzeD");
		ServerCommand("bot_add_t %s", "fluFFS");
		ServerCommand("bot_add_t %s", "ifan");
		ServerCommand("mp_teamlogo_2 cex");
	}
	
	return Plugin_Handled;
}

public Action Team_Havan(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "ALLE");
		ServerCommand("bot_add_ct %s", "drg");
		ServerCommand("bot_add_ct %s", "remix");
		ServerCommand("bot_add_ct %s", "dok");
		ServerCommand("bot_add_ct %s", "w1");
		ServerCommand("mp_teamlogo_1 havan");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "ALLE");
		ServerCommand("bot_add_t %s", "drg");
		ServerCommand("bot_add_t %s", "remix");
		ServerCommand("bot_add_t %s", "dok");
		ServerCommand("bot_add_t %s", "w1");
		ServerCommand("mp_teamlogo_2 havan");
	}
	
	return Plugin_Handled;
}

public Action Team_Sangal(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "MAJ3R");
		ServerCommand("bot_add_ct %s", "ngiN");
		ServerCommand("bot_add_ct %s", "paz");
		ServerCommand("bot_add_ct %s", "l0gicman");
		ServerCommand("bot_add_ct %s", "imoRR");
		ServerCommand("mp_teamlogo_1 sang");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "MAJ3R");
		ServerCommand("bot_add_t %s", "ngiN");
		ServerCommand("bot_add_t %s", "paz");
		ServerCommand("bot_add_t %s", "l0gicman");
		ServerCommand("bot_add_t %s", "imoRR");
		ServerCommand("mp_teamlogo_2 sang");
	}
	
	return Plugin_Handled;
}

public void OnMapStart()
{
	g_iProfileRankOffset = FindSendPropInfo("CCSPlayerResource", "m_nPersonaDataPublicLevel");
	
	GameRules_SetProp("m_bIsValveDS", 1);
	GameRules_SetProp("m_bIsQuestEligible", 1);
	
	GetCurrentMap(g_szMap, sizeof(g_szMap));
	
	CreateTimer(1.0, Timer_CheckPlayer, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	SDKHook(FindEntityByClassname(MaxClients + 1, "cs_player_manager"), SDKHook_ThinkPost, OnThinkPost);
}

public Action Timer_CheckPlayer(Handle hTimer, any data)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && IsFakeClient(i) && IsPlayerAlive(i))
		{
			int iAccount = GetEntProp(i, Prop_Send, "m_iAccount");
			bool bInBuyZone = view_as<bool>(GetEntProp(i, Prop_Send, "m_bInBuyZone"));
			
			if (Math_GetRandomInt(1, 100) <= 5)
			{
				FakeClientCommand(i, "+lookatweapon");
				FakeClientCommand(i, "-lookatweapon");
			}
			
			if (iAccount == 800 && bInBuyZone)
			{
				FakeClientCommand(i, "buy vest");
			}
			else if ((iAccount > 3000 || GetPlayerWeaponSlot(i, CS_SLOT_PRIMARY) != -1) && bInBuyZone)
			{
				if (GetEntProp(i, Prop_Data, "m_ArmorValue") < 50 || GetEntProp(i, Prop_Send, "m_bHasHelmet") == 0)
				{
					FakeClientCommand(i, "buy vesthelm");
				}
				
				if (GetClientTeam(i) == CS_TEAM_CT && GetEntProp(i, Prop_Send, "m_bHasDefuser") == 0)
				{
					FakeClientCommand(i, "buy defuser");
				}
			}
		}
	}
}

public void OnMapEnd()
{
	SDKUnhook(FindEntityByClassname(MaxClients + 1, "cs_player_manager"), SDKHook_ThinkPost, OnThinkPost);
}

public void OnClientPostAdminCheck(int client)
{
	g_iProfileRank[client] = Math_GetRandomInt(1, 40);
	
	if (IsValidClient(client) && IsFakeClient(client))
	{
		char szBotName[MAX_NAME_LENGTH];
		char szClanTag[MAX_NAME_LENGTH];
		
		GetClientName(client, szBotName, sizeof(szBotName));
		g_bIsProBot[client] = false;
		
		if(IsProBot(szBotName, szClanTag))
		{
			g_bIsProBot[client] = true;
		}
		
		CS_SetClientClanTag(client, szClanTag);
		
		g_iUSPChance[client] = Math_GetRandomInt(1, 100);
		g_iM4A1SChance[client] = Math_GetRandomInt(1, 100);
		
		SDKHook(client, SDKHook_OnTakeDamageAlive, OnTakeDamageAlive);
	}
}

public void OnRoundStart(Event eEvent, char[] szName, bool bDontBroadcast)
{
	g_bFreezetimeEnd = false;
	g_bBombPlanted = false;
	g_bDoExecute = false;
	g_iRoundStartedTime = GetTime();
	
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && IsFakeClient(i) && IsPlayerAlive(i))
		{
			g_bHasThrownNade[i] = false;
			g_bHasThrownSmoke[i] = false;
			g_iUncrouchChance[i] = Math_GetRandomInt(1, 100);
			g_bCanAttack[i] = false;
			g_bCanThrowSmoke[i] = false;
			g_bCanThrowFlash[i] = false;
		}
	}
}

public void OnFreezetimeEnd(Event eEvent, char[] szName, bool bDontBroadcast)
{
	g_bFreezetimeEnd = true;
	
	if (strcmp(g_szMap, "de_mirage") == 0)
	{
		g_iRndExecute = Math_GetRandomInt(1, 3);
		PrepareMirageExecutes();
	}
	else if (strcmp(g_szMap, "de_dust2") == 0)
	{
		g_iRndExecute = Math_GetRandomInt(1, 3);
		PrepareDust2Executes();
	}
	else if (strcmp(g_szMap, "de_inferno") == 0)
	{
		g_iRndExecute = Math_GetRandomInt(1, 3);
		PrepareInfernoExecutes();
	}
	else if (strcmp(g_szMap, "de_overpass") == 0)
	{
		g_iRndExecute = Math_GetRandomInt(1, 2);
		PrepareOverpassExecutes();
	}
}

public void OnBombPlanted(Event eEvent, const char[] szName, bool bDontBroadcast)
{
	g_bBombPlanted = true;
}

public Action CS_OnTerminateRound(float& fDelay, CSRoundEndReason& pReason)
{
	g_bBombPlanted = false;
	
	return Plugin_Continue;
}

public void OnWeaponZoom(Event eEvent, const char[] szName, bool bDontBroadcast)
{
	int client = GetClientOfUserId(eEvent.GetInt("userid"));
	
	if (IsValidClient(client) && IsFakeClient(client))
	{
		CreateTimer(0.3, Timer_Zoomed, GetClientUserId(client));
	}
}

public void OnThinkPost(int iEnt)
{
	SetEntDataArray(iEnt, g_iProfileRankOffset, g_iProfileRank, MAXPLAYERS + 1);
}

public Action OnTakeDamageAlive(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
{
	if (IsValidClient(victim) && IsFakeClient(victim))
	{
		g_bCanAttack[victim] = true;
	}
}

public Action CS_OnBuyCommand(int client, const char[] szWeapon)
{
	if (IsValidClient(client) && IsFakeClient(client) && IsPlayerAlive(client))
	{
		if (strcmp(szWeapon, "molotov") == 0 || strcmp(szWeapon, "incgrenade") == 0 || strcmp(szWeapon, "decoy") == 0 || strcmp(szWeapon, "flashbang") == 0 || strcmp(szWeapon, "hegrenade") == 0
			 || strcmp(szWeapon, "smokegrenade") == 0 || strcmp(szWeapon, "vest") == 0 || strcmp(szWeapon, "vesthelm") == 0 || strcmp(szWeapon, "defuser") == 0)
		{
			return Plugin_Continue;
		}
		else if (GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY) != -1 && (strcmp(szWeapon, "galilar") == 0 || strcmp(szWeapon, "famas") == 0 || strcmp(szWeapon, "ak47") == 0
				 || strcmp(szWeapon, "m4a1") == 0 || strcmp(szWeapon, "ssg08") == 0 || strcmp(szWeapon, "aug") == 0 || strcmp(szWeapon, "sg556") == 0 || strcmp(szWeapon, "awp") == 0
				 || strcmp(szWeapon, "scar20") == 0 || strcmp(szWeapon, "g3sg1") == 0 || strcmp(szWeapon, "nova") == 0 || strcmp(szWeapon, "xm1014") == 0 || strcmp(szWeapon, "mag7") == 0
				 || strcmp(szWeapon, "m249") == 0 || strcmp(szWeapon, "negev") == 0 || strcmp(szWeapon, "mac10") == 0 || strcmp(szWeapon, "mp9") == 0 || strcmp(szWeapon, "mp7") == 0
				 || strcmp(szWeapon, "ump45") == 0 || strcmp(szWeapon, "p90") == 0 || strcmp(szWeapon, "bizon") == 0))
		{
			return Plugin_Handled;
		}
		
		int iAccount = GetEntProp(client, Prop_Send, "m_iAccount");
		
		if (strcmp(szWeapon, "m4a1") == 0)
		{
			if (g_iM4A1SChance[client] <= 30)
			{
				CSGO_SetMoney(client, iAccount - CS_GetWeaponPrice(client, CSWeapon_M4A1_SILENCER));
				CSGO_ReplaceWeapon(client, CS_SLOT_PRIMARY, "weapon_m4a1_silencer");
				
				return Plugin_Changed;
			}
			
			if (Math_GetRandomInt(1, 100) <= 5)
			{
				CSGO_SetMoney(client, iAccount - CS_GetWeaponPrice(client, CSWeapon_AUG));
				CSGO_ReplaceWeapon(client, CS_SLOT_PRIMARY, "weapon_aug");
				
				return Plugin_Changed;
			}
			
			return Plugin_Continue;
		}
		else if (strcmp(szWeapon, "ak47") == 0)
		{
			if (Math_GetRandomInt(1, 100) <= 5)
			{
				CSGO_SetMoney(client, iAccount - CS_GetWeaponPrice(client, CSWeapon_SG556));
				CSGO_ReplaceWeapon(client, CS_SLOT_PRIMARY, "weapon_sg556");
				
				return Plugin_Changed;
			}
		}
		else if (strcmp(szWeapon, "mac10") == 0)
		{
			if (Math_GetRandomInt(1, 100) <= 40)
			{
				CSGO_SetMoney(client, iAccount - CS_GetWeaponPrice(client, CSWeapon_GALILAR));
				CSGO_ReplaceWeapon(client, CS_SLOT_PRIMARY, "weapon_galilar");
				
				return Plugin_Changed;
			}
			else
			{
				return Plugin_Continue;
			}
		}
		else if (strcmp(szWeapon, "mp9") == 0)
		{
			if (Math_GetRandomInt(1, 100) <= 40)
			{
				CSGO_SetMoney(client, iAccount - CS_GetWeaponPrice(client, CSWeapon_FAMAS));
				CSGO_ReplaceWeapon(client, CS_SLOT_PRIMARY, "weapon_famas");
				
				return Plugin_Changed;
			}
			else
			{
				return Plugin_Continue;
			}
		}
		else
		{
			return Plugin_Continue;
		}
	}
	return Plugin_Continue;
}

public MRESReturn Detour_OnBOTThrowGrenade(int client, Handle hParams)
{
	if (g_bIsProBot[client] && GetClientTeam(client) == CS_TEAM_T && g_bDoExecute)
	{
		return MRES_Supercede;
	}
	
	return MRES_Ignored;
}

public MRESReturn Detour_OnBOTPickNewAimSpot(int client, Handle hParams)
{
	if (g_bIsProBot[client])
	{
		int iActiveWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if (iActiveWeapon == -1)return MRES_Ignored;
		
		int iDefIndex = GetEntProp(iActiveWeapon, Prop_Send, "m_iItemDefinitionIndex");
		int iEnt = -1;
		float fTargetEyes[3];
		
		fTargetEyes = SelectBestTargetPos(client, iEnt);
		
		if (iEnt == -1 || fTargetEyes[2] == 0)
		{
			g_bCanAttack[client] = false;
			return MRES_Ignored;
		}
		
		if ((eItems_GetWeaponSlotByDefIndex(iDefIndex) == CS_SLOT_PRIMARY && iDefIndex != 11 && iDefIndex != 38 && iDefIndex != 9 && iDefIndex != 27 && iDefIndex != 29 && iDefIndex != 35 && iDefIndex != 40) || iDefIndex == 63)
		{
			if (g_bIsHeadVisible[client])
			{
				if (Math_GetRandomInt(1, 100) <= 50)
				{
					int iBone = LookupBone(iEnt, "spine_3");
					
					if (iBone < 0)
						return MRES_Ignored;
					
					float fBody[3], fBad[3];
					GetBonePosition(iEnt, iBone, fBody, fBad);
					
					if (BotIsVisible(client, fBody, false, -1))
					{
						fTargetEyes = fBody;
					}
				}
			}
		}
		else if ((eItems_GetWeaponSlotByDefIndex(iDefIndex) == CS_SLOT_SECONDARY && iDefIndex != 63 && iDefIndex != 1) || iDefIndex == 27 || iDefIndex == 29 || iDefIndex == 35)
		{
			if (g_bIsHeadVisible[client])
			{
				if (Math_GetRandomInt(1, 100) <= 50)
				{
					int iBone = LookupBone(iEnt, "spine_3");
					
					if (iBone < 0)
						return MRES_Ignored;
					
					float fBody[3], fBad[3];
					GetBonePosition(iEnt, iBone, fBody, fBad);
					
					if (BotIsVisible(client, fBody, false, -1))
					{
						fTargetEyes = fBody;
					}
				}
			}
		}
		else if (iDefIndex == 11 || iDefIndex == 38)
		{
			if (g_bIsHeadVisible[client])
			{
				if (Math_GetRandomInt(1, 100) <= 50)
				{
					int iBone = LookupBone(iEnt, "spine_3");
					
					if (iBone < 0)
						return MRES_Ignored;
					
					float fBody[3], fBad[3];
					GetBonePosition(iEnt, iBone, fBody, fBad);
					
					if (BotIsVisible(client, fBody, false, -1))
					{
						fTargetEyes = fBody;
					}
				}
			}
		}
		else if (iDefIndex == 9)
		{
			if (g_bIsHeadVisible[client])
			{
				int iBone = LookupBone(iEnt, "spine_3");
				if (iBone < 0)
					return MRES_Ignored;
				
				float fBody[3], fBad[3];
				GetBonePosition(iEnt, iBone, fBody, fBad);
				
				if (BotIsVisible(client, fBody, false, -1))
				{
					fTargetEyes = fBody;
				}
			}
		}
		else if (eItems_IsDefIndexKnife(iDefIndex))
		{
			return MRES_Ignored;
		}
		
		SetEntDataFloat(client, g_iBotTargetSpotXOffset, fTargetEyes[0]);
		SetEntDataFloat(client, g_iBotTargetSpotYOffset, fTargetEyes[1]);
		SetEntDataFloat(client, g_iBotTargetSpotZOffset, fTargetEyes[2]);
	}
	
	return MRES_Ignored;
}

public MRESReturn Detour_OnBOTSetLookAt(int pThis, Handle hParams)
{
	char szDesc[64];
	
	DHookGetParamString(hParams, 1, szDesc, sizeof(szDesc));
	
	if (strcmp(szDesc, "Defuse bomb") == 0 || strcmp(szDesc, "Use entity") == 0 || strcmp(szDesc, "Open door") == 0 || strcmp(szDesc, "Breakable") == 0
		 || strcmp(szDesc, "Hostage") == 0 || strcmp(szDesc, "Plant bomb on floor") == 0 || strcmp(szDesc, "Avoid Flashbang") == 0)
	{
		return MRES_Ignored;
	}
	else if (strcmp(szDesc, "GrenadeThrowBend") == 0)
	{
		float fPos[3];
		
		DHookGetParamVector(hParams, 2, fPos);
		fPos[2] += Math_GetRandomFloat(25.0, 100.0);
		DHookSetParamVector(hParams, 2, fPos);
		
		return MRES_ChangedHandled;
	}
	else
	{
		float fPos[3];
		
		DHookGetParamVector(hParams, 2, fPos);
		fPos[2] += 30.0;
		DHookSetParamVector(hParams, 2, fPos);
		
		return MRES_ChangedHandled;
	}
}

public MRESReturn Detour_OnBOTUpdate(int client, Handle hParams)
{
	int iActiveWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if (iActiveWeapon == -1)return MRES_Ignored;
	
	int iDefIndex = GetEntProp(iActiveWeapon, Prop_Send, "m_iItemDefinitionIndex");
	
	if ((GetAliveTeamCount(CS_TEAM_T) == 0 || GetAliveTeamCount(CS_TEAM_CT) == 0) && !eItems_IsDefIndexKnife(iDefIndex))
	{
		FakeClientCommandEx(client, "use weapon_knife");
	}
	
	if (g_bIsProBot[client])
	{
		int iPlantedC4 = GetNearestEntity(client, "planted_c4");
		
		if (IsValidEntity(iPlantedC4) && GetClientTeam(client) == CS_TEAM_CT)
		{
			float fPlantedC4Location[3];
			GetEntPropVector(iPlantedC4, Prop_Send, "m_vecOrigin", fPlantedC4Location);
			
			float fClientLocation[3];
			GetClientAbsOrigin(client, fClientLocation);
			
			float fPlantedC4Distance;
			
			fPlantedC4Distance = GetVectorDistance(fClientLocation, fPlantedC4Location);
			
			if (fPlantedC4Distance > 1500.0 && !BotIsBusy(client) && !eItems_IsDefIndexKnife(iDefIndex) && GetEntData(client, g_iBotNearbyEnemiesOffset) == 0)
			{
				FakeClientCommandEx(client, "use weapon_knife");
			}
		}
		
		int iHostage = GetNearestEntity(client, "hostage_entity");
		float fHostageDistance;
		
		if (IsValidEntity(iHostage) && GetClientTeam(client) == CS_TEAM_CT)
		{
			float fHostageLocation[3];
			GetEntPropVector(iHostage, Prop_Send, "m_vecOrigin", fHostageLocation);
			
			float fClientLocation[3];
			GetClientAbsOrigin(client, fClientLocation);
			
			fHostageDistance = GetVectorDistance(fClientLocation, fHostageLocation);
		}
		
		if (g_bFreezetimeEnd && !g_bBombPlanted && !BotIsBusy(client) && !BotIsHiding(client) && (fHostageDistance > 100.0 || !IsValidEntity(iHostage)))
		{
			//Rifles
			int iAK47 = GetNearestEntity(client, "weapon_ak47");
			int iM4A1 = GetNearestEntity(client, "weapon_m4a1");
			int iPrimary = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
			int iPrimaryDefIndex;
			
			if (IsValidEntity(iAK47))
			{
				float fAK47Location[3];
				
				if (iPrimary != -1)
				{
					iPrimaryDefIndex = GetEntProp(iPrimary, Prop_Send, "m_iItemDefinitionIndex");
				}
				
				if (iPrimaryDefIndex != 7 && iPrimaryDefIndex != 9)
				{
					GetEntPropVector(iAK47, Prop_Send, "m_vecOrigin", fAK47Location);
					
					if (fAK47Location[0] != 0.0 && fAK47Location[1] != 0.0 && fAK47Location[2] != 0.0)
					{
						float fClientLocation[3];
						GetClientAbsOrigin(client, fClientLocation);
						
						if (GetVectorDistance(fClientLocation, fAK47Location) < 500.0)
						{
							BotMoveTo(client, fAK47Location, FASTEST_ROUTE);
						}
					}
				}
				else if (iPrimary == -1)
				{
					GetEntPropVector(iAK47, Prop_Send, "m_vecOrigin", fAK47Location);
					
					if (fAK47Location[0] != 0.0 && fAK47Location[1] != 0.0 && fAK47Location[2] != 0.0)
					{
						float fClientLocation[3];
						GetClientAbsOrigin(client, fClientLocation);
						
						if (GetVectorDistance(fClientLocation, fAK47Location) < 500.0)
						{
							BotMoveTo(client, fAK47Location, FASTEST_ROUTE);
						}
					}
				}
			}
			
			if (IsValidEntity(iM4A1))
			{
				float fM4A1Location[3];
				
				if (iPrimary != -1)
				{
					iPrimaryDefIndex = GetEntProp(iPrimary, Prop_Send, "m_iItemDefinitionIndex");
				}
				
				if (iPrimaryDefIndex != 7 && iPrimaryDefIndex != 9 && iPrimaryDefIndex != 16 && iPrimaryDefIndex != 60)
				{
					GetEntPropVector(iM4A1, Prop_Send, "m_vecOrigin", fM4A1Location);
					
					if (fM4A1Location[0] != 0.0 && fM4A1Location[1] != 0.0 && fM4A1Location[2] != 0.0)
					{
						float fClientLocation[3];
						GetClientAbsOrigin(client, fClientLocation);
						
						if (GetVectorDistance(fClientLocation, fM4A1Location) < 500.0)
						{
							BotMoveTo(client, fM4A1Location, FASTEST_ROUTE);
							
							if (GetVectorDistance(fClientLocation, fM4A1Location) < 25.0 && GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY) != -1)
							{
								CS_DropWeapon(client, GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY), false, false);
							}
						}
					}
				}
				else if (iPrimary == -1)
				{
					GetEntPropVector(iM4A1, Prop_Send, "m_vecOrigin", fM4A1Location);
					
					if (fM4A1Location[0] != 0.0 && fM4A1Location[1] != 0.0 && fM4A1Location[2] != 0.0)
					{
						float fClientLocation[3];
						GetClientAbsOrigin(client, fClientLocation);
						
						if (GetVectorDistance(fClientLocation, fM4A1Location) < 500.0)
						{
							BotMoveTo(client, fM4A1Location, FASTEST_ROUTE);
						}
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
				float fDeagleLocation[3];
				
				if (iSecondary != -1)
				{
					iSecondaryDefIndex = GetEntProp(iSecondary, Prop_Send, "m_iItemDefinitionIndex");
				}
				
				if (iSecondaryDefIndex == 4 || iSecondaryDefIndex == 32 || iSecondaryDefIndex == 61 || iSecondaryDefIndex == 36 || iSecondaryDefIndex == 30 || iSecondaryDefIndex == 3 || iSecondaryDefIndex == 63)
				{
					GetEntPropVector(iDeagle, Prop_Send, "m_vecOrigin", fDeagleLocation);
					
					if (fDeagleLocation[0] != 0.0 && fDeagleLocation[1] != 0.0 && fDeagleLocation[2] != 0.0)
					{
						float fClientLocation[3];
						GetClientAbsOrigin(client, fClientLocation);
						
						if (GetVectorDistance(fClientLocation, fDeagleLocation) < 500.0)
						{
							BotMoveTo(client, fDeagleLocation, FASTEST_ROUTE);
							
							if (GetVectorDistance(fClientLocation, fDeagleLocation) < 25.0 && GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY) != -1)
							{
								CS_DropWeapon(client, GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY), false, false);
							}
						}
					}
				}
			}
			
			if (IsValidEntity(iTec9))
			{
				float fTec9Location[3];
				
				if (iSecondary != -1)
				{
					iSecondaryDefIndex = GetEntProp(iSecondary, Prop_Send, "m_iItemDefinitionIndex");
				}
				
				if (iSecondaryDefIndex == 4 || iSecondaryDefIndex == 32 || iSecondaryDefIndex == 61 || iSecondaryDefIndex == 36)
				{
					GetEntPropVector(iTec9, Prop_Send, "m_vecOrigin", fTec9Location);
					
					if (fTec9Location[0] != 0.0 && fTec9Location[1] != 0.0 && fTec9Location[2] != 0.0)
					{
						float fClientLocation[3];
						GetClientAbsOrigin(client, fClientLocation);
						
						if (GetVectorDistance(fClientLocation, fTec9Location) < 500.0)
						{
							BotMoveTo(client, fTec9Location, FASTEST_ROUTE);
							
							if (GetVectorDistance(fClientLocation, fTec9Location) < 25.0 && GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY) != -1)
							{
								CS_DropWeapon(client, GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY), false, false);
							}
						}
					}
				}
			}
			
			if (IsValidEntity(iFiveSeven))
			{
				float fFiveSevenLocation[3];
				
				if (iSecondary != -1)
				{
					iSecondaryDefIndex = GetEntProp(iSecondary, Prop_Send, "m_iItemDefinitionIndex");
				}
				
				if (iSecondaryDefIndex == 4 || iSecondaryDefIndex == 32 || iSecondaryDefIndex == 61 || iSecondaryDefIndex == 36)
				{
					GetEntPropVector(iFiveSeven, Prop_Send, "m_vecOrigin", fFiveSevenLocation);
					
					if (fFiveSevenLocation[0] != 0.0 && fFiveSevenLocation[1] != 0.0 && fFiveSevenLocation[2] != 0.0)
					{
						float fClientLocation[3];
						GetClientAbsOrigin(client, fClientLocation);
						
						if (GetVectorDistance(fClientLocation, fFiveSevenLocation) < 500.0)
						{
							BotMoveTo(client, fFiveSevenLocation, FASTEST_ROUTE);
							
							if (GetVectorDistance(fClientLocation, fFiveSevenLocation) < 25.0 && GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY) != -1)
							{
								CS_DropWeapon(client, GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY), false, false);
							}
						}
					}
				}
			}
			
			if (IsValidEntity(iP250))
			{
				float fP250Location[3];
				
				if (iSecondary != -1)
				{
					iSecondaryDefIndex = GetEntProp(iSecondary, Prop_Send, "m_iItemDefinitionIndex");
				}
				
				if (iSecondaryDefIndex == 4 || iSecondaryDefIndex == 32 || iSecondaryDefIndex == 61)
				{
					GetEntPropVector(iP250, Prop_Send, "m_vecOrigin", fP250Location);
					
					if (fP250Location[0] != 0.0 && fP250Location[1] != 0.0 && fP250Location[2] != 0.0)
					{
						float fClientLocation[3];
						GetClientAbsOrigin(client, fClientLocation);
						
						if (GetVectorDistance(fClientLocation, fP250Location) < 500.0)
						{
							BotMoveTo(client, fP250Location, FASTEST_ROUTE);
							
							if (GetVectorDistance(fClientLocation, fP250Location) < 25.0 && GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY) != -1)
							{
								CS_DropWeapon(client, GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY), false, false);
							}
						}
					}
				}
			}
			
			if (IsValidEntity(iUSP))
			{
				float fUSPLocation[3];
				
				if (iSecondary != -1)
				{
					iSecondaryDefIndex = GetEntProp(iSecondary, Prop_Send, "m_iItemDefinitionIndex");
				}
				
				if (iSecondaryDefIndex == 4)
				{
					GetEntPropVector(iUSP, Prop_Send, "m_vecOrigin", fUSPLocation);
					
					if (fUSPLocation[0] != 0.0 && fUSPLocation[1] != 0.0 && fUSPLocation[2] != 0.0)
					{
						float fClientLocation[3];
						GetClientAbsOrigin(client, fClientLocation);
						
						if (GetVectorDistance(fClientLocation, fUSPLocation) < 500.0)
						{
							BotMoveTo(client, fUSPLocation, FASTEST_ROUTE);
							
							if (GetVectorDistance(fClientLocation, fUSPLocation) < 25.0 && GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY) != -1)
							{
								CS_DropWeapon(client, GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY), false, false);
							}
						}
					}
				}
			}
		}
	}
	
	return MRES_Ignored;
}

public Action OnPlayerRunCmd(int client, int & iButtons, int & iImpulse, float fVel[3], float fAngles[3], int & iWeapon, int & iSubtype, int & iCmdNum, int & iTickCount, int & iSeed, int iMouse[2])
{
	if (!IsFakeClient(client))return Plugin_Continue;
	
	int iActiveWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if (iActiveWeapon == -1)return Plugin_Continue;
	
	int iDefIndex = GetEntProp(iActiveWeapon, Prop_Send, "m_iItemDefinitionIndex");
	
	if (IsValidClient(client) && IsPlayerAlive(client))
	{
		float fClientLoc[3];
		
		GetClientAbsOrigin(client, fClientLoc);
		
		CNavArea currArea = NavMesh_GetNearestArea(fClientLoc);
		
		if(currArea != INVALID_NAV_AREA)
		{
			if (currArea.Attributes & NAV_MESH_WALK)
			{
				iButtons |= IN_SPEED;
				return Plugin_Changed;
			}
			
			if (currArea.Attributes & NAV_MESH_RUN)
			{
				iButtons &= ~IN_SPEED;
				return Plugin_Changed;
			}	
		}
		
		if (g_bIsProBot[client])
		{
			float fClientEyes[3], fTargetEyes[3];
			GetClientEyePosition(client, fClientEyes);
			int iEnt = -1;
			fTargetEyes = SelectBestTargetPos(client, iEnt);
			
			if (GetEntProp(client, Prop_Send, "m_bIsScoped") == 0)
			{
				g_bZoomed[client] = false;
			}
			
			if (BotIsHiding(client) && g_iUncrouchChance[client] <= 50)
			{
				iButtons &= ~IN_DUCK;
				return Plugin_Changed;
			}
			
			if (g_bFreezetimeEnd && !g_bBombPlanted && g_bDoExecute && (GetTotalRoundTime() - GetCurrentRoundTime() >= 60) && GetClientTeam(client) == CS_TEAM_T && !g_bHasThrownNade[client] && GetAliveTeamCount(CS_TEAM_T) >= 3 && GetAliveTeamCount(CS_TEAM_CT) > 0 && (iEnt == -1 || fTargetEyes[2] == 0))
			{
				DoExecute(client, iButtons, iDefIndex);
			}
			
			if (iEnt == -1 || fTargetEyes[2] == 0)
			{
				g_bCanAttack[client] = false;
				return Plugin_Continue;
			}
			
			if (g_bFreezetimeEnd && g_bCanAttack[client])
			{
				if (GetEntityMoveType(client) == MOVETYPE_LADDER)
				{
					return Plugin_Continue;
				}
				
				if (eItems_GetWeaponSlotByDefIndex(iDefIndex) == CS_SLOT_KNIFE || eItems_GetWeaponSlotByDefIndex(iDefIndex) == CS_SLOT_GRENADE)
				{
					BotEquipBestWeapon(client, true);
				}
				
				if (IsPlayerReloading(client))
				{
					if (Math_GetRandomInt(1, 100) <= 50)
					{
						moveSide(fVel, 250.0);
					}
					else
					{
						moveSide2(fVel, 250.0);
					}
				}
				
				if ((eItems_GetWeaponSlotByDefIndex(iDefIndex) == CS_SLOT_PRIMARY && iDefIndex != 40 && iDefIndex != 11 && iDefIndex != 38 && iDefIndex != 9 && iDefIndex != 27 && iDefIndex != 29 && iDefIndex != 35) || iDefIndex == 63)
				{
					if (IsTargetInSightRange(client, iEnt, 10.0) && GetVectorDistance(fClientEyes, fTargetEyes) < 2000.0 && !IsPlayerReloading(client))
					{
						iButtons |= IN_ATTACK;
					}
					
					if (IsTargetInSightRange(client, iEnt, 10.0) && !(GetEntityFlags(client) & FL_DUCKING))
					{
						fVel[0] = 0.0;
						fVel[1] = 0.0;
						fVel[2] = 0.0;
					}
				}
				else if ((eItems_GetWeaponSlotByDefIndex(iDefIndex) == CS_SLOT_SECONDARY && iDefIndex != 63 && iDefIndex != 1) || iDefIndex == 27 || iDefIndex == 29 || iDefIndex == 35)
				{
					if (Math_GetRandomInt(1, 100) <= 50)
					{
						moveSide(fVel, 250.0);
					}
					else
					{
						moveSide2(fVel, 250.0);
					}
				}
				else if (iDefIndex == 1)
				{
					if (IsTargetInSightRange(client, iEnt, 10.0) && !(GetEntityFlags(client) & FL_DUCKING))
					{
						fVel[0] = 0.0;
						fVel[1] = 0.0;
						fVel[2] = 0.0;
					}
				}
				else if (iDefIndex == 9 || iDefIndex == 40)
				{
					if (GetClientAimTarget(client, true) == iEnt && g_bZoomed[client])
					{
						iButtons |= IN_ATTACK;
						
						fVel[0] = 0.0;
						fVel[1] = 0.0;
						fVel[2] = 0.0;
					}
				}
				
				BotAttack(client, iEnt);
				
				float fClientPos[3];
				GetClientAbsOrigin(client, fClientPos);
				fClientPos[2] += 35.5;
				
				if (IsPointVisible(fClientPos, fTargetEyes) && IsTargetInSightRange(client, iEnt, 10.0) && GetVectorDistance(fClientEyes, fTargetEyes) < 2000.0 && (iDefIndex == 7 || iDefIndex == 8 || iDefIndex == 10 || iDefIndex == 13 || iDefIndex == 14 || iDefIndex == 16 || iDefIndex == 39 || iDefIndex == 60 || iDefIndex == 28))
				{
					iButtons |= IN_DUCK;
					return Plugin_Changed;
				}
				
				return Plugin_Changed;
			}
		}
	}
	
	return Plugin_Changed;
}

public void OnPlayerSpawn(Handle hEvent, const char[] szName, bool bDontBroadcast)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && IsFakeClient(i) && IsPlayerAlive(i))
		{
			CreateTimer(1.0, RFrame_CheckBuyZoneValue, GetClientSerial(i));
			
			if (g_iUSPChance[i] >= 25)
			{
				if (GetClientTeam(i) == CS_TEAM_CT)
				{
					char szUSP[32];
					
					GetClientWeapon(i, szUSP, sizeof(szUSP));
					
					if (strcmp(szUSP, "weapon_hkp2000") == 0)
					{
						CSGO_ReplaceWeapon(i, CS_SLOT_SECONDARY, "weapon_usp_silencer");
					}
				}
			}
		}
	}
}

public Action RFrame_CheckBuyZoneValue(Handle hTimer, int iSerial)
{
	int client = GetClientFromSerial(iSerial);
	
	if (!client || !IsClientInGame(client) || !IsPlayerAlive(client))return Plugin_Stop;
	int iTeam = GetClientTeam(client);
	if (iTeam < 2)return Plugin_Stop;
	
	int iAccount = GetEntProp(client, Prop_Send, "m_iAccount");
	
	bool bInBuyZone = view_as<bool>(GetEntProp(client, Prop_Send, "m_bInBuyZone"));
	
	if (!bInBuyZone)return Plugin_Stop;
	
	int iPrimary = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
	
	char szDefaultPrimary[64];
	GetClientWeapon(client, szDefaultPrimary, sizeof(szDefaultPrimary));
	
	if ((iAccount > 2000) && (iAccount < 3000) && iPrimary == -1 && (strcmp(szDefaultPrimary, "weapon_hkp2000") == 0 || strcmp(szDefaultPrimary, "weapon_usp_silencer") == 0 || strcmp(szDefaultPrimary, "weapon_glock") == 0))
	{
		int iRndPistol = Math_GetRandomInt(1, 3);
		
		switch (iRndPistol)
		{
			case 1:
			{
				CSGO_ReplaceWeapon(client, CS_SLOT_SECONDARY, "weapon_p250");
			}
			case 2:
			{
				int iCZ = Math_GetRandomInt(1, 2);
				
				switch (iCZ)
				{
					case 1:
					{
						CSGO_ReplaceWeapon(client, CS_SLOT_SECONDARY, (iTeam == CS_TEAM_CT) ? "weapon_fiveseven" : "weapon_tec9");
					}
					case 2:
					{
						CSGO_ReplaceWeapon(client, CS_SLOT_SECONDARY, "weapon_cz75a");
					}
				}
			}
			case 3:
			{
				CSGO_ReplaceWeapon(client, CS_SLOT_SECONDARY, "weapon_deagle");
			}
		}
	}
	return Plugin_Stop;
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

bool GetNade(const char[] szNade, float fPos[3], float fLookAt[3], float fAng[3], float &fWaitTime, bool &bJumpthrow, bool &bCrouch)
{
	char szPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, szPath, sizeof(szPath), "configs/%s.txt", g_szMap);
	
	if (!FileExists(szPath))
	{
		PrintToServer("Configuration file %s is not found.", szPath);
		return false;
	}
	
	KeyValues kv = new KeyValues(g_szMap);
	
	if (!kv.ImportFromFile(szPath))
	{
		delete kv;
		PrintToServer("Unable to parse Key Values file %s.", szPath);
		return false;
	}
	
	if (!kv.JumpToKey(szNade))
	{
		delete kv;
		PrintToServer("Unable to find %s section in file %s.", szNade, szPath);
		return false;
	}
	
	kv.GetVector("position", fPos);
	kv.GetVector("lookpos", fLookAt);
	kv.GetVector("angles", fAng);
	fWaitTime = kv.GetFloat("waittime");
	bJumpthrow = !!kv.GetNum("jumpthrow");
	bCrouch = !!kv.GetNum("crouch");	
	delete kv;
	
	return true;
}

bool GetPosition(const char[] szPos, float fLookAt[3], float &fWaitTime)
{
	char szPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, szPath, sizeof(szPath), "configs/%s.txt", g_szMap);
	
	if (!FileExists(szPath))
	{
		PrintToServer("Configuration file %s is not found.", szPath);
		return false;
	}
	
	KeyValues kv = new KeyValues(g_szMap);
	
	if (!kv.ImportFromFile(szPath))
	{
		delete kv;
		PrintToServer("Unable to parse Key Values file %s.", szPath);
		return false;
	}
	
	if (!kv.JumpToKey(szPos))
	{
		delete kv;
		PrintToServer("Unable to find %s section in file %s.", szPos, szPath);
		return false;
	}
	
	kv.GetVector("lookpos", fLookAt);
	fWaitTime = kv.GetFloat("waittime");
	delete kv;
	
	return true;
}

public void DoExecute(int client, int& iButtons, int iDefIndex)
{
	float fClientLocation[3];
	
	GetClientAbsOrigin(client, fClientLocation);
	
	if(strcmp(g_szSmoke[client], "") != 0)
	{
		if (!g_bHasThrownSmoke[client])
		{
			float fSmoke[3], fLookAt[3], fAng[3], fWaitTime;
			bool bJumpthrow, bCrouch;
			
			if (GetNade(g_szSmoke[client], fSmoke, fLookAt, fAng, fWaitTime, bJumpthrow, bCrouch))
			{
				float fSmokeDis = GetVectorDistance(fClientLocation, fSmoke);
			
				BotMoveTo(client, fSmoke, FASTEST_ROUTE);
				
				if (fSmokeDis < 150.0)
				{
					if (iDefIndex != 45)
					{
						FakeClientCommandEx(client, "use weapon_smokegrenade");
					}
				}
				
				if (fSmokeDis < 25.0)
				{					
					BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, fWaitTime, true, 5.0, false);
					
					CreateTimer(fWaitTime, Timer_ThrowSmoke, GetClientUserId(client));
					
					iButtons |= IN_ATTACK;
					
					if(bCrouch)
					{
						iButtons |= IN_DUCK;
					}
					
					if (g_bCanThrowSmoke[client])
					{
						TeleportEntity(client, fSmoke, fAng, NULL_VECTOR);
						iButtons &= ~IN_ATTACK;
						
						if(bJumpthrow)
						{
							iButtons |= IN_JUMP;
						}
						
						if(bCrouch)
						{
							iButtons |= IN_DUCK;
						}
						
						if(strcmp(g_szFlashbang[client], "") != 0)
						{
							CreateTimer(0.2, Timer_SmokeDelay, GetClientUserId(client));	
						}
						else
						{
							CreateTimer(0.2, Timer_NadeDelay, GetClientUserId(client));
						}
					}
				}
			}
		}
	}
	
	if(strcmp(g_szFlashbang[client], "") != 0 && g_bHasThrownSmoke[client])
	{
		float fFlash[3], fLookAt[3], fAng[3], fWaitTime;
		bool bJumpthrow, bCrouch;
		
		if (GetNade(g_szFlashbang[client], fFlash, fLookAt, fAng, fWaitTime, bJumpthrow, bCrouch))
		{
			float fFlashDis = GetVectorDistance(fClientLocation, fFlash);
		
			BotMoveTo(client, fFlash, FASTEST_ROUTE);
			
			if (fFlashDis < 150.0)
			{
				if (iDefIndex != 43)
				{
					FakeClientCommandEx(client, "use weapon_flashbang");
				}
			}
			
			if (fFlashDis < 25.0)
			{
				BotSetLookAt(client, "Use entity", fLookAt, PRIORITY_HIGH, fWaitTime, true, 5.0, false);
				
				CreateTimer(fWaitTime, Timer_ThrowFlash, GetClientUserId(client));
				
				iButtons |= IN_ATTACK;
				
				if(bCrouch)
				{
					iButtons |= IN_DUCK;
				}
				
				if (g_bCanThrowFlash[client])
				{
					TeleportEntity(client, fFlash, fAng, NULL_VECTOR);
					iButtons &= ~IN_ATTACK;
					
					if(bJumpthrow)
					{
						iButtons |= IN_JUMP;
					}
					
					if(bCrouch)
					{
						iButtons |= IN_DUCK;
					}
					
					CreateTimer(0.2, Timer_NadeDelay, GetClientUserId(client));
				}
			}
		}
	}
	
	if(strcmp(g_szPosition[client], "") != 0)
	{
		float fLookAt[3], fWaitTime;
		
		if (GetPosition(g_szPosition[client], fLookAt, fWaitTime))
		{
			if (!g_bCanThrowSmoke[client])
			{				
				float fHoldSpotDis = GetVectorDistance(fClientLocation, g_fHoldPos[client]);
				
				BotMoveTo(client, g_fHoldPos[client], FASTEST_ROUTE);
				
				if (fHoldSpotDis < 25.0)
				{
					float fBentLook[3], fEyePos[3];
					
					GetClientEyePosition(client, fEyePos);
					
					BotBendLineOfSight(client, fEyePos, fLookAt, fBentLook, 135.0);
					BotSetLookAt(client, "Use entity", fBentLook, PRIORITY_HIGH, fWaitTime, true, 5.0, false);
					
					CreateTimer(fWaitTime, Timer_ThrowSmoke, GetClientUserId(client));
				}
			}
		}	
	}
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

public void LoadSDK()
{
	Handle hGameConfig = LoadGameConfigFile("botstuff.games");
	if (hGameConfig == INVALID_HANDLE)
		SetFailState("Failed to find botstuff.games game config.");
	
	if ((g_iBotTargetSpotXOffset = GameConfGetOffset(hGameConfig, "CCSBot::m_targetSpot.x")) == -1)
	{
		SetFailState("Failed to get CCSBot::m_targetSpot.x offset.");
	}
	
	if ((g_iBotTargetSpotYOffset = GameConfGetOffset(hGameConfig, "CCSBot::m_targetSpot.y")) == -1)
	{
		SetFailState("Failed to get CCSBot::m_targetSpot.y offset.");
	}
	
	if ((g_iBotTargetSpotZOffset = GameConfGetOffset(hGameConfig, "CCSBot::m_targetSpot.z")) == -1)
	{
		SetFailState("Failed to get CCSBot::m_targetSpot.z offset.");
	}
	
	if ((g_iBotNearbyEnemiesOffset = GameConfGetOffset(hGameConfig, "CCSBot::m_nearbyEnemyCount")) == -1)
	{
		SetFailState("Failed to get CCSBot::m_nearbyEnemyCount offset.");
	}
	
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConfig, SDKConf_Signature, "CCSBot::MoveTo");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Pointer); // Move Position As Vector, Pointer
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain); // Move Type As Integer
	if ((g_hBotMoveTo = EndPrepSDKCall()) == INVALID_HANDLE)SetFailState("Failed to create SDKCall for CCSBot::MoveTo signature!");
	
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hGameConfig, SDKConf_Signature, "CBaseAnimating::LookupBone");
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	if ((g_hLookupBone = EndPrepSDKCall()) == INVALID_HANDLE)SetFailState("Failed to create SDKCall for CBaseAnimating::LookupBone signature!");
	
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hGameConfig, SDKConf_Signature, "CBaseAnimating::GetBonePosition");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef, _, VENCODE_FLAG_COPYBACK);
	PrepSDKCall_AddParameter(SDKType_QAngle, SDKPass_ByRef, _, VENCODE_FLAG_COPYBACK);
	if ((g_hGetBonePosition = EndPrepSDKCall()) == INVALID_HANDLE)SetFailState("Failed to create SDKCall for CBaseAnimating::GetBonePosition signature!");
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConfig, SDKConf_Signature, "CCSBot::Attack");
	PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
	if ((g_hBotAttack = EndPrepSDKCall()) == INVALID_HANDLE)SetFailState("Failed to create SDKCall for CCSBot::Attack signature!");
	
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hGameConfig, SDKConf_Signature, "CCSBot::IsVisible");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer, VDECODE_FLAG_ALLOWNULL);
	PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
	if ((g_hBotIsVisible = EndPrepSDKCall()) == INVALID_HANDLE)SetFailState("Failed to create SDKCall for CCSBot::IsVisible signature!");
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConfig, SDKConf_Signature, "CCSBot::IsBusy");
	PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
	if ((g_hBotIsBusy = EndPrepSDKCall()) == INVALID_HANDLE)SetFailState("Failed to create SDKCall for CCSBot::IsBusy signature!");
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConfig, SDKConf_Signature, "CCSBot::IsAtHidingSpot");
	PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
	if ((g_hBotIsHiding = EndPrepSDKCall()) == INVALID_HANDLE)SetFailState("Failed to create SDKCall for CCSBot::IsAtHidingSpot signature!");
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConfig, SDKConf_Signature, "CCSBot::EquipBestWeapon");
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
	if ((g_hBotEquipBestWeapon = EndPrepSDKCall()) == INVALID_HANDLE)SetFailState("Failed to create SDKCall for CCSBot::EquipBestWeapon signature!");
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConfig, SDKConf_Signature, "CCSBot::SetLookAt");
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
	if ((g_hBotSetLookAt = EndPrepSDKCall()) == INVALID_HANDLE)SetFailState("Failed to create SDKCall for CCSBot::SetLookAt signature!");
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConfig, SDKConf_Signature, "CCSBot::BendLineOfSight");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef, _, VENCODE_FLAG_COPYBACK);
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
	if ((g_hBotBendLineOfSight = EndPrepSDKCall()) == INVALID_HANDLE)SetFailState("Failed to create SDKCall for CCSBot::BendLineOfSight signature!");
	
	delete hGameConfig;
}

public void LoadDetours()
{
	Handle hGameData = LoadGameConfigFile("botstuff.games");
	if (!hGameData)
	{
		SetFailState("Failed to load botstuff gamedata.");
		return;
	}
	
	//CCSBot::SetLookAt Detour
	g_hBotSetLookAtDetour = DHookCreateDetour(Address_Null, CallConv_THISCALL, ReturnType_Void, ThisPointer_CBaseEntity);
	if (!g_hBotSetLookAtDetour)
		SetFailState("Failed to setup detour for CCSBot::SetLookAt");
	
	if (!DHookSetFromConf(g_hBotSetLookAtDetour, hGameData, SDKConf_Signature, "CCSBot::SetLookAt"))
		SetFailState("Failed to load CCSBot::SetLookAt signature from gamedata");
	
	DHookAddParam(g_hBotSetLookAtDetour, HookParamType_CharPtr); // desc
	DHookAddParam(g_hBotSetLookAtDetour, HookParamType_VectorPtr); // pos
	DHookAddParam(g_hBotSetLookAtDetour, HookParamType_Int); // pri
	DHookAddParam(g_hBotSetLookAtDetour, HookParamType_Float); // duration
	DHookAddParam(g_hBotSetLookAtDetour, HookParamType_Bool); // clearIfClose
	DHookAddParam(g_hBotSetLookAtDetour, HookParamType_Float); // angleTolerance
	DHookAddParam(g_hBotSetLookAtDetour, HookParamType_Bool); // attack
	
	if (!DHookEnableDetour(g_hBotSetLookAtDetour, false, Detour_OnBOTSetLookAt))
		SetFailState("Failed to detour CCSBot::SetLookAt.");
	
	//CCSBot:Update Detour
	g_hBotUpdateDetour = DHookCreateDetour(Address_Null, CallConv_THISCALL, ReturnType_Void, ThisPointer_CBaseEntity);
	if (!g_hBotUpdateDetour)
		SetFailState("Failed to setup detour for CCSBot::Update");
	
	if (!DHookSetFromConf(g_hBotUpdateDetour, hGameData, SDKConf_Signature, "CCSBot::Update"))
		SetFailState("Failed to load CCSBot::Update signature from gamedata");
	
	if (!DHookEnableDetour(g_hBotUpdateDetour, false, Detour_OnBOTUpdate))
		SetFailState("Failed to detour CCSBot::Update.");
	
	//CCSBot::PickNewAimSpot Detour
	g_hBotPickNewAimSpotDetour = DHookCreateDetour(Address_Null, CallConv_THISCALL, ReturnType_Void, ThisPointer_CBaseEntity);
	if (!g_hBotPickNewAimSpotDetour)
		SetFailState("Failed to setup detour for CCSBot::PickNewAimSpot");
	
	if (!DHookSetFromConf(g_hBotPickNewAimSpotDetour, hGameData, SDKConf_Signature, "CCSBot::PickNewAimSpot"))
		SetFailState("Failed to load CCSBot::PickNewAimSpot signature from gamedata");
	
	if (!DHookEnableDetour(g_hBotPickNewAimSpotDetour, true, Detour_OnBOTPickNewAimSpot))
		SetFailState("Failed to detour CCSBot::PickNewAimSpot.");
	
	//CCSBot::ThrowGrenade Detour
	g_hBotThrowGrenadeDetour = DHookCreateDetour(Address_Null, CallConv_THISCALL, ReturnType_Void, ThisPointer_CBaseEntity);
	if (!g_hBotThrowGrenadeDetour)
		SetFailState("Failed to setup detour for CCSBot::ThrowGrenade");
	
	if (!DHookSetFromConf(g_hBotThrowGrenadeDetour, hGameData, SDKConf_Signature, "CCSBot::ThrowGrenade"))
		SetFailState("Failed to load CCSBot::ThrowGrenade signature from gamedata");
	
	DHookAddParam(g_hBotThrowGrenadeDetour, HookParamType_VectorPtr); // target
	
	if (!DHookEnableDetour(g_hBotThrowGrenadeDetour, false, Detour_OnBOTThrowGrenade))
		SetFailState("Failed to detour CCSBot::ThrowGrenade.");
	
	delete hGameData;
}

public void BotMoveTo(int client, float fOrigin[3], RouteType routeType)
{
	SDKCall(g_hBotMoveTo, client, fOrigin, routeType);
}

public void BotAttack(int client, int iEnemy)
{
	SDKCall(g_hBotAttack, client, iEnemy);
}

public bool BotIsVisible(int client, float fPos[3], bool bTestFOV, int iIgnore)
{
	return SDKCall(g_hBotIsVisible, client, fPos, bTestFOV, iIgnore);
}

public bool BotIsBusy(int client)
{
	return SDKCall(g_hBotIsBusy, client);
}

public bool BotIsHiding(int client)
{
	return SDKCall(g_hBotIsHiding, client);
}

public int BotEquipBestWeapon(int client, bool bMustEquip)
{
	SDKCall(g_hBotEquipBestWeapon, client, bMustEquip);
}

public int BotSetLookAt(int client, const char[] szDesc, const float fPos[3], PriorityType pri, float fDuration, bool bClearIfClose, float fAngleTolerance, bool bAttack)
{
	SDKCall(g_hBotSetLookAt, client, szDesc, fPos, pri, fDuration, bClearIfClose, fAngleTolerance, bAttack);
}

public int BotBendLineOfSight(int client, const float fEye[3], const float fTarget[3], float fBend[3], float fAngleLimit)
{
	SDKCall(g_hBotBendLineOfSight, client, fEye, fTarget, fBend, fAngleLimit);
}

public int LookupBone(int iEntity, const char[] szName)
{
	return SDKCall(g_hLookupBone, iEntity, szName);
}

public void GetBonePosition(int iEntity, int iBone, float fOrigin[3], float fAngles[3])
{
	SDKCall(g_hGetBonePosition, iEntity, iBone, fOrigin, fAngles);
}

public int GetNearestEntity(int client, char[] szClassname)
{
	int iNearestEntity = -1;
	float fClientOrigin[3], fEntityOrigin[3];
	
	GetEntPropVector(client, Prop_Data, "m_vecOrigin", fClientOrigin); // Line 2607
	
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

float moveSide(float fVel[3], float fMaxSpeed)
{
	fVel[1] = fMaxSpeed;
	return fVel;
}

float moveSide2(float fVel[3], float fMaxSpeed)
{
	fVel[1] = -fMaxSpeed;
	return fVel;
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
	
	if (!IsValidEntity(iPlayerWeapon))
		return true;
	
	bool bReloading = true;
	
	float flNextPrimaryAttack = GetGameTime() - GetEntPropFloat(iPlayerWeapon, Prop_Send, "m_flNextPrimaryAttack");
	
	bool m_bInReload = !!GetEntProp(iPlayerWeapon, Prop_Data, "m_bInReload");
	
	//Can fire?
	if (flNextPrimaryAttack > 0)
		bReloading = false;
	
	//Has ammo and is not reloading
	if (GetEntProp(iPlayerWeapon, Prop_Send, "m_iClip1") <= 0 || m_bInReload)
		bReloading = true;
	
	return bReloading;
}

stock int GetTotalRoundTime()
{
	return GameRules_GetProp("m_iRoundTime");
}

stock int GetCurrentRoundTime()
{
	Handle hFreezeTime = FindConVar("mp_freezetime"); // Freezetime Handle
	int iFreezeTime = GetConVarInt(hFreezeTime); // Freezetime in seconds (5 by default)
	return (GetTime() - g_iRoundStartedTime) - iFreezeTime;
}

public Action Timer_Attack(Handle hTimer, any client)
{
	client = GetClientOfUserId(client);
	
	if(client != 0 && IsClientInGame(client))
	{
		g_bCanAttack[client] = true;
	}
	
	return Plugin_Stop;
}

public Action Timer_ThrowSmoke(Handle hTimer, any client)
{
	client = GetClientOfUserId(client);
	
	if(client != 0 && IsClientInGame(client))
	{
		g_bCanThrowSmoke[client] = true;
	}
	
	return Plugin_Stop;
}

public Action Timer_ThrowFlash(Handle hTimer, any client)
{
	client = GetClientOfUserId(client);
	
	if(client != 0 && IsClientInGame(client))
	{
		g_bCanThrowFlash[client] = true;
	}
	
	return Plugin_Stop;
}

public Action Timer_SmokeDelay(Handle hTimer, any client)
{
	client = GetClientOfUserId(client);
	
	if(client != 0 && IsClientInGame(client))
	{
		g_bHasThrownSmoke[client] = true;
	}
	
	return Plugin_Stop;
}

public Action Timer_NadeDelay(Handle hTimer, any client)
{
	client = GetClientOfUserId(client);
	
	if(client != 0 && IsClientInGame(client))
	{
		g_bHasThrownNade[client] = true;
	}
	
	return Plugin_Stop;
}

public Action Timer_Zoomed(Handle hTimer, any client)
{
	client = GetClientOfUserId(client);
	
	if(client != 0 && IsClientInGame(client))
	{
		g_bZoomed[client] = true;	
	}
	
	return Plugin_Stop;
}

float[] SelectBestTargetPos(int client, int &iBestEnemy)
{
	float fMyPos[3];
	GetClientAbsOrigin(client, fMyPos);
	
	float fTargetPos[3];
	float fClosestDistance = 999999999999999.0;
	
	int iActiveWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	int iDefIndex;
	if (iActiveWeapon != -1)
	{
		iDefIndex = GetEntProp(iActiveWeapon, Prop_Send, "m_iItemDefinitionIndex");
	}
	
	char szClanTag[MAX_NAME_LENGTH];
	
	CS_GetClientClanTag(client, szClanTag, sizeof(szClanTag));
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (i == client)
			continue;
		
		if (!IsClientInGame(i))
			continue;
		
		if (!IsPlayerAlive(i))
			continue;
		
		if (GetEntProp(i, Prop_Send, "m_bGunGameImmunity"))
			continue;
		
		if (GetClientTeam(i) == GetClientTeam(client))
			continue;
		
		if (strcmp(szClanTag, "Endpoint") == 0) //30th
		{
			if (!IsTargetInSightRange(client, i, 50.0))
				continue;
		}
		else if (strcmp(szClanTag, "Triumph") == 0) //29th
		{
			if (!IsTargetInSightRange(client, i, 60.0))
				continue;
		}
		else if (strcmp(szClanTag, "Sprout") == 0) //28th
		{
			if (!IsTargetInSightRange(client, i, 70.0))
				continue;
		}
		else if (strcmp(szClanTag, "ESPADA") == 0) //27th
		{
			if (!IsTargetInSightRange(client, i, 80.0))
				continue;
		}
		else if (strcmp(szClanTag, "North") == 0) //26th
		{
			if (!IsTargetInSightRange(client, i, 90.0))
				continue;
		}
		else if (strcmp(szClanTag, "Nemiga") == 0) //25th
		{
			if (!IsTargetInSightRange(client, i, 100.0))
				continue;
		}
		else if (strcmp(szClanTag, "One") == 0) //24th
		{
			if (!IsTargetInSightRange(client, i, 110.0))
				continue;
		}
		else if (strcmp(szClanTag, "C9") == 0) //23rd
		{
			if (!IsTargetInSightRange(client, i, 120.0))
				continue;
		}
		else if (strcmp(szClanTag, "Lions") == 0) //22nd
		{
			if (!IsTargetInSightRange(client, i, 130.0))
				continue;
		}
		else if (strcmp(szClanTag, "MIBR") == 0) //21st
		{
			if (!IsTargetInSightRange(client, i, 140.0))
				continue;
		}
		else if (strcmp(szClanTag, "Chaos") == 0) //20th
		{
			if (!IsTargetInSightRange(client, i, 150.0))
				continue;
		}
		else if (strcmp(szClanTag, "GODSENT") == 0) //19th
		{
			if (!IsTargetInSightRange(client, i, 160.0))
				continue;
		}
		else if (strcmp(szClanTag, "Spirit") == 0) //18th
		{
			if (!IsTargetInSightRange(client, i, 170.0))
				continue;
		}
		else if (strcmp(szClanTag, "Gambit") == 0) //17th
		{
			if (!IsTargetInSightRange(client, i, 180.0))
				continue;
		}
		else if (strcmp(szClanTag, "Liquid") == 0) //16th
		{
			if (!IsTargetInSightRange(client, i, 190.0))
				continue;
		}
		else if (strcmp(szClanTag, "EG") == 0) //15th
		{
			if (!IsTargetInSightRange(client, i, 200.0))
				continue;
		}
		else if (strcmp(szClanTag, "NiP") == 0) //14th
		{
			if (!IsTargetInSightRange(client, i, 210.0))
				continue;
		}
		else if (strcmp(szClanTag, "fnatic") == 0) //13th
		{
			if (!IsTargetInSightRange(client, i, 220.0))
				continue;
		}
		else if (strcmp(szClanTag, "FaZe") == 0) //12th
		{
			if (!IsTargetInSightRange(client, i, 230.0))
				continue;
		}
		else if (strcmp(szClanTag, "VP") == 0) //11th
		{
			if (!IsTargetInSightRange(client, i, 240.0))
				continue;
		}
		else if (strcmp(szClanTag, "coL") == 0) //10th
		{
			if (!IsTargetInSightRange(client, i, 250.0))
				continue;
		}
		else if (strcmp(szClanTag, "G2") == 0) //9th
		{
			if (!IsTargetInSightRange(client, i, 260.0))
				continue;
		}
		else if (strcmp(szClanTag, "mouz") == 0) //8th
		{
			if (!IsTargetInSightRange(client, i, 270.0))
				continue;
		}
		else if (strcmp(szClanTag, "FURIA") == 0) //7th
		{
			if (!IsTargetInSightRange(client, i, 280.0))
				continue;
		}
		else if (strcmp(szClanTag, "OG") == 0) //6th
		{
			if (!IsTargetInSightRange(client, i, 290.0))
				continue;
		}
		else if (strcmp(szClanTag, "BIG") == 0) //5th
		{
			if (!IsTargetInSightRange(client, i, 300.0))
				continue;
		}
		else if (strcmp(szClanTag, "Na´Vi") == 0) //4th
		{
			if (!IsTargetInSightRange(client, i, 310.0))
				continue;
		}
		else if (strcmp(szClanTag, "Heroic") == 0) //3rd
		{
			if (!IsTargetInSightRange(client, i, 320.0))
				continue;
		}
		else if (strcmp(szClanTag, "Astralis") == 0) //2nd
		{
			if (!IsTargetInSightRange(client, i, 330.0))
				continue;
		}
		else if (strcmp(szClanTag, "Vitality") == 0) //1st
		{
			if (!IsTargetInSightRange(client, i, 340.0))
				continue;
		}
		else
		{
			if (!IsTargetInSightRange(client, i))
				continue;
		}
		
		int iBone = LookupBone(i, "head_0");
		if (iBone < 0)
			continue;
		
		float fHead[3], fBad[3];
		GetBonePosition(i, iBone, fHead, fBad);
		
		if (BotIsVisible(client, fHead, false, -1))
		{
			g_bIsHeadVisible[client] = true;
		}
		else
		{
			bool bVisibleOther = false;
			
			//Head wasn't visible, check other bones.
			for (int b = 0; b <= sizeof(g_szBoneNames) - 1; b++)
			{
				iBone = LookupBone(i, g_szBoneNames[b]);
				if (iBone < 0)
					continue;
				
				GetBonePosition(i, iBone, fHead, fBad);
				
				if (BotIsVisible(client, fHead, false, -1))
				{
					g_bIsHeadVisible[client] = false;
					bVisibleOther = true;
					break;
				}
			}
			
			if (!bVisibleOther)
				continue;
		}
		
		float fEnemyPos[3];
		GetClientAbsOrigin(i, fEnemyPos);
		
		float fDistance = GetVectorDistance(fEnemyPos, fMyPos, true);
		if (fDistance < fClosestDistance)
		{
			fClosestDistance = fDistance;
			fTargetPos = fHead;
			
			iBestEnemy = i;
			
			if (iDefIndex == 9 || iDefIndex == 11 || iDefIndex == 38 || iDefIndex == 40)
			{
				g_bCanAttack[client] = true;
			}
			else
			{
				CreateTimer(0.18, Timer_Attack, GetClientUserId(client));
			}
		}
	}
	
	return fTargetPos;
}

stock bool IsTargetInSightRange(int client, int iTarget, float fAngle = 40.0, float fDistance = 0.0, bool bHeightcheck = true, bool bNegativeangle = false)
{
	if (fAngle > 360.0)
		fAngle = 360.0;
	
	if (fAngle < 0.0)
		return false;
	
	float fClientPos[3];
	float fTargetPos[3];
	float fAngleVector[3];
	float fTargetVector[3];
	float fResultAngle;
	float fResultDistance;
	
	GetClientEyeAngles(client, fAngleVector);
	fAngleVector[0] = fAngleVector[2] = 0.0;
	GetAngleVectors(fAngleVector, fAngleVector, NULL_VECTOR, NULL_VECTOR);
	NormalizeVector(fAngleVector, fAngleVector);
	if (bNegativeangle)
		NegateVector(fAngleVector);
	
	GetClientAbsOrigin(client, fClientPos);
	GetClientAbsOrigin(iTarget, fTargetPos);
	
	if (bHeightcheck && fDistance > 0)
		fResultDistance = GetVectorDistance(fClientPos, fTargetPos);
	
	fClientPos[2] = fTargetPos[2] = 0.0;
	MakeVectorFromPoints(fClientPos, fTargetPos, fTargetVector);
	NormalizeVector(fTargetVector, fTargetVector);
	
	fResultAngle = RadToDeg(ArcCosine(GetVectorDotProduct(fTargetVector, fAngleVector)));
	
	if (fResultAngle <= fAngle / 2)
	{
		if (fDistance > 0)
		{
			if (!bHeightcheck)
				fResultDistance = GetVectorDistance(fClientPos, fTargetPos);
			
			if (fDistance >= fResultDistance)
				return true;
			else return false;
		}
		else return true;
	}
	
	return false;
}

stock bool IsPointVisible(float fStart[3], float fEnd[3])
{
	TR_TraceRayFilter(fStart, fEnd, MASK_SHOT, RayType_EndPoint, TraceEntityFilterStuff);
	return TR_GetFraction() >= 0.9;
}

public bool TraceEntityFilterStuff(int iEntity, int iMask)
{
	return iEntity > MaxClients;
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

stock bool IsValidClient(int client)
{
	return client > 0 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && !IsClientSourceTV(client);
}