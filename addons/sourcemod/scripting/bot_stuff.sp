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
bool g_bIsProBot[MAXPLAYERS+1], g_bZoomed[MAXPLAYERS + 1], g_bDontSwitch[MAXPLAYERS+1], g_bDropWeapon[MAXPLAYERS+1], g_bHasGottenDrop[MAXPLAYERS+1];
int g_iProfileRank[MAXPLAYERS+1], g_iPlayerColor[MAXPLAYERS+1], g_iUncrouchChance[MAXPLAYERS+1], g_iUSPChance[MAXPLAYERS+1], g_iM4A1SChance[MAXPLAYERS+1], g_iTarget[MAXPLAYERS+1];
int g_iRndExecute, g_iCurrentRound, g_iProfileRankOffset, g_iPlayerColorOffset, g_iBotTargetSpotOffset, g_iBotNearbyEnemiesOffset, g_iBotTaskOffset, g_iFireWeaponOffset, g_iEnemyVisibleOffset, g_iBotProfileOffset, g_iBotSafeTimeOffset, g_iBotAttackingOffset, g_iBotEnemyOffset, g_iBotLookAtSpotStateOffset, g_iBotDispositionOffset, g_iBotMoraleOffset;
float g_fTargetPos[MAXPLAYERS+1][3], g_fNadeTarget[MAXPLAYERS+1][3], g_fLookAngleMaxAccel[MAXPLAYERS+1], g_fReactionTime[MAXPLAYERS+1], g_fRoundStart, g_fFreezeTimeEnd;
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
Handle g_hBotSetEnemy;
Handle g_hBotBendLineOfSight;
Address g_pTheBots;
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

enum TaskType
{
	SEEK_AND_DESTROY = 0,
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
}

enum DispositionType
{
	ENGAGE_AND_INVESTIGATE,								///< engage enemies on sight and investigate enemy noises
	OPPORTUNITY_FIRE,									///< engage enemies on sight, but only look towards enemy noises, dont investigate
	SELF_DEFENSE,										///< only engage if fired on, or very close to enemy
	IGNORE_ENEMIES,										///< ignore all enemies - useful for ducking around corners, running away, etc

	NUM_DISPOSITIONS
}

enum LookAtSpotState
{
	NOT_LOOKING_AT_SPOT,			///< not currently looking at a point in space
	LOOK_TOWARDS_SPOT,				///< in the process of aiming at m_lookAtSpot
	LOOK_AT_SPOT,					///< looking at m_lookAtSpot
	NUM_LOOK_AT_SPOT_STATES
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
	HookEventEx("round_start", OnRoundStart);
	HookEventEx("round_freeze_end", OnFreezetimeEnd);
	HookEventEx("weapon_zoom", OnWeaponZoom);
	HookEventEx("weapon_fire", OnWeaponFire);
	HookEventEx("round_announce_last_round_half", OnLastRoundHalf);
	
	LoadSDK();
	LoadDetours();
	
	g_cvBotEcoLimit = FindConVar("bot_eco_limit");
	
	RegConsoleCmd("team_nip", Team_NiP);
	RegConsoleCmd("team_mibr", Team_MIBR);
	RegConsoleCmd("team_faze", Team_FaZe);
	RegConsoleCmd("team_astralis", Team_Astralis);
	RegConsoleCmd("team_1win", Team_1win);
	RegConsoleCmd("team_g2", Team_G2);
	RegConsoleCmd("team_fnatic", Team_fnatic);
	RegConsoleCmd("team_dynamo", Team_Dynamo);
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
	RegConsoleCmd("team_santos", Team_Santos);
	RegConsoleCmd("team_col", Team_coL);
	RegConsoleCmd("team_atom", Team_Atom);
	RegConsoleCmd("team_forze", Team_forZe);
	RegConsoleCmd("team_sprout", Team_Sprout);
	RegConsoleCmd("team_heroic", Team_Heroic);
	RegConsoleCmd("team_vp", Team_VP);
	RegConsoleCmd("team_apeks", Team_Apeks);
	RegConsoleCmd("team_rng", Team_Renegades);
	RegConsoleCmd("team_gamerlegion", Team_GamerLegion);
	RegConsoleCmd("team_havu", Team_HAVU);
	RegConsoleCmd("team_ecstatic", Team_ECSTATIC);
	RegConsoleCmd("team_godsent", Team_GODSENT);
	RegConsoleCmd("team_rhyno", Team_Rhyno);
	RegConsoleCmd("team_riders", Team_Riders);
	RegConsoleCmd("team_esuba", Team_eSuba);
	RegConsoleCmd("team_nexus", Team_Nexus);
	RegConsoleCmd("team_pact", Team_PACT);
	RegConsoleCmd("team_nemiga", Team_Nemiga);
	RegConsoleCmd("team_gzg", Team_GZG);
	RegConsoleCmd("team_xian", Team_Xian);
	RegConsoleCmd("team_infinity", Team_Infinity);
	RegConsoleCmd("team_isurus", Team_Isurus);
	RegConsoleCmd("team_pain", Team_paiN);
	RegConsoleCmd("team_sharks", Team_Sharks);
	RegConsoleCmd("team_one", Team_One);
	RegConsoleCmd("team_order", Team_ORDER);
	RegConsoleCmd("team_skade", Team_SKADE);
	RegConsoleCmd("team_izako", Team_Izako);
	RegConsoleCmd("team_offset", Team_OFFSET);
	RegConsoleCmd("team_nasr", Team_NASR);
	RegConsoleCmd("team_ecb", Team_ECB);
	RegConsoleCmd("team_bravado", Team_Bravado);
	RegConsoleCmd("team_sh", Team_SH);
	RegConsoleCmd("team_gtz", Team_GTZ);
	RegConsoleCmd("team_eternal", Team_Eternal);
	RegConsoleCmd("team_k23", Team_K23);
	RegConsoleCmd("team_goliath", Team_Goliath);
	RegConsoleCmd("team_vertex", Team_VERTEX);
	RegConsoleCmd("team_ig", Team_IG);
	RegConsoleCmd("team_finest", Team_Finest);
	RegConsoleCmd("team_c9", Team_C9);
	RegConsoleCmd("team_wisla", Team_Wisla);
	RegConsoleCmd("team_attax", Team_aTTaX);
	RegConsoleCmd("team_Unique", Team_Unique);
	RegConsoleCmd("team_atk", Team_ATK);
	RegConsoleCmd("team_wings", Team_Wings);
	RegConsoleCmd("team_lynn", Team_Lynn);
	RegConsoleCmd("team_impact", Team_Impact);
	RegConsoleCmd("team_og", Team_OG);
	RegConsoleCmd("team_bne", Team_BNE);
	RegConsoleCmd("team_tricked", Team_Tricked);
	RegConsoleCmd("team_endpoint", Team_Endpoint);
	RegConsoleCmd("team_saw", Team_sAw);
	RegConsoleCmd("team_dig", Team_DIG);
	RegConsoleCmd("team_d13", Team_D13);
	RegConsoleCmd("team_divizon", Team_DIVIZON);
	RegConsoleCmd("team_kova", Team_KOVA);
	RegConsoleCmd("team_agf", Team_AGF);
	RegConsoleCmd("team_nlg", Team_NLG);
	RegConsoleCmd("team_lilmix", Team_Lilmix);
	RegConsoleCmd("team_ftw", Team_FTW);
	RegConsoleCmd("team_tigers", Team_Tigers);
	RegConsoleCmd("team_9z", Team_9z);
	RegConsoleCmd("team_sinners", Team_SINNERS);
	RegConsoleCmd("team_paradox", Team_Paradox);
	RegConsoleCmd("team_flames", Team_Flames);
	RegConsoleCmd("team_ep", Team_EP);
	RegConsoleCmd("team_lemondogs", Team_Lemondogs);
	RegConsoleCmd("team_alpha", Team_Alpha);
	RegConsoleCmd("team_sangal", Team_Sangal);
	RegConsoleCmd("team_ambush", Team_Ambush);
	RegConsoleCmd("team_supremacy", Team_Supremacy);
	RegConsoleCmd("team_catevil", Team_CatEvil);
	RegConsoleCmd("team_avez", Team_AVEZ);
	RegConsoleCmd("team_anonymo", Team_Anonymo);
	RegConsoleCmd("team_honoris", Team_HONORIS);
	RegConsoleCmd("team_spirit", Team_Spirit);
	RegConsoleCmd("team_dmnk", Team_DNMK);
	RegConsoleCmd("team_ination", Team_iNation);
	RegConsoleCmd("team_leisure", Team_LEISURE);
	RegConsoleCmd("team_bnb", Team_BNB);
	RegConsoleCmd("team_nation", Team_Nation);
	RegConsoleCmd("team_eriness", Team_Eriness);
	RegConsoleCmd("team_entropiq", Team_Entropiq);
	RegConsoleCmd("team_strife", Team_Strife);
	RegConsoleCmd("team_party", Team_Party);
	RegConsoleCmd("team_777", Team_777);
	RegConsoleCmd("team_CG", Team_CG);
	RegConsoleCmd("team_bluejays", Team_BLUEJAYS);
	RegConsoleCmd("team_eck", Team_ECK);
	RegConsoleCmd("team_conquer", Team_Conquer);
	RegConsoleCmd("team_avangar", Team_AVANGAR);
	RegConsoleCmd("team_sws", Team_SWS);
	RegConsoleCmd("team_leviatan", Team_Leviatan);
	RegConsoleCmd("team_furious", Team_Furious);
	RegConsoleCmd("team_mongolz", Team_MongolZ);
	RegConsoleCmd("team_onyx", Team_ONYX);
	RegConsoleCmd("team_dice", Team_Dice);
	RegConsoleCmd("team_falcons", Team_Falcons);
	RegConsoleCmd("team_gameagents", Team_GameAgents);
	RegConsoleCmd("team_entropy", Team_Entropy);
	RegConsoleCmd("team_ssp", Team_SSP);
	RegConsoleCmd("team_renewal", Team_Renewal);
	RegConsoleCmd("team_onetap", Team_OneTap);
	RegConsoleCmd("team_bp", Team_BP);
	RegConsoleCmd("team_mcon", Team_mCon);
	RegConsoleCmd("team_heet", Team_HEET);
	RegConsoleCmd("team_lll", Team_LLL);
	RegConsoleCmd("team_ldlc", Team_LDLC);
	RegConsoleCmd("team_vireo", Team_Vireo);
	RegConsoleCmd("team_imperial", Team_Imperial);
	RegConsoleCmd("team_berzerk", Team_Berzerk);
	RegConsoleCmd("team_k1ck", Team_K1CK);
	RegConsoleCmd("team_tc", Team_TC);
	RegConsoleCmd("team_lfo", Team_LFO);
	RegConsoleCmd("team_ag", Team_AG);
	RegConsoleCmd("team_nkt", Team_NKT);
	RegConsoleCmd("team_1shot", Team_1shot);
	RegConsoleCmd("team_boca", Team_Boca);
	RegConsoleCmd("team_itb", Team_ITB);
}

public Action Team_NiP(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "es3tag");
		ServerCommand("bot_add_ct %s", "device");
		ServerCommand("bot_add_ct %s", "hampus");
		ServerCommand("bot_add_ct %s", "Plopski");
		ServerCommand("bot_add_ct %s", "REZ");
		ServerCommand("mp_teamlogo_1 nip");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "es3tag");
		ServerCommand("bot_add_t %s", "device");
		ServerCommand("bot_add_t %s", "hampus");
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
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "chelo");
		ServerCommand("bot_add_ct %s", "yel");
		ServerCommand("bot_add_ct %s", "shz");
		ServerCommand("bot_add_ct %s", "boltz");
		ServerCommand("bot_add_ct %s", "exit");
		ServerCommand("mp_teamlogo_1 mibr");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "chelo");
		ServerCommand("bot_add_t %s", "yel");
		ServerCommand("bot_add_t %s", "shz");
		ServerCommand("bot_add_t %s", "boltz");
		ServerCommand("bot_add_t %s", "exit");
		ServerCommand("mp_teamlogo_2 mibr");
	}
	
	return Plugin_Handled;
}

public Action Team_FaZe(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Twistzz");
		ServerCommand("bot_add_ct %s", "broky");
		ServerCommand("bot_add_ct %s", "karrigan");
		ServerCommand("bot_add_ct %s", "rain");
		ServerCommand("bot_add_ct %s", "ropz");
		ServerCommand("mp_teamlogo_1 faze");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Twistzz");
		ServerCommand("bot_add_t %s", "broky");
		ServerCommand("bot_add_t %s", "karrigan");
		ServerCommand("bot_add_t %s", "rain");
		ServerCommand("bot_add_t %s", "ropz");
		ServerCommand("mp_teamlogo_2 faze");
	}
	
	return Plugin_Handled;
}

public Action Team_Astralis(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "gla1ve");
		ServerCommand("bot_add_ct %s", "farlig");
		ServerCommand("bot_add_ct %s", "Xyp9x");
		ServerCommand("bot_add_ct %s", "k0nfig");
		ServerCommand("bot_add_ct %s", "blameF");
		ServerCommand("mp_teamlogo_1 astr");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "gla1ve");
		ServerCommand("bot_add_t %s", "farlig");
		ServerCommand("bot_add_t %s", "Xyp9x");
		ServerCommand("bot_add_t %s", "k0nfig");
		ServerCommand("bot_add_t %s", "blameF");
		ServerCommand("mp_teamlogo_2 astr");
	}
	
	return Plugin_Handled;
}

public Action Team_1win(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "glowiing");
		ServerCommand("bot_add_ct %s", "flamie");
		ServerCommand("bot_add_ct %s", "TRAVIS");
		ServerCommand("bot_add_ct %s", "fostar");
		ServerCommand("bot_add_ct %s", "deko");
		ServerCommand("mp_teamlogo_1 1win");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "glowiing");
		ServerCommand("bot_add_t %s", "flamie");
		ServerCommand("bot_add_t %s", "TRAVIS");
		ServerCommand("bot_add_t %s", "fostar");
		ServerCommand("bot_add_t %s", "deko");
		ServerCommand("mp_teamlogo_2 1win");
	}
	
	return Plugin_Handled;
}

public Action Team_G2(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "huNter-");
		ServerCommand("bot_add_ct %s", "m0NESY");
		ServerCommand("bot_add_ct %s", "Aleksib");
		ServerCommand("bot_add_ct %s", "JaCkz");
		ServerCommand("bot_add_ct %s", "NiKo");
		ServerCommand("mp_teamlogo_1 g2");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "huNter-");
		ServerCommand("bot_add_t %s", "m0NESY");
		ServerCommand("bot_add_t %s", "Aleksib");
		ServerCommand("bot_add_t %s", "JaCkz");
		ServerCommand("bot_add_t %s", "NiKo");
		ServerCommand("mp_teamlogo_2 g2");
	}
	
	return Plugin_Handled;
}

public Action Team_fnatic(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "ALEX");
		ServerCommand("bot_add_ct %s", "poizon");
		ServerCommand("bot_add_ct %s", "KRIMZ");
		ServerCommand("bot_add_ct %s", "Peppzor");
		ServerCommand("bot_add_ct %s", "mezii");
		ServerCommand("mp_teamlogo_1 fntc");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "ALEX");
		ServerCommand("bot_add_t %s", "poizon");
		ServerCommand("bot_add_t %s", "KRIMZ");
		ServerCommand("bot_add_t %s", "Peppzor");
		ServerCommand("bot_add_t %s", "mezii");
		ServerCommand("mp_teamlogo_2 fntc");
	}
	
	return Plugin_Handled;
}

public Action Team_Dynamo(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Dytor");
		ServerCommand("bot_add_ct %s", "capseN");
		ServerCommand("bot_add_ct %s", "K1-FiDa");
		ServerCommand("bot_add_ct %s", "Valencio");
		ServerCommand("bot_add_ct %s", "nbqq");
		ServerCommand("mp_teamlogo_1 dyna");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Dytor");
		ServerCommand("bot_add_t %s", "capseN");
		ServerCommand("bot_add_t %s", "K1-FiDa");
		ServerCommand("bot_add_t %s", "Valencio");
		ServerCommand("bot_add_t %s", "nbqq");
		ServerCommand("mp_teamlogo_2 dyna");
	}
	
	return Plugin_Handled;
}

public Action Team_mouz(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "dexter");
		ServerCommand("bot_add_ct %s", "torzsi");
		ServerCommand("bot_add_ct %s", "Bymas");
		ServerCommand("bot_add_ct %s", "frozen");
		ServerCommand("bot_add_ct %s", "JDC");
		ServerCommand("mp_teamlogo_1 mouz");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "dexter");
		ServerCommand("bot_add_t %s", "torzsi");
		ServerCommand("bot_add_t %s", "Bymas");
		ServerCommand("bot_add_t %s", "frozen");
		ServerCommand("bot_add_t %s", "JDC");
		ServerCommand("mp_teamlogo_2 mouz");
	}
	
	return Plugin_Handled;
}

public Action Team_TYLOO(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Summer");
		ServerCommand("bot_add_ct %s", "Attacker");
		ServerCommand("bot_add_ct %s", "SLOWLY");
		ServerCommand("bot_add_ct %s", "somebody");
		ServerCommand("bot_add_ct %s", "DANK1NG");
		ServerCommand("mp_teamlogo_1 tyl");
	}
	
	if (strcmp(arg, "t") == 0)
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
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Stewie2K");
		ServerCommand("bot_add_ct %s", "CeRq");
		ServerCommand("bot_add_ct %s", "Brehze");
		ServerCommand("bot_add_ct %s", "autimatic");
		ServerCommand("bot_add_ct %s", "RUSH");
		ServerCommand("mp_teamlogo_1 evl");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Stewie2K");
		ServerCommand("bot_add_t %s", "CeRq");
		ServerCommand("bot_add_t %s", "Brehze");
		ServerCommand("bot_add_t %s", "autimatic");
		ServerCommand("bot_add_t %s", "RUSH");
		ServerCommand("mp_teamlogo_2 evl");
	}
	
	return Plugin_Handled;
}

public Action Team_NaVi(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "electronic");
		ServerCommand("bot_add_ct %s", "s1mple");
		ServerCommand("bot_add_ct %s", "B1T");
		ServerCommand("bot_add_ct %s", "Boombl4");
		ServerCommand("bot_add_ct %s", "Perfecto");
		ServerCommand("mp_teamlogo_1 navi");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "electronic");
		ServerCommand("bot_add_t %s", "s1mple");
		ServerCommand("bot_add_t %s", "B1T");
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
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "shox");
		ServerCommand("bot_add_ct %s", "oSee");
		ServerCommand("bot_add_ct %s", "nitr0");
		ServerCommand("bot_add_ct %s", "ELiGE");
		ServerCommand("bot_add_ct %s", "NAF");
		ServerCommand("mp_teamlogo_1 liq");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "shox");
		ServerCommand("bot_add_t %s", "oSee");
		ServerCommand("bot_add_t %s", "nitr0");
		ServerCommand("bot_add_t %s", "ELiGE");
		ServerCommand("bot_add_t %s", "NAF");
		ServerCommand("mp_teamlogo_2 liq");
	}
	
	return Plugin_Handled;
}

public Action Team_AGO(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Furlan");
		ServerCommand("bot_add_ct %s", "Grashog");
		ServerCommand("bot_add_ct %s", "kRaSnaL");
		ServerCommand("bot_add_ct %s", "F1KU");
		ServerCommand("bot_add_ct %s", "leman");
		ServerCommand("mp_teamlogo_1 ago");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Furlan");
		ServerCommand("bot_add_t %s", "Grashog");
		ServerCommand("bot_add_t %s", "kRaSnaL");
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
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Snappi");
		ServerCommand("bot_add_ct %s", "hades");
		ServerCommand("bot_add_ct %s", "Spinx");
		ServerCommand("bot_add_ct %s", "maden");
		ServerCommand("bot_add_ct %s", "dycha");
		ServerCommand("mp_teamlogo_1 ence");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Snappi");
		ServerCommand("bot_add_t %s", "hades");
		ServerCommand("bot_add_t %s", "Spinx");
		ServerCommand("bot_add_t %s", "maden");
		ServerCommand("bot_add_t %s", "dycha");
		ServerCommand("mp_teamlogo_2 ence");
	}
	
	return Plugin_Handled;
}

public Action Team_Vitality(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "dupreeh");
		ServerCommand("bot_add_ct %s", "ZywOo");
		ServerCommand("bot_add_ct %s", "apEX");
		ServerCommand("bot_add_ct %s", "Magisk");
		ServerCommand("bot_add_ct %s", "Misutaaa");
		ServerCommand("mp_teamlogo_1 vita");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "dupreeh");
		ServerCommand("bot_add_t %s", "ZywOo");
		ServerCommand("bot_add_t %s", "apEX");
		ServerCommand("bot_add_t %s", "Magisk");
		ServerCommand("bot_add_t %s", "Misutaaa");
		ServerCommand("mp_teamlogo_2 vita");
	}
	
	return Plugin_Handled;
}

public Action Team_BIG(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "tiziaN");
		ServerCommand("bot_add_ct %s", "syrsoN");
		ServerCommand("bot_add_ct %s", "faveN");
		ServerCommand("bot_add_ct %s", "tabseN");
		ServerCommand("bot_add_ct %s", "Krimbo");
		ServerCommand("mp_teamlogo_1 big");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "tiziaN");
		ServerCommand("bot_add_t %s", "syrsoN");
		ServerCommand("bot_add_t %s", "faveN");
		ServerCommand("bot_add_t %s", "tabseN");
		ServerCommand("bot_add_t %s", "Krimbo");
		ServerCommand("mp_teamlogo_2 big");
	}
	
	return Plugin_Handled;
}

public Action Team_FURIA(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "yuurih");
		ServerCommand("bot_add_ct %s", "saffee");
		ServerCommand("bot_add_ct %s", "drop");
		ServerCommand("bot_add_ct %s", "KSCERATO");
		ServerCommand("bot_add_ct %s", "arT");
		ServerCommand("mp_teamlogo_1 furi");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "yuurih");
		ServerCommand("bot_add_t %s", "saffee");
		ServerCommand("bot_add_t %s", "drop");
		ServerCommand("bot_add_t %s", "KSCERATO");
		ServerCommand("bot_add_t %s", "arT");
		ServerCommand("mp_teamlogo_2 furi");
	}
	
	return Plugin_Handled;
}

public Action Team_Santos(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "jAPA");
		ServerCommand("bot_add_ct %s", "zdr");
		ServerCommand("bot_add_ct %s", "STRIKER");
		ServerCommand("bot_add_ct %s", "begod");
		ServerCommand("bot_add_ct %s", "DebornY");
		ServerCommand("mp_teamlogo_1 sant");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "jAPA");
		ServerCommand("bot_add_t %s", "zdr");
		ServerCommand("bot_add_t %s", "STRIKER");
		ServerCommand("bot_add_t %s", "begod");
		ServerCommand("bot_add_t %s", "DebornY");
		ServerCommand("mp_teamlogo_2 sant");
	}
	
	return Plugin_Handled;
}

public Action Team_coL(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "JT");
		ServerCommand("bot_add_ct %s", "junior");
		ServerCommand("bot_add_ct %s", "FaNg");
		ServerCommand("bot_add_ct %s", "floppy");
		ServerCommand("bot_add_ct %s", "Grim");
		ServerCommand("mp_teamlogo_1 col");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "JT");
		ServerCommand("bot_add_t %s", "junior");
		ServerCommand("bot_add_t %s", "FaNg");
		ServerCommand("bot_add_t %s", "floppy");
		ServerCommand("bot_add_t %s", "Grim");
		ServerCommand("mp_teamlogo_2 col");
	}
	
	return Plugin_Handled;
}

public Action Team_Atom(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "zhokiNg");
		ServerCommand("bot_add_ct %s", "kaze");
		ServerCommand("bot_add_ct %s", "aumaN");
		ServerCommand("bot_add_ct %s", "JamYoung");
		ServerCommand("bot_add_ct %s", "advent");
		ServerCommand("mp_teamlogo_1 atom");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "zhokiNg");
		ServerCommand("bot_add_t %s", "kaze");
		ServerCommand("bot_add_t %s", "aumaN");
		ServerCommand("bot_add_t %s", "JamYoung");
		ServerCommand("bot_add_t %s", "advent");
		ServerCommand("mp_teamlogo_2 atom");
	}
	
	return Plugin_Handled;
}

public Action Team_forZe(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "KENSI");
		ServerCommand("bot_add_ct %s", "zorte");
		ServerCommand("bot_add_ct %s", "Norwi");
		ServerCommand("bot_add_ct %s", "shalfey");
		ServerCommand("bot_add_ct %s", "Jerry");
		ServerCommand("mp_teamlogo_1 forz");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "KENSI");
		ServerCommand("bot_add_t %s", "zorte");
		ServerCommand("bot_add_t %s", "Norwi");
		ServerCommand("bot_add_t %s", "shalfey");
		ServerCommand("bot_add_t %s", "Jerry");
		ServerCommand("mp_teamlogo_2 forz");
	}
	
	return Plugin_Handled;
}

public Action Team_Sprout(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Staehr");
		ServerCommand("bot_add_ct %s", "slaxz");
		ServerCommand("bot_add_ct %s", "Spiidi");
		ServerCommand("bot_add_ct %s", "Marix");
		ServerCommand("bot_add_ct %s", "raalz");
		ServerCommand("mp_teamlogo_1 spr");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Staehr");
		ServerCommand("bot_add_t %s", "slaxz");
		ServerCommand("bot_add_t %s", "Spiidi");
		ServerCommand("bot_add_t %s", "Marix");
		ServerCommand("bot_add_t %s", "raalz");
		ServerCommand("mp_teamlogo_2 spr");
	}
	
	return Plugin_Handled;
}

public Action Team_Heroic(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "TeSeS");
		ServerCommand("bot_add_ct %s", "cadiaN");
		ServerCommand("bot_add_ct %s", "sjuush");
		ServerCommand("bot_add_ct %s", "refrezh");
		ServerCommand("bot_add_ct %s", "stavn");
		ServerCommand("mp_teamlogo_1 hero");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "TeSeS");
		ServerCommand("bot_add_t %s", "cadiaN");
		ServerCommand("bot_add_t %s", "sjuush");
		ServerCommand("bot_add_t %s", "refrezh");
		ServerCommand("bot_add_t %s", "stavn");
		ServerCommand("mp_teamlogo_2 hero");
	}
	
	return Plugin_Handled;
}

public Action Team_VP(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "YEKINDAR");
		ServerCommand("bot_add_ct %s", "Jame");
		ServerCommand("bot_add_ct %s", "qikert");
		ServerCommand("bot_add_ct %s", "FL1T");
		ServerCommand("bot_add_ct %s", "buster");
		ServerCommand("mp_teamlogo_1 vp");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "YEKINDAR");
		ServerCommand("bot_add_t %s", "Jame");
		ServerCommand("bot_add_t %s", "qikert");
		ServerCommand("bot_add_t %s", "FL1T");
		ServerCommand("bot_add_t %s", "buster");
		ServerCommand("mp_teamlogo_2 vp");
	}
	
	return Plugin_Handled;
}

public Action Team_Apeks(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "jkaem");
		ServerCommand("bot_add_ct %s", "nawwk");
		ServerCommand("bot_add_ct %s", "Chawzyyy");
		ServerCommand("bot_add_ct %s", "STYKO");
		ServerCommand("bot_add_ct %s", "AcilioN");
		ServerCommand("mp_teamlogo_1 ape");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "jkaem");
		ServerCommand("bot_add_t %s", "nawwk");
		ServerCommand("bot_add_t %s", "Chawzyyy");
		ServerCommand("bot_add_t %s", "STYKO");
		ServerCommand("bot_add_t %s", "AcilioN");
		ServerCommand("mp_teamlogo_2 ape");
	}
	
	return Plugin_Handled;
}

public Action Team_Renegades(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "INS");
		ServerCommand("bot_add_ct %s", "sico");
		ServerCommand("bot_add_ct %s", "aliStair");
		ServerCommand("bot_add_ct %s", "Hatz");
		ServerCommand("bot_add_ct %s", "Liazz");
		ServerCommand("mp_teamlogo_1 ren");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "INS");
		ServerCommand("bot_add_t %s", "sico");
		ServerCommand("bot_add_t %s", "aliStair");
		ServerCommand("bot_add_t %s", "Hatz");
		ServerCommand("bot_add_t %s", "Liazz");
		ServerCommand("mp_teamlogo_2 ren");
	}
	
	return Plugin_Handled;
}

public Action Team_GamerLegion(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "iM");
		ServerCommand("bot_add_ct %s", "eraa");
		ServerCommand("bot_add_ct %s", "Zero");
		ServerCommand("bot_add_ct %s", "RuStY");
		ServerCommand("bot_add_ct %s", "isak");
		ServerCommand("mp_teamlogo_1 glegion");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "iM");
		ServerCommand("bot_add_t %s", "eraa");
		ServerCommand("bot_add_t %s", "Zero");
		ServerCommand("bot_add_t %s", "RuStY");
		ServerCommand("bot_add_t %s", "isak");
		ServerCommand("mp_teamlogo_2 glegion");
	}
	
	return Plugin_Handled;
}

public Action Team_HAVU(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "ottoNd");
		ServerCommand("bot_add_ct %s", "sLowi");
		ServerCommand("bot_add_ct %s", "Aerial");
		ServerCommand("bot_add_ct %s", "xseveN");
		ServerCommand("bot_add_ct %s", "Sm1llee");
		ServerCommand("mp_teamlogo_1 havu");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "ottoNd");
		ServerCommand("bot_add_t %s", "sLowi");
		ServerCommand("bot_add_t %s", "Aerial");
		ServerCommand("bot_add_t %s", "xseveN");
		ServerCommand("bot_add_t %s", "Sm1llee");
		ServerCommand("mp_teamlogo_2 havu");
	}
	
	return Plugin_Handled;
}

public Action Team_ECSTATIC(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "birdfromsky");
		ServerCommand("bot_add_ct %s", "WolfY");
		ServerCommand("bot_add_ct %s", "maNkz");
		ServerCommand("bot_add_ct %s", "FASHR");
		ServerCommand("bot_add_ct %s", "Daffu");
		ServerCommand("mp_teamlogo_1 ecs");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "birdfromsky");
		ServerCommand("bot_add_t %s", "WolfY");
		ServerCommand("bot_add_t %s", "maNkz");
		ServerCommand("bot_add_t %s", "FASHR");
		ServerCommand("bot_add_t %s", "Daffu");
		ServerCommand("mp_teamlogo_2 ecs");
	}
	
	return Plugin_Handled;
}

public Action Team_GODSENT(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "TACO");
		ServerCommand("bot_add_ct %s", "HEN1");
		ServerCommand("bot_add_ct %s", "b4rtiN");
		ServerCommand("bot_add_ct %s", "latto");
		ServerCommand("bot_add_ct %s", "dumau");
		ServerCommand("mp_teamlogo_1 god");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "TACO");
		ServerCommand("bot_add_t %s", "HEN1");
		ServerCommand("bot_add_t %s", "b4rtiN");
		ServerCommand("bot_add_t %s", "latto");
		ServerCommand("bot_add_t %s", "dumau");
		ServerCommand("mp_teamlogo_2 god");
	}
	
	return Plugin_Handled;
}

public Action Team_Rhyno(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "HS");
		ServerCommand("bot_add_ct %s", "DeviNe");
		ServerCommand("bot_add_ct %s", "SeabraEZ");
		ServerCommand("bot_add_ct %s", "opdust");
		ServerCommand("bot_add_ct %s", "krazy");
		ServerCommand("mp_teamlogo_1 rhy");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "HS");
		ServerCommand("bot_add_t %s", "DeviNe");
		ServerCommand("bot_add_t %s", "SeabraEZ");
		ServerCommand("bot_add_t %s", "opdust");
		ServerCommand("bot_add_t %s", "krazy");
		ServerCommand("mp_teamlogo_2 rhy");
	}
	
	return Plugin_Handled;
}

public Action Team_Riders(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "mopoz");
		ServerCommand("bot_add_ct %s", "SunPayus");
		ServerCommand("bot_add_ct %s", "DeathZz");
		ServerCommand("bot_add_ct %s", "\"alex*\"");
		ServerCommand("bot_add_ct %s", "dav1g");
		ServerCommand("mp_teamlogo_1 ride");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "mopoz");
		ServerCommand("bot_add_t %s", "SunPayus");
		ServerCommand("bot_add_t %s", "DeathZz");
		ServerCommand("bot_add_t %s", "\"alex*\"");
		ServerCommand("bot_add_t %s", "dav1g");
		ServerCommand("mp_teamlogo_2 ride");
	}
	
	return Plugin_Handled;
}

public Action Team_eSuba(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Pechyn");
		ServerCommand("bot_add_ct %s", "desty");
		ServerCommand("bot_add_ct %s", "sAvana1");
		ServerCommand("bot_add_ct %s", "blogg1s");
		ServerCommand("bot_add_ct %s", "Levi");
		ServerCommand("mp_teamlogo_1 esu");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Pechyn");
		ServerCommand("bot_add_t %s", "desty");
		ServerCommand("bot_add_t %s", "sAvana1");
		ServerCommand("bot_add_t %s", "blogg1s");
		ServerCommand("bot_add_t %s", "Levi");
		ServerCommand("mp_teamlogo_2 esu");
	}
	
	return Plugin_Handled;
}

public Action Team_Nexus(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "BTN");
		ServerCommand("bot_add_ct %s", "XELLOW");
		ServerCommand("bot_add_ct %s", "ragga");
		ServerCommand("bot_add_ct %s", "lauNX");
		ServerCommand("bot_add_ct %s", "SEMINTE");
		ServerCommand("mp_teamlogo_1 nex");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "BTN");
		ServerCommand("bot_add_t %s", "XELLOW");
		ServerCommand("bot_add_t %s", "ragga");
		ServerCommand("bot_add_t %s", "lauNX");
		ServerCommand("bot_add_t %s", "SEMINTE");
		ServerCommand("mp_teamlogo_2 nex");
	}
	
	return Plugin_Handled;
}

public Action Team_PACT(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "SAYN");
		ServerCommand("bot_add_ct %s", "lunAtic");
		ServerCommand("bot_add_ct %s", "bnox");
		ServerCommand("bot_add_ct %s", "TOAO");
		ServerCommand("bot_add_ct %s", "reatz");
		ServerCommand("mp_teamlogo_1 pact");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "SAYN");
		ServerCommand("bot_add_t %s", "lunAtic");
		ServerCommand("bot_add_t %s", "bnox");
		ServerCommand("bot_add_t %s", "TOAO");
		ServerCommand("bot_add_t %s", "reatz");
		ServerCommand("mp_teamlogo_2 pact");
	}
	
	return Plugin_Handled;
}

public Action Team_Nemiga(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "iDISBALANCE");
		ServerCommand("bot_add_ct %s", "BELCHONOKK");
		ServerCommand("bot_add_ct %s", "Chill");
		ServerCommand("bot_add_ct %s", "Jyo");
		ServerCommand("bot_add_ct %s", "boX");
		ServerCommand("mp_teamlogo_1 nem");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "iDISBALANCE");
		ServerCommand("bot_add_t %s", "BELCHONOKK");
		ServerCommand("bot_add_t %s", "Chill");
		ServerCommand("bot_add_t %s", "Jyo");
		ServerCommand("bot_add_t %s", "boX");
		ServerCommand("mp_teamlogo_2 nem");
	}
	
	return Plugin_Handled;
}

public Action Team_GZG(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "guag");
		ServerCommand("bot_add_ct %s", "mizzy");
		ServerCommand("bot_add_ct %s", "2D");
		ServerCommand("bot_add_ct %s", "rekonz");
		ServerCommand("bot_add_ct %s", "nexar");
		ServerCommand("mp_teamlogo_1 gzg");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "guag");
		ServerCommand("bot_add_t %s", "mizzy");
		ServerCommand("bot_add_t %s", "2D");
		ServerCommand("bot_add_t %s", "rekonz");
		ServerCommand("bot_add_t %s", "nexar");
		ServerCommand("mp_teamlogo_2 gzg");
	}
	
	return Plugin_Handled;
}

public Action Team_Xian(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "QUQU");
		ServerCommand("bot_add_ct %s", "Savageoh");
		ServerCommand("bot_add_ct %s", "Franke19");
		ServerCommand("bot_add_ct %s", "18yM");
		ServerCommand("bot_add_ct %s", "tb");
		ServerCommand("mp_teamlogo_1 xi");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "QUQU");
		ServerCommand("bot_add_t %s", "Savageoh");
		ServerCommand("bot_add_t %s", "Franke19");
		ServerCommand("bot_add_t %s", "18yM");
		ServerCommand("bot_add_t %s", "tb");
		ServerCommand("mp_teamlogo_2 xi");
	}
	
	return Plugin_Handled;
}

public Action Team_Infinity(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "k1Nky");
		ServerCommand("bot_add_ct %s", "pacman^v^");
		ServerCommand("bot_add_ct %s", "spamzzy");
		ServerCommand("bot_add_ct %s", "tor1towOw");
		ServerCommand("bot_add_ct %s", "Marro");
		ServerCommand("mp_teamlogo_1 infi");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "k1Nky");
		ServerCommand("bot_add_t %s", "pacman^v^");
		ServerCommand("bot_add_t %s", "spamzzy");
		ServerCommand("bot_add_t %s", "tor1towOw");
		ServerCommand("bot_add_t %s", "Marro");
		ServerCommand("mp_teamlogo_2 infi");
	}
	
	return Plugin_Handled;
}

public Action Team_Isurus(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "DeStiNy");
		ServerCommand("bot_add_ct %s", "Noktse");
		ServerCommand("bot_add_ct %s", "Gafolo");
		ServerCommand("bot_add_ct %s", "decov9jse");
		ServerCommand("bot_add_ct %s", "ALLE");
		ServerCommand("mp_teamlogo_1 isu");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "DeStiNy");
		ServerCommand("bot_add_t %s", "Noktse");
		ServerCommand("bot_add_t %s", "Gafolo");
		ServerCommand("bot_add_t %s", "decov9jse");
		ServerCommand("bot_add_t %s", "ALLE");
		ServerCommand("mp_teamlogo_2 isu");
	}
	
	return Plugin_Handled;
}

public Action Team_paiN(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "PKL");
		ServerCommand("bot_add_ct %s", "nython");
		ServerCommand("bot_add_ct %s", "NEKIZ");
		ServerCommand("bot_add_ct %s", "biguzera");
		ServerCommand("bot_add_ct %s", "hardzao");
		ServerCommand("mp_teamlogo_1 pain");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "PKL");
		ServerCommand("bot_add_t %s", "nython");
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
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "chay");
		ServerCommand("bot_add_ct %s", "jnt");
		ServerCommand("bot_add_ct %s", "Lucaozy");
		ServerCommand("bot_add_ct %s", "matios");
		ServerCommand("bot_add_ct %s", "zevy");
		ServerCommand("mp_teamlogo_1 shrk");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "chay");
		ServerCommand("bot_add_t %s", "jnt");
		ServerCommand("bot_add_t %s", "Lucaozy");
		ServerCommand("bot_add_t %s", "matios");
		ServerCommand("bot_add_t %s", "zevy");
		ServerCommand("mp_teamlogo_2 shrk");
	}
	
	return Plugin_Handled;
}

public Action Team_One(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "keiz");
		ServerCommand("bot_add_ct %s", "Maluk3");
		ServerCommand("bot_add_ct %s", "trk");
		ServerCommand("bot_add_ct %s", "xns");
		ServerCommand("bot_add_ct %s", "pesadelo");
		ServerCommand("mp_teamlogo_1 tone");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "keiz");
		ServerCommand("bot_add_t %s", "Maluk3");
		ServerCommand("bot_add_t %s", "trk");
		ServerCommand("bot_add_t %s", "xns");
		ServerCommand("bot_add_t %s", "pesadelo");
		ServerCommand("mp_teamlogo_2 tone");
	}
	
	return Plugin_Handled;
}

public Action Team_ORDER(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "J1rah");
		ServerCommand("bot_add_ct %s", "Vexite");
		ServerCommand("bot_add_ct %s", "tucks");
		ServerCommand("bot_add_ct %s", "USTILO");
		ServerCommand("bot_add_ct %s", "Valiance");
		ServerCommand("mp_teamlogo_1 order");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "J1rah");
		ServerCommand("bot_add_t %s", "Vexite");
		ServerCommand("bot_add_t %s", "tucks");
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
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "dream3r");
		ServerCommand("bot_add_ct %s", "dennyslaw");
		ServerCommand("bot_add_ct %s", "bubble");
		ServerCommand("bot_add_ct %s", "Rainwaker");
		ServerCommand("bot_add_ct %s", "SHiPZ");
		ServerCommand("mp_teamlogo_1 ska");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "dream3r");
		ServerCommand("bot_add_t %s", "dennyslaw");
		ServerCommand("bot_add_t %s", "bubble");
		ServerCommand("bot_add_t %s", "Rainwaker");
		ServerCommand("bot_add_t %s", "SHiPZ");
		ServerCommand("mp_teamlogo_2 ska");
	}
	
	return Plugin_Handled;
}

public Action Team_Izako(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "asran");
		ServerCommand("bot_add_ct %s", "Crityourface");
		ServerCommand("bot_add_ct %s", "Mride");
		ServerCommand("bot_add_ct %s", "rico");
		ServerCommand("bot_add_ct %s", "sh3nanigan");
		ServerCommand("mp_teamlogo_1 izak");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "asran");
		ServerCommand("bot_add_t %s", "Crityourface");
		ServerCommand("bot_add_t %s", "Mride");
		ServerCommand("bot_add_t %s", "rico");
		ServerCommand("bot_add_t %s", "sh3nanigan");
		ServerCommand("mp_teamlogo_2 izak");
	}
	
	return Plugin_Handled;
}

public Action Team_OFFSET(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "slaxx");
		ServerCommand("bot_add_ct %s", "Lr0z1n");
		ServerCommand("bot_add_ct %s", "snapy");
		ServerCommand("bot_add_ct %s", "shr");
		ServerCommand("bot_add_ct %s", "shellzi");
		ServerCommand("mp_teamlogo_1 offs");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "slaxx");
		ServerCommand("bot_add_t %s", "Lr0z1n");
		ServerCommand("bot_add_t %s", "snapy");
		ServerCommand("bot_add_t %s", "shr");
		ServerCommand("bot_add_t %s", "shellzi");
		ServerCommand("mp_teamlogo_2 offs");
	}
	
	return Plugin_Handled;
}

public Action Team_NASR(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Remind");
		ServerCommand("bot_add_ct %s", "REAL1ZE");
		ServerCommand("bot_add_ct %s", "keen");
		ServerCommand("bot_add_ct %s", "EiZAA");
		ServerCommand("bot_add_ct %s", "bibu");
		ServerCommand("mp_teamlogo_1 nasr");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Remind");
		ServerCommand("bot_add_t %s", "REAL1ZE");
		ServerCommand("bot_add_t %s", "keen");
		ServerCommand("bot_add_t %s", "EiZAA");
		ServerCommand("bot_add_t %s", "bibu");
		ServerCommand("mp_teamlogo_2 nasr");
	}
	
	return Plugin_Handled;
}

public Action Team_ECB(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "ritchiEE");
		ServerCommand("bot_add_ct %s", "Stev0se");
		ServerCommand("bot_add_ct %s", "Gringo");
		ServerCommand("bot_add_ct %s", "Matty");
		ServerCommand("bot_add_ct %s", "n0tice");
		ServerCommand("mp_teamlogo_1 ecb");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "ritchiEE");
		ServerCommand("bot_add_t %s", "Stev0se");
		ServerCommand("bot_add_t %s", "Gringo");
		ServerCommand("bot_add_t %s", "Matty");
		ServerCommand("bot_add_t %s", "n0tice");
		ServerCommand("mp_teamlogo_2 ecb");
	}
	
	return Plugin_Handled;
}

public Action Team_Bravado(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "TheM4N");
		ServerCommand("bot_add_ct %s", "SloWye");
		ServerCommand("bot_add_ct %s", "Wip3ouT");
		ServerCommand("bot_add_ct %s", "flexeeee");
		ServerCommand("bot_add_ct %s", ".exe");
		ServerCommand("mp_teamlogo_1 bravg");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "TheM4N");
		ServerCommand("bot_add_t %s", "SloWye");
		ServerCommand("bot_add_t %s", "Wip3ouT");
		ServerCommand("bot_add_t %s", "flexeeee");
		ServerCommand("bot_add_t %s", ".exe");
		ServerCommand("mp_teamlogo_2 bravg");
	}
	
	return Plugin_Handled;
}

public Action Team_SH(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "captainMo");
		ServerCommand("bot_add_ct %s", "AE");
		ServerCommand("bot_add_ct %s", "LOVEYY");
		ServerCommand("bot_add_ct %s", "XiaosaGe");
		ServerCommand("bot_add_ct %s", "Ayeon");
		ServerCommand("mp_teamlogo_1 sh");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "captainMo");
		ServerCommand("bot_add_t %s", "AE");
		ServerCommand("bot_add_t %s", "LOVEYY");
		ServerCommand("bot_add_t %s", "XiaosaGe");
		ServerCommand("bot_add_t %s", "Ayeon");
		ServerCommand("mp_teamlogo_2 sh");
	}
	
	return Plugin_Handled;
}

public Action Team_GTZ(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Linko");
		ServerCommand("bot_add_ct %s", "rafaxF");
		ServerCommand("bot_add_ct %s", "StepA");
		ServerCommand("bot_add_ct %s", "Jaepe");
		ServerCommand("bot_add_ct %s", "fakes2");
		ServerCommand("mp_teamlogo_1 gtz");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Linko");
		ServerCommand("bot_add_t %s", "rafaxF");
		ServerCommand("bot_add_t %s", "StepA");
		ServerCommand("bot_add_t %s", "Jaepe");
		ServerCommand("bot_add_t %s", "fakes2");
		ServerCommand("mp_teamlogo_2 gtz");
	}
	
	return Plugin_Handled;
}

public Action Team_Eternal(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "XANTARES");
		ServerCommand("bot_add_ct %s", "woxic");
		ServerCommand("bot_add_ct %s", "xfl0ud");
		ServerCommand("bot_add_ct %s", "imoRR");
		ServerCommand("bot_add_ct %s", "Calyx");
		ServerCommand("mp_teamlogo_1 eter");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "XANTARES");
		ServerCommand("bot_add_t %s", "woxic");
		ServerCommand("bot_add_t %s", "xfl0ud");
		ServerCommand("bot_add_t %s", "imoRR");
		ServerCommand("bot_add_t %s", "Calyx");
		ServerCommand("mp_teamlogo_2 eter");
	}
	
	return Plugin_Handled;
}

public Action Team_K23(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "neaLaN");
		ServerCommand("bot_add_ct %s", "xsepower");
		ServerCommand("bot_add_ct %s", "n0rb3r7");
		ServerCommand("bot_add_ct %s", "fame");
		ServerCommand("bot_add_ct %s", "X5G7V");
		ServerCommand("mp_teamlogo_1 k23");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "neaLaN");
		ServerCommand("bot_add_t %s", "xsepower");
		ServerCommand("bot_add_t %s", "n0rb3r7");
		ServerCommand("bot_add_t %s", "fame");
		ServerCommand("bot_add_t %s", "X5G7V");
		ServerCommand("mp_teamlogo_2 k23");
	}
	
	return Plugin_Handled;
}

public Action Team_Goliath(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "massacRe");
		ServerCommand("bot_add_ct %s", "Dweezil");
		ServerCommand("bot_add_ct %s", "Triton");
		ServerCommand("bot_add_ct %s", "ELUSIVE");
		ServerCommand("bot_add_ct %s", "zox");
		ServerCommand("mp_teamlogo_1 gol");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "massacRe");
		ServerCommand("bot_add_t %s", "Dweezil");
		ServerCommand("bot_add_t %s", "Triton");
		ServerCommand("bot_add_t %s", "ELUSIVE");
		ServerCommand("bot_add_t %s", "zox");
		ServerCommand("mp_teamlogo_2 gol");
	}
	
	return Plugin_Handled;
}

public Action Team_VERTEX(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "pz");
		ServerCommand("bot_add_ct %s", "BRACE");
		ServerCommand("bot_add_ct %s", "apocdud");
		ServerCommand("bot_add_ct %s", "malta");
		ServerCommand("bot_add_ct %s", "Roflko");
		ServerCommand("mp_teamlogo_1 vert");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "pz");
		ServerCommand("bot_add_t %s", "BRACE");
		ServerCommand("bot_add_t %s", "apocdud");
		ServerCommand("bot_add_t %s", "malta");
		ServerCommand("bot_add_t %s", "Roflko");
		ServerCommand("mp_teamlogo_2 vert");
	}
	
	return Plugin_Handled;
}

public Action Team_IG(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "bottle");
		ServerCommand("bot_add_ct %s", "DeStRoYeR");
		ServerCommand("bot_add_ct %s", "flying");
		ServerCommand("bot_add_ct %s", "Viva");
		ServerCommand("bot_add_ct %s", "rage");
		ServerCommand("mp_teamlogo_1 ig");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "bottle");
		ServerCommand("bot_add_t %s", "DeStRoYeR");
		ServerCommand("bot_add_t %s", "flying");
		ServerCommand("bot_add_t %s", "Viva");
		ServerCommand("bot_add_t %s", "rage");
		ServerCommand("mp_teamlogo_2 ig");
	}
	
	return Plugin_Handled;
}

public Action Team_Finest(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "twist");
		ServerCommand("bot_add_ct %s", "anarkez");
		ServerCommand("bot_add_ct %s", "kreaz");
		ServerCommand("bot_add_ct %s", "PlesseN");
		ServerCommand("bot_add_ct %s", "shokz");
		ServerCommand("mp_teamlogo_1 fine");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "twist");
		ServerCommand("bot_add_t %s", "anarkez");
		ServerCommand("bot_add_t %s", "kreaz");
		ServerCommand("bot_add_t %s", "PlesseN");
		ServerCommand("bot_add_t %s", "shokz");
		ServerCommand("mp_teamlogo_2 fine");
	}
	
	return Plugin_Handled;
}

public Action Team_C9(int client, int iArgs)
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
		ServerCommand("mp_teamlogo_1 c9");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "nafany");
		ServerCommand("bot_add_t %s", "sh1ro");
		ServerCommand("bot_add_t %s", "interz");
		ServerCommand("bot_add_t %s", "Ax1Le");
		ServerCommand("bot_add_t %s", "Hobbit");
		ServerCommand("mp_teamlogo_2 c9");
	}
	
	return Plugin_Handled;
}

public Action Team_Wisla(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Sobol");
		ServerCommand("bot_add_ct %s", "SZPERO");
		ServerCommand("bot_add_ct %s", "Goofy");
		ServerCommand("bot_add_ct %s", "snatchie");
		ServerCommand("bot_add_ct %s", "jedqr");
		ServerCommand("mp_teamlogo_1 wisla");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Sobol");
		ServerCommand("bot_add_t %s", "SZPERO");
		ServerCommand("bot_add_t %s", "Goofy");
		ServerCommand("bot_add_t %s", "snatchie");
		ServerCommand("bot_add_t %s", "jedqr");
		ServerCommand("mp_teamlogo_2 wisla");
	}
	
	return Plugin_Handled;
}

public Action Team_aTTaX(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "awzek");
		ServerCommand("bot_add_ct %s", "mave");
		ServerCommand("bot_add_ct %s", "xenn");
		ServerCommand("bot_add_ct %s", "FreeZe");
		ServerCommand("bot_add_ct %s", "skyye");
		ServerCommand("mp_teamlogo_1 attax");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "awzek");
		ServerCommand("bot_add_t %s", "mave");
		ServerCommand("bot_add_t %s", "xenn");
		ServerCommand("bot_add_t %s", "FreeZe");
		ServerCommand("bot_add_t %s", "skyye");
		ServerCommand("mp_teamlogo_2 attax");
	}
	
	return Plugin_Handled;
}

public Action Team_Unique(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "sorrow");
		ServerCommand("bot_add_ct %s", "smiley");
		ServerCommand("bot_add_ct %s", "w1nt3r");
		ServerCommand("bot_add_ct %s", "icem4N");
		ServerCommand("bot_add_ct %s", "dukefissura");
		ServerCommand("mp_teamlogo_1 uniq");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "sorrow");
		ServerCommand("bot_add_t %s", "smiley");
		ServerCommand("bot_add_t %s", "w1nt3r");
		ServerCommand("bot_add_t %s", "icem4N");
		ServerCommand("bot_add_t %s", "dukefissura");
		ServerCommand("mp_teamlogo_2 uniq");
	}
	
	return Plugin_Handled;
}

public Action Team_ATK(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "b0denmaster");
		ServerCommand("bot_add_ct %s", "MisteM");
		ServerCommand("bot_add_ct %s", "motm");
		ServerCommand("bot_add_ct %s", "Fadey");
		ServerCommand("bot_add_ct %s", "Swisher");
		ServerCommand("mp_teamlogo_1 atk");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "b0denmaster");
		ServerCommand("bot_add_t %s", "MisteM");
		ServerCommand("bot_add_t %s", "motm");
		ServerCommand("bot_add_t %s", "Fadey");
		ServerCommand("bot_add_t %s", "Swisher");
		ServerCommand("mp_teamlogo_2 atk");
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
		ServerCommand("bot_add_ct %s", "ahang");
		ServerCommand("bot_add_ct %s", "gas");
		ServerCommand("mp_teamlogo_1 wings");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "ChildKing");
		ServerCommand("bot_add_t %s", "lan");
		ServerCommand("bot_add_t %s", "MarT1n");
		ServerCommand("bot_add_t %s", "ahang");
		ServerCommand("bot_add_t %s", "gas");
		ServerCommand("mp_teamlogo_2 wings");
	}
	
	return Plugin_Handled;
}

public Action Team_Lynn(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "westmelon");
		ServerCommand("bot_add_ct %s", "z4kr");
		ServerCommand("bot_add_ct %s", "Starry");
		ServerCommand("bot_add_ct %s", "EXPRO");
		ServerCommand("bot_add_ct %s", "V4D1M");
		ServerCommand("mp_teamlogo_1 lynn");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "westmelon");
		ServerCommand("bot_add_t %s", "z4kr");
		ServerCommand("bot_add_t %s", "Starry");
		ServerCommand("bot_add_t %s", "EXPRO");
		ServerCommand("bot_add_t %s", "V4D1M");
		ServerCommand("mp_teamlogo_2 lynn");
	}
	
	return Plugin_Handled;
}

public Action Team_Impact(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "RZU");
		ServerCommand("bot_add_ct %s", "grape");
		ServerCommand("bot_add_ct %s", "Danejoris");
		ServerCommand("bot_add_ct %s", "mesamiduck");
		ServerCommand("bot_add_ct %s", "D4rtyMontana");
		ServerCommand("mp_teamlogo_1 imp");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "RZU");
		ServerCommand("bot_add_t %s", "grape");
		ServerCommand("bot_add_t %s", "Danejoris");
		ServerCommand("bot_add_t %s", "mesamiduck");
		ServerCommand("bot_add_t %s", "D4rtyMontana");
		ServerCommand("mp_teamlogo_2 imp");
	}
	
	return Plugin_Handled;
}

public Action Team_OG(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "nikozan");
		ServerCommand("bot_add_ct %s", "mantuu");
		ServerCommand("bot_add_ct %s", "nexa");
		ServerCommand("bot_add_ct %s", "valde");
		ServerCommand("bot_add_ct %s", "flameZ");
		ServerCommand("mp_teamlogo_1 og");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "nikozan");
		ServerCommand("bot_add_t %s", "mantuu");
		ServerCommand("bot_add_t %s", "nexa");
		ServerCommand("bot_add_t %s", "valde");
		ServerCommand("bot_add_t %s", "flameZ");
		ServerCommand("mp_teamlogo_2 og");
	}
	
	return Plugin_Handled;
}

public Action Team_BNE(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "juanflatroo");
		ServerCommand("bot_add_ct %s", "SENER1");
		ServerCommand("bot_add_ct %s", "sinnopsyy");
		ServerCommand("bot_add_ct %s", "gxx-");
		ServerCommand("bot_add_ct %s", "rigoN");
		ServerCommand("mp_teamlogo_1 bne");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "juanflatroo");
		ServerCommand("bot_add_t %s", "SENER1");
		ServerCommand("bot_add_t %s", "sinnopsyy");
		ServerCommand("bot_add_t %s", "gxx-");
		ServerCommand("bot_add_t %s", "rigoN");
		ServerCommand("mp_teamlogo_2 bne");
	}
	
	return Plugin_Handled;
}

public Action Team_Tricked(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "kiR");
		ServerCommand("bot_add_ct %s", "kwezz");
		ServerCommand("bot_add_ct %s", "larsen");
		ServerCommand("bot_add_ct %s", "IceBerg");
		ServerCommand("bot_add_ct %s", "PR1mE");
		ServerCommand("mp_teamlogo_1 trick");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "kiR");
		ServerCommand("bot_add_t %s", "kwezz");
		ServerCommand("bot_add_t %s", "larsen");
		ServerCommand("bot_add_t %s", "IceBerg");
		ServerCommand("bot_add_t %s", "PR1mE");
		ServerCommand("mp_teamlogo_2 trick");
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
		ServerCommand("bot_add_ct %s", "BOROS");
		ServerCommand("bot_add_ct %s", "Nertz");
		ServerCommand("mp_teamlogo_1 endp");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Surreal");
		ServerCommand("bot_add_t %s", "CRUC1AL");
		ServerCommand("bot_add_t %s", "MiGHTYMAX");
		ServerCommand("bot_add_t %s", "BOROS");
		ServerCommand("bot_add_t %s", "Nertz");
		ServerCommand("mp_teamlogo_2 endp");
	}
	
	return Plugin_Handled;
}

public Action Team_sAw(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "arki");
		ServerCommand("bot_add_ct %s", "stadodo");
		ServerCommand("bot_add_ct %s", "JUST");
		ServerCommand("bot_add_ct %s", "MUTiRiS");
		ServerCommand("bot_add_ct %s", "rmn");
		ServerCommand("mp_teamlogo_1 saw");
	}
	
	if (strcmp(arg, "t") == 0)
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
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Lekr0");
		ServerCommand("bot_add_ct %s", "hallzerk");
		ServerCommand("bot_add_ct %s", "f0rest");
		ServerCommand("bot_add_ct %s", "friberg");
		ServerCommand("bot_add_ct %s", "HEAP");
		ServerCommand("mp_teamlogo_1 dign");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Lekr0");
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
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "tamir");
		ServerCommand("bot_add_ct %s", "rate");
		ServerCommand("bot_add_ct %s", "shinobi");
		ServerCommand("bot_add_ct %s", "yAmi");
		ServerCommand("bot_add_ct %s", "Annihilation");
		ServerCommand("mp_teamlogo_1 d13");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "tamir");
		ServerCommand("bot_add_t %s", "rate");
		ServerCommand("bot_add_t %s", "shinobi");
		ServerCommand("bot_add_t %s", "yAmi");
		ServerCommand("bot_add_t %s", "Annihilation");
		ServerCommand("mp_teamlogo_2 d13");
	}
	
	return Plugin_Handled;
}

public Action Team_DIVIZON(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "farmaG");
		ServerCommand("bot_add_ct %s", "Sw1ft");
		ServerCommand("bot_add_ct %s", "Cl34v3rs");
		ServerCommand("bot_add_ct %s", "nANO^G");
		ServerCommand("bot_add_ct %s", "Spexy");
		ServerCommand("mp_teamlogo_1 divi");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "farmaG");
		ServerCommand("bot_add_t %s", "Sw1ft");
		ServerCommand("bot_add_t %s", "Cl34v3rs");
		ServerCommand("bot_add_t %s", "nANO^G");
		ServerCommand("bot_add_t %s", "Spexy");
		ServerCommand("mp_teamlogo_2 divi");
	}
	
	return Plugin_Handled;
}

public Action Team_KOVA(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "zks");
		ServerCommand("bot_add_ct %s", "spargo");
		ServerCommand("bot_add_ct %s", "uli");
		ServerCommand("bot_add_ct %s", "airax");
		ServerCommand("bot_add_ct %s", "Twixie");
		ServerCommand("mp_teamlogo_1 kova");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "zks");
		ServerCommand("bot_add_t %s", "spargo");
		ServerCommand("bot_add_t %s", "uli");
		ServerCommand("bot_add_t %s", "airax");
		ServerCommand("bot_add_t %s", "Twixie");
		ServerCommand("mp_teamlogo_2 kova");
	}
	
	return Plugin_Handled;
}

public Action Team_AGF(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "FeZ");
		ServerCommand("bot_add_ct %s", "Speedy");
		ServerCommand("bot_add_ct %s", "Griller");
		ServerCommand("bot_add_ct %s", "void");
		ServerCommand("bot_add_ct %s", "Equip");
		ServerCommand("mp_teamlogo_1 agf");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "FeZ");
		ServerCommand("bot_add_t %s", "Speedy");
		ServerCommand("bot_add_t %s", "Griller");
		ServerCommand("bot_add_t %s", "void");
		ServerCommand("bot_add_t %s", "Equip");
		ServerCommand("mp_teamlogo_2 agf");
	}
	
	return Plugin_Handled;
}

public Action Team_NLG(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "pdy");
		ServerCommand("bot_add_ct %s", "red");
		ServerCommand("bot_add_ct %s", "PerX");
		ServerCommand("bot_add_ct %s", "maRky");
		ServerCommand("bot_add_ct %s", "OKOLICIOUZ");
		ServerCommand("mp_teamlogo_1 nlg");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "pdy");
		ServerCommand("bot_add_t %s", "red");
		ServerCommand("bot_add_t %s", "PerX");
		ServerCommand("bot_add_t %s", "maRky");
		ServerCommand("bot_add_t %s", "OKOLICIOUZ");
		ServerCommand("mp_teamlogo_2 nlg");
	}
	
	return Plugin_Handled;
}

public Action Team_Lilmix(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "quix");
		ServerCommand("bot_add_ct %s", "bobeksde");
		ServerCommand("bot_add_ct %s", "FRANSSON");
		ServerCommand("bot_add_ct %s", "hns");
		ServerCommand("bot_add_ct %s", "Hype");
		ServerCommand("mp_teamlogo_1 lil");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "quix");
		ServerCommand("bot_add_t %s", "bobeksde");
		ServerCommand("bot_add_t %s", "FRANSSON");
		ServerCommand("bot_add_t %s", "hns");
		ServerCommand("bot_add_t %s", "Hype");
		ServerCommand("mp_teamlogo_2 lil");
	}
	
	return Plugin_Handled;
}

public Action Team_FTW(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Ag1l");
		ServerCommand("bot_add_ct %s", "ewjerkz");
		ServerCommand("bot_add_ct %s", "DDias");
		ServerCommand("bot_add_ct %s", "story");
		ServerCommand("bot_add_ct %s", "arrozdoce");
		ServerCommand("mp_teamlogo_1 ftw");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Ag1l");
		ServerCommand("bot_add_t %s", "ewjerkz");
		ServerCommand("bot_add_t %s", "DDias");
		ServerCommand("bot_add_t %s", "story");
		ServerCommand("bot_add_t %s", "arrozdoce");
		ServerCommand("mp_teamlogo_2 ftw");
	}
	
	return Plugin_Handled;
}

public Action Team_Tigers(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Aralio");
		ServerCommand("bot_add_ct %s", "Feki");
		ServerCommand("bot_add_ct %s", "outex");
		ServerCommand("bot_add_ct %s", "heikkoL");
		ServerCommand("bot_add_ct %s", "creZe");
		ServerCommand("mp_teamlogo_1 tigers");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Aralio");
		ServerCommand("bot_add_t %s", "Feki");
		ServerCommand("bot_add_t %s", "outex");
		ServerCommand("bot_add_t %s", "heikkoL");
		ServerCommand("bot_add_t %s", "creZe");
		ServerCommand("mp_teamlogo_2 tigers");
	}
	
	return Plugin_Handled;
}

public Action Team_9z(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "dgt");
		ServerCommand("bot_add_ct %s", "dav1d");
		ServerCommand("bot_add_ct %s", "maxujas");
		ServerCommand("bot_add_ct %s", "Luken");
		ServerCommand("bot_add_ct %s", "rox");
		ServerCommand("mp_teamlogo_1 9z");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "dgt");
		ServerCommand("bot_add_t %s", "dav1d");
		ServerCommand("bot_add_t %s", "maxujas");
		ServerCommand("bot_add_t %s", "Luken");
		ServerCommand("bot_add_t %s", "rox");
		ServerCommand("mp_teamlogo_2 9z");
	}
	
	return Plugin_Handled;
}

public Action Team_SINNERS(int client, int iArgs)
{
	char arg[12];
	GetCmdArg(1, arg, sizeof(arg));
	
	if (strcmp(arg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "ZEDKO");
		ServerCommand("bot_add_ct %s", "forsyy");
		ServerCommand("bot_add_ct %s", "SHOCK");
		ServerCommand("bot_add_ct %s", "beastik");
		ServerCommand("bot_add_ct %s", "NEOFRAG");
		ServerCommand("mp_teamlogo_1 sinn");
	}
	
	if (strcmp(arg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "ZEDKO");
		ServerCommand("bot_add_t %s", "forsyy");
		ServerCommand("bot_add_t %s", "SHOCK");
		ServerCommand("bot_add_t %s", "beastik");
		ServerCommand("bot_add_t %s", "NEOFRAG");
		ServerCommand("mp_teamlogo_2 sinn");
	}
	
	return Plugin_Handled;
}

public Action Team_Paradox(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "DannyG");
		ServerCommand("bot_add_ct %s", "nettik");
		ServerCommand("bot_add_ct %s", "chelleos");
		ServerCommand("bot_add_ct %s", "asap");
		ServerCommand("bot_add_ct %s", "dangeR");
		ServerCommand("mp_teamlogo_1 para");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "DannyG");
		ServerCommand("bot_add_t %s", "nettik");
		ServerCommand("bot_add_t %s", "chelleos");
		ServerCommand("bot_add_t %s", "asap");
		ServerCommand("bot_add_t %s", "dangeR");
		ServerCommand("mp_teamlogo_2 para");
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
		ServerCommand("bot_add_ct %s", "roeJ");
		ServerCommand("bot_add_ct %s", "nicoodoz");
		ServerCommand("bot_add_ct %s", "HooXi");
		ServerCommand("bot_add_ct %s", "Jabbi");
		ServerCommand("bot_add_ct %s", "Zyphon");
		ServerCommand("mp_teamlogo_1 cope");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "roeJ");
		ServerCommand("bot_add_t %s", "nicoodoz");
		ServerCommand("bot_add_t %s", "HooXi");
		ServerCommand("bot_add_t %s", "Jabbi");
		ServerCommand("bot_add_t %s", "Zyphon");
		ServerCommand("mp_teamlogo_2 cope");
	}
	
	return Plugin_Handled;
}

public Action Team_EP(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "\"The eLiVe\"");
		ServerCommand("bot_add_ct %s", "Blytz");
		ServerCommand("bot_add_ct %s", "manguss");
		ServerCommand("bot_add_ct %s", "myltsi");
		ServerCommand("bot_add_ct %s", "matys");
		ServerCommand("mp_teamlogo_1 ente");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "\"The eLiVe\"");
		ServerCommand("bot_add_t %s", "Blytz");
		ServerCommand("bot_add_t %s", "manguss");
		ServerCommand("bot_add_t %s", "myltsi");
		ServerCommand("bot_add_t %s", "matys");
		ServerCommand("mp_teamlogo_2 ente");
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
		ServerCommand("bot_add_ct %s", "adamb");
		ServerCommand("bot_add_ct %s", "hemzk9");
		ServerCommand("bot_add_ct %s", "susp");
		ServerCommand("bot_add_ct %s", "KriLLe");
		ServerCommand("mp_teamlogo_1 lemon");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "xelos");
		ServerCommand("bot_add_t %s", "adamb");
		ServerCommand("bot_add_t %s", "hemzk9");
		ServerCommand("bot_add_t %s", "susp");
		ServerCommand("bot_add_t %s", "KriLLe");
		ServerCommand("mp_teamlogo_2 lemon");
	}
	
	return Plugin_Handled;
}

public Action Team_Alpha(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "zypztw");
		ServerCommand("bot_add_ct %s", "Toft");
		ServerCommand("bot_add_ct %s", "vester");
		ServerCommand("bot_add_ct %s", "Tauson");
		ServerCommand("bot_add_ct %s", "mupzG");
		ServerCommand("mp_teamlogo_1 alpha");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "zypztw");
		ServerCommand("bot_add_t %s", "Toft");
		ServerCommand("bot_add_t %s", "vester");
		ServerCommand("bot_add_t %s", "Tauson");
		ServerCommand("bot_add_t %s", "mupzG");
		ServerCommand("mp_teamlogo_2 alpha");
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
		ServerCommand("bot_add_ct %s", "ScrunK");
		ServerCommand("bot_add_ct %s", "kyuubii");
		ServerCommand("bot_add_ct %s", "kory");
		ServerCommand("bot_add_ct %s", "Soulfly");
		ServerCommand("bot_add_ct %s", "S3NSEY");
		ServerCommand("mp_teamlogo_1 sang");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "ScrunK");
		ServerCommand("bot_add_t %s", "kyuubii");
		ServerCommand("bot_add_t %s", "kory");
		ServerCommand("bot_add_t %s", "Soulfly");
		ServerCommand("bot_add_t %s", "S3NSEY");
		ServerCommand("mp_teamlogo_2 sang");
	}
	
	return Plugin_Handled;
}

public Action Team_Ambush(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "wasiNk");
		ServerCommand("bot_add_ct %s", "DrqkoN");
		ServerCommand("bot_add_ct %s", "SBT");
		ServerCommand("bot_add_ct %s", "s0ne");
		ServerCommand("bot_add_ct %s", "devoduvek");
		ServerCommand("mp_teamlogo_1 amb");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "wasiNk");
		ServerCommand("bot_add_t %s", "DrqkoN");
		ServerCommand("bot_add_t %s", "SBT");
		ServerCommand("bot_add_t %s", "s0ne");
		ServerCommand("bot_add_t %s", "devoduvek");
		ServerCommand("mp_teamlogo_2 amb");
	}
	
	return Plugin_Handled;
}

public Action Team_Supremacy(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", ".Rome");
		ServerCommand("bot_add_ct %s", "GuepaRd");
		ServerCommand("bot_add_ct %s", "NiK0");
		ServerCommand("bot_add_ct %s", "Surviv0r");
		ServerCommand("bot_add_ct %s", "ALONZO");
		ServerCommand("mp_teamlogo_1 sup");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", ".Rome");
		ServerCommand("bot_add_t %s", "GuepaRd");
		ServerCommand("bot_add_t %s", "NiK0");
		ServerCommand("bot_add_t %s", "Surviv0r");
		ServerCommand("bot_add_t %s", "ALONZO");
		ServerCommand("mp_teamlogo_2 sup");
	}
	
	return Plugin_Handled;
}

public Action Team_CatEvil(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Cate");
		ServerCommand("bot_add_ct %s", "splashske");
		ServerCommand("bot_add_ct %s", "Drea3er");
		ServerCommand("bot_add_ct %s", "Gin");
		ServerCommand("bot_add_ct %s", "nephh");
		ServerCommand("mp_teamlogo_1 cat");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Cate");
		ServerCommand("bot_add_t %s", "splashske");
		ServerCommand("bot_add_t %s", "Drea3er");
		ServerCommand("bot_add_t %s", "Gin");
		ServerCommand("bot_add_t %s", "nephh");
		ServerCommand("mp_teamlogo_2 cat");
	}
	
	return Plugin_Handled;
}

public Action Team_AVEZ(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "mystic");
		ServerCommand("bot_add_ct %s", "bastEe");
		ServerCommand("bot_add_ct %s", "eYs");
		ServerCommand("bot_add_ct %s", "arioszek");
		ServerCommand("bot_add_ct %s", "hous1k");
		ServerCommand("mp_teamlogo_1 avez");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "mystic");
		ServerCommand("bot_add_t %s", "bastEe");
		ServerCommand("bot_add_t %s", "eYs");
		ServerCommand("bot_add_t %s", "arioszek");
		ServerCommand("bot_add_t %s", "hous1k");
		ServerCommand("mp_teamlogo_2 avez");
	}
	
	return Plugin_Handled;
}

public Action Team_Anonymo(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "oskarish");
		ServerCommand("bot_add_ct %s", "tudsoN");
		ServerCommand("bot_add_ct %s", "Demho");
		ServerCommand("bot_add_ct %s", "Vegi");
		ServerCommand("bot_add_ct %s", "innocent");
		ServerCommand("mp_teamlogo_1 anon");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "oskarish");
		ServerCommand("bot_add_t %s", "tudsoN");
		ServerCommand("bot_add_t %s", "Demho");
		ServerCommand("bot_add_t %s", "Vegi");
		ServerCommand("bot_add_t %s", "innocent");
		ServerCommand("mp_teamlogo_2 anon");
	}
	
	return Plugin_Handled;
}

public Action Team_HONORIS(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "TaZ");
		ServerCommand("bot_add_ct %s", "fr3nd");
		ServerCommand("bot_add_ct %s", "reiko");
		ServerCommand("bot_add_ct %s", "mouz");
		ServerCommand("bot_add_ct %s", "NEO");
		ServerCommand("mp_teamlogo_1 hono");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "TaZ");
		ServerCommand("bot_add_t %s", "fr3nd");
		ServerCommand("bot_add_t %s", "reiko");
		ServerCommand("bot_add_t %s", "mouz");
		ServerCommand("bot_add_t %s", "NEO");
		ServerCommand("mp_teamlogo_2 hono");
	}
	
	return Plugin_Handled;
}

public Action Team_Spirit(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "chopper");
		ServerCommand("bot_add_ct %s", "degster");
		ServerCommand("bot_add_ct %s", "magixx");
		ServerCommand("bot_add_ct %s", "Patsi");
		ServerCommand("bot_add_ct %s", "s1ren");
		ServerCommand("mp_teamlogo_1 spir");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "chopper");
		ServerCommand("bot_add_t %s", "degster");
		ServerCommand("bot_add_t %s", "magixx");
		ServerCommand("bot_add_t %s", "Patsi");
		ServerCommand("bot_add_t %s", "s1ren");
		ServerCommand("mp_teamlogo_2 spir");
	}
	
	return Plugin_Handled;
}

public Action Team_DNMK(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Niix");
		ServerCommand("bot_add_ct %s", "Leggy");
		ServerCommand("bot_add_ct %s", "dyvo");
		ServerCommand("bot_add_ct %s", "Doru");
		ServerCommand("bot_add_ct %s", "Dubee");
		ServerCommand("mp_teamlogo_1 dnmk");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Niix");
		ServerCommand("bot_add_t %s", "Leggy");
		ServerCommand("bot_add_t %s", "dyvo");
		ServerCommand("bot_add_t %s", "Doru");
		ServerCommand("bot_add_t %s", "Dubee");
		ServerCommand("mp_teamlogo_2 dnkm");
	}
	
	return Plugin_Handled;
}

public Action Team_iNation(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Dragon");
		ServerCommand("bot_add_ct %s", "VLDN");
		ServerCommand("bot_add_ct %s", "choiv7");
		ServerCommand("bot_add_ct %s", "Dav");
		ServerCommand("bot_add_ct %s", "SkippeR");
		ServerCommand("mp_teamlogo_1 inat");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Dragon");
		ServerCommand("bot_add_t %s", "VLDN");
		ServerCommand("bot_add_t %s", "choiv7");
		ServerCommand("bot_add_t %s", "Dav");
		ServerCommand("bot_add_t %s", "SkippeR");
		ServerCommand("mp_teamlogo_2 inat");
	}
	
	return Plugin_Handled;
}

public Action Team_LEISURE(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "get");
		ServerCommand("bot_add_ct %s", "rome");
		ServerCommand("bot_add_ct %s", "raveN");
		ServerCommand("bot_add_ct %s", "d1cer");
		ServerCommand("bot_add_ct %s", "oddo");
		ServerCommand("mp_teamlogo_1 leis");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "get");
		ServerCommand("bot_add_t %s", "rome");
		ServerCommand("bot_add_t %s", "raveN");
		ServerCommand("bot_add_t %s", "d1cer");
		ServerCommand("bot_add_t %s", "oddo");
		ServerCommand("mp_teamlogo_2 leis");
	}
	
	return Plugin_Handled;
}

public Action Team_Paqueta(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "DeStiNy");
		ServerCommand("bot_add_ct %s", "Gafolo");
		ServerCommand("bot_add_ct %s", "dav1d");
		ServerCommand("bot_add_ct %s", "KHTEX");
		ServerCommand("bot_add_ct %s", "iDk");
		ServerCommand("mp_teamlogo_1 paq");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "DeStiNy");
		ServerCommand("bot_add_t %s", "Gafolo");
		ServerCommand("bot_add_t %s", "dav1d");
		ServerCommand("bot_add_t %s", "KHTEX");
		ServerCommand("bot_add_t %s", "iDk");
		ServerCommand("mp_teamlogo_2 paq");
	}
	
	return Plugin_Handled;
}

public Action Team_BNB(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "MoMo");
		ServerCommand("bot_add_ct %s", "Swahn");
		ServerCommand("bot_add_ct %s", "Pluto");
		ServerCommand("bot_add_ct %s", "Spongey");
		ServerCommand("bot_add_ct %s", "Shakezullah");
		ServerCommand("mp_teamlogo_1 bnb");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "MoMo");
		ServerCommand("bot_add_t %s", "Swahn");
		ServerCommand("bot_add_t %s", "Pluto");
		ServerCommand("bot_add_t %s", "Spongey");
		ServerCommand("bot_add_t %s", "Shakezullah");
		ServerCommand("mp_teamlogo_2 bnb");
	}
	
	return Plugin_Handled;
}

public Action Team_Nation(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "coldzera");
		ServerCommand("bot_add_ct %s", "try");
		ServerCommand("bot_add_ct %s", "leo_drk");
		ServerCommand("bot_add_ct %s", "malbsMd");
		ServerCommand("bot_add_ct %s", "v$m");
		ServerCommand("mp_teamlogo_1 nat");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "coldzera");
		ServerCommand("bot_add_t %s", "try");
		ServerCommand("bot_add_t %s", "leo_drk");
		ServerCommand("bot_add_t %s", "malbsMd");
		ServerCommand("bot_add_t %s", "v$m");
		ServerCommand("mp_teamlogo_2 nat");
	}
	
	return Plugin_Handled;
}

public Action Team_Eriness(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "replay");
		ServerCommand("bot_add_ct %s", "stinx");
		ServerCommand("bot_add_ct %s", "Lueg");
		ServerCommand("bot_add_ct %s", "DOCKSTAR");
		ServerCommand("bot_add_ct %s", "Lastiik");
		ServerCommand("mp_teamlogo_1 eri");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "replay");
		ServerCommand("bot_add_t %s", "stinx");
		ServerCommand("bot_add_t %s", "Lueg");
		ServerCommand("bot_add_t %s", "DOCKSTAR");
		ServerCommand("bot_add_t %s", "Lastiik");
		ServerCommand("mp_teamlogo_2 eri");
	}
	
	return Plugin_Handled;
}

public Action Team_Entropiq(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Lack1");
		ServerCommand("bot_add_ct %s", "El1an");
		ServerCommand("bot_add_ct %s", "NickelBack");
		ServerCommand("bot_add_ct %s", "Krad");
		ServerCommand("bot_add_ct %s", "Forester");
		ServerCommand("mp_teamlogo_1 ent");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Lack1");
		ServerCommand("bot_add_t %s", "El1an");
		ServerCommand("bot_add_t %s", "NickelBack");
		ServerCommand("bot_add_t %s", "Krad");
		ServerCommand("bot_add_t %s", "Forester");
		ServerCommand("mp_teamlogo_2 ent");
	}
	
	return Plugin_Handled;
}

public Action Team_Strife(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "J0LZ");
		ServerCommand("bot_add_ct %s", "cool4st");
		ServerCommand("bot_add_ct %s", "hasteka");
		ServerCommand("bot_add_ct %s", "aris");
		ServerCommand("bot_add_ct %s", "D4rtyMontana");
		ServerCommand("mp_teamlogo_1 strife");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "J0LZ");
		ServerCommand("bot_add_t %s", "cool4st");
		ServerCommand("bot_add_t %s", "hasteka");
		ServerCommand("bot_add_t %s", "aris");
		ServerCommand("bot_add_t %s", "D4rtyMontana");
		ServerCommand("mp_teamlogo_2 strife");
	}
	
	return Plugin_Handled;
}

public Action Team_Party(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "ben1337");
		ServerCommand("bot_add_ct %s", "PwnAlone");
		ServerCommand("bot_add_ct %s", "djay");
		ServerCommand("bot_add_ct %s", "Jonji");
		ServerCommand("bot_add_ct %s", "viz");
		ServerCommand("mp_teamlogo_1 part");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "ben1337");
		ServerCommand("bot_add_t %s", "PwnAlone");
		ServerCommand("bot_add_t %s", "djay");
		ServerCommand("bot_add_t %s", "Jonji");
		ServerCommand("bot_add_t %s", "viz");
		ServerCommand("mp_teamlogo_2 part");
	}
	
	return Plugin_Handled;
}

public Action Team_777(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "ruyter");
		ServerCommand("bot_add_ct %s", "Grus");
		ServerCommand("bot_add_ct %s", "mikki");
		ServerCommand("bot_add_ct %s", "akEz");
		ServerCommand("bot_add_ct %s", "H4RR3");
		ServerCommand("mp_teamlogo_1 777");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "ruyter");
		ServerCommand("bot_add_t %s", "Grus");
		ServerCommand("bot_add_t %s", "mikki");
		ServerCommand("bot_add_t %s", "akEz");
		ServerCommand("bot_add_t %s", "H4RR3");
		ServerCommand("mp_teamlogo_2 777");
	}
	
	return Plugin_Handled;
}

public Action Team_CG(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "kressy");
		ServerCommand("bot_add_ct %s", "PANIX");
		ServerCommand("bot_add_ct %s", "glaVed");
		ServerCommand("bot_add_ct %s", "kRYSTAL");
		ServerCommand("bot_add_ct %s", "stfN");
		ServerCommand("mp_teamlogo_1 cg");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "kressy");
		ServerCommand("bot_add_t %s", "PANIX");
		ServerCommand("bot_add_t %s", "glaVed");
		ServerCommand("bot_add_t %s", "kRYSTAL");
		ServerCommand("bot_add_t %s", "stfN");
		ServerCommand("mp_teamlogo_2 cg");
	}
	
	return Plugin_Handled;
}

public Action Team_BLUEJAYS(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "aidKiT");
		ServerCommand("bot_add_ct %s", "kyxsan");
		ServerCommand("bot_add_ct %s", "stYleEeZ");
		ServerCommand("bot_add_ct %s", "dan1");
		ServerCommand("bot_add_ct %s", "Cryveng");
		ServerCommand("mp_teamlogo_1 bluej");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "aidKiT");
		ServerCommand("bot_add_t %s", "kyxsan");
		ServerCommand("bot_add_t %s", "stYleEeZ");
		ServerCommand("bot_add_t %s", "dan1");
		ServerCommand("bot_add_t %s", "Cryveng");
		ServerCommand("mp_teamlogo_2 bluej");
	}
	
	return Plugin_Handled;
}

public Action Team_ECK(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "byr9");
		ServerCommand("bot_add_ct %s", "uQlutzavr");
		ServerCommand("bot_add_ct %s", "Smash");
		ServerCommand("bot_add_ct %s", "s4");
		ServerCommand("bot_add_ct %s", "amster");
		ServerCommand("mp_teamlogo_1 eck");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "byr9");
		ServerCommand("bot_add_t %s", "uQlutzavr");
		ServerCommand("bot_add_t %s", "Smash");
		ServerCommand("bot_add_t %s", "s4");
		ServerCommand("bot_add_t %s", "amster");
		ServerCommand("mp_teamlogo_2 eck");
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
		ServerCommand("bot_add_ct %s", "jelo");
		ServerCommand("bot_add_ct %s", "Mikzuuu");
		ServerCommand("bot_add_ct %s", "Samppa");
		ServerCommand("bot_add_ct %s", "eDi");
		ServerCommand("bot_add_ct %s", "JUS6");
		ServerCommand("mp_teamlogo_1 conq");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "jelo");
		ServerCommand("bot_add_t %s", "Mikzuuu");
		ServerCommand("bot_add_t %s", "Samppa");
		ServerCommand("bot_add_t %s", "eDi");
		ServerCommand("bot_add_t %s", "JUS6");
		ServerCommand("mp_teamlogo_2 conq");
	}
	
	return Plugin_Handled;
}

public Action Team_AVANGAR(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "FinigaN");
		ServerCommand("bot_add_ct %s", "fozil");
		ServerCommand("bot_add_ct %s", "kade0");
		ServerCommand("bot_add_ct %s", "enzero");
		ServerCommand("bot_add_ct %s", "ICY");
		ServerCommand("mp_teamlogo_1 avg");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "FinigaN");
		ServerCommand("bot_add_t %s", "fozil");
		ServerCommand("bot_add_t %s", "kade0");
		ServerCommand("bot_add_t %s", "enzero");
		ServerCommand("bot_add_t %s", "ICY");
		ServerCommand("mp_teamlogo_2 avg");
	}
	
	return Plugin_Handled;
}

public Action Team_SWS(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "gbb");
		ServerCommand("bot_add_ct %s", "CSO");
		ServerCommand("bot_add_ct %s", "bsd");
		ServerCommand("bot_add_ct %s", "DANVIET");
		ServerCommand("bot_add_ct %s", "w1");
		ServerCommand("mp_teamlogo_1 sws");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "gbb");
		ServerCommand("bot_add_t %s", "CSO");
		ServerCommand("bot_add_t %s", "bsd");
		ServerCommand("bot_add_t %s", "DANVIET");
		ServerCommand("bot_add_t %s", "w1");
		ServerCommand("mp_teamlogo_2 sws");
	}
	
	return Plugin_Handled;
}

public Action Team_Leviatan(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "1962");
		ServerCommand("bot_add_ct %s", "fakzwall");
		ServerCommand("bot_add_ct %s", "Reversive");
		ServerCommand("bot_add_ct %s", "meyern");
		ServerCommand("bot_add_ct %s", "pancc");
		ServerCommand("mp_teamlogo_1 levi");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "1962");
		ServerCommand("bot_add_t %s", "fakzwall");
		ServerCommand("bot_add_t %s", "Reversive");
		ServerCommand("bot_add_t %s", "meyern");
		ServerCommand("bot_add_t %s", "pancc");
		ServerCommand("mp_teamlogo_2 levi");
	}
	
	return Plugin_Handled;
}

public Action Team_Furious(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "KAISER");
		ServerCommand("bot_add_ct %s", "TIKO");
		ServerCommand("bot_add_ct %s", "laser");
		ServerCommand("bot_add_ct %s", "andrew");
		ServerCommand("bot_add_ct %s", "ABM");
		ServerCommand("mp_teamlogo_1 fur");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "KAISER");
		ServerCommand("bot_add_t %s", "TIKO");
		ServerCommand("bot_add_t %s", "laser");
		ServerCommand("bot_add_t %s", "andrew");
		ServerCommand("bot_add_t %s", "ABM");
		ServerCommand("mp_teamlogo_2 fur");
	}
	
	return Plugin_Handled;
}

public Action Team_MongolZ(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "ncl");
		ServerCommand("bot_add_ct %s", "MagnumZ");
		ServerCommand("bot_add_ct %s", "Tsogoo");
		ServerCommand("bot_add_ct %s", "Machinegun");
		ServerCommand("bot_add_ct %s", "starDUST");
		ServerCommand("mp_teamlogo_1 mon");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "ncl");
		ServerCommand("bot_add_t %s", "MagnumZ");
		ServerCommand("bot_add_t %s", "Tsogoo");
		ServerCommand("bot_add_t %s", "Machinegun");
		ServerCommand("bot_add_t %s", "starDUST");
		ServerCommand("mp_teamlogo_2 mon");
	}
	
	return Plugin_Handled;
}

public Action Team_ONYX(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "bodito");
		ServerCommand("bot_add_ct %s", "Kamion");
		ServerCommand("bot_add_ct %s", "sl3nd");
		ServerCommand("bot_add_ct %s", "msN");
		ServerCommand("bot_add_ct %s", "coolio");
		ServerCommand("mp_teamlogo_1 ony");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "bodito");
		ServerCommand("bot_add_t %s", "Kamion");
		ServerCommand("bot_add_t %s", "sl3nd");
		ServerCommand("bot_add_t %s", "msN");
		ServerCommand("bot_add_t %s", "coolio");
		ServerCommand("mp_teamlogo_2 ony");
	}
	
	return Plugin_Handled;
}

public Action Team_Dice(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "XpG");
		ServerCommand("bot_add_ct %s", "Gauthierlele");
		ServerCommand("bot_add_ct %s", "Alca");
		ServerCommand("bot_add_ct %s", "bSSSSSS");
		ServerCommand("bot_add_ct %s", "CamZ");
		ServerCommand("mp_teamlogo_1 dice");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "XpG");
		ServerCommand("bot_add_t %s", "Gauthierlele");
		ServerCommand("bot_add_t %s", "Alca");
		ServerCommand("bot_add_t %s", "bSSSSSS");
		ServerCommand("bot_add_t %s", "CamZ");
		ServerCommand("mp_teamlogo_2 dice");
	}
	
	return Plugin_Handled;
}

public Action Team_Falcons(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Kyojin");
		ServerCommand("bot_add_ct %s", "Maka");
		ServerCommand("bot_add_ct %s", "hAdji");
		ServerCommand("bot_add_ct %s", "Keoz");
		ServerCommand("bot_add_ct %s", "Python");
		ServerCommand("mp_teamlogo_1 fal");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Kyojin");
		ServerCommand("bot_add_t %s", "Maka");
		ServerCommand("bot_add_t %s", "hAdji");
		ServerCommand("bot_add_t %s", "Keoz");
		ServerCommand("bot_add_t %s", "Python");
		ServerCommand("mp_teamlogo_2 fal");
	}
	
	return Plugin_Handled;
}

public Action Team_GameAgents(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Klameczka");
		ServerCommand("bot_add_ct %s", "Bajmi");
		ServerCommand("bot_add_ct %s", "Flayy");
		ServerCommand("bot_add_ct %s", "noise");
		ServerCommand("bot_add_ct %s", "Majster");
		ServerCommand("mp_teamlogo_1 game");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Klameczka");
		ServerCommand("bot_add_t %s", "Bajmi");
		ServerCommand("bot_add_t %s", "Flayy");
		ServerCommand("bot_add_t %s", "noise");
		ServerCommand("bot_add_t %s", "Majster");
		ServerCommand("mp_teamlogo_2 game");
	}
	
	return Plugin_Handled;
}

public Action Team_Entropy(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "powerYY");
		ServerCommand("bot_add_ct %s", "stefank0k0");
		ServerCommand("bot_add_ct %s", "KrowNii");
		ServerCommand("bot_add_ct %s", "fatih-");
		ServerCommand("bot_add_ct %s", "AKEX");
		ServerCommand("mp_teamlogo_1 entr");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "powerYY");
		ServerCommand("bot_add_t %s", "stefank0k0");
		ServerCommand("bot_add_t %s", "KrowNii");
		ServerCommand("bot_add_t %s", "fatih-");
		ServerCommand("bot_add_t %s", "AKEX");
		ServerCommand("mp_teamlogo_2 entr");
	}
	
	return Plugin_Handled;
}

public Action Team_SSP(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "rapala");
		ServerCommand("bot_add_ct %s", "LapeX");
		ServerCommand("bot_add_ct %s", "DreaM-");
		ServerCommand("bot_add_ct %s", "florento");
		ServerCommand("bot_add_ct %s", "pr1metapz");
		ServerCommand("mp_teamlogo_1 ssp");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "rapala");
		ServerCommand("bot_add_t %s", "LapeX");
		ServerCommand("bot_add_t %s", "DreaM-");
		ServerCommand("bot_add_t %s", "florento");
		ServerCommand("bot_add_t %s", "pr1metapz");
		ServerCommand("mp_teamlogo_2 ssp");
	}
	
	return Plugin_Handled;
}

public Action Team_Renewal(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "xerolte");
		ServerCommand("bot_add_ct %s", "Ensury");
		ServerCommand("bot_add_ct %s", "NEUZ");
		ServerCommand("bot_add_ct %s", "MiQ");
		ServerCommand("bot_add_ct %s", "sT0P");
		ServerCommand("mp_teamlogo_1 rene");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "xerolte");
		ServerCommand("bot_add_t %s", "Ensury");
		ServerCommand("bot_add_t %s", "NEUZ");
		ServerCommand("bot_add_t %s", "MiQ");
		ServerCommand("bot_add_t %s", "sT0P");
		ServerCommand("mp_teamlogo_2 rene");
	}
	
	return Plugin_Handled;
}

public Action Team_OneTap(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "GEOHYPE");
		ServerCommand("bot_add_ct %s", "MoDo");
		ServerCommand("bot_add_ct %s", "smekk");
		ServerCommand("bot_add_ct %s", "swiiffter");
		ServerCommand("bot_add_ct %s", "ADRON");
		ServerCommand("mp_teamlogo_1 tap");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "GEOHYPE");
		ServerCommand("bot_add_t %s", "MoDo");
		ServerCommand("bot_add_t %s", "smekk");
		ServerCommand("bot_add_t %s", "swiiffter");
		ServerCommand("bot_add_t %s", "ADRON");
		ServerCommand("mp_teamlogo_2 tap");
	}
	
	return Plugin_Handled;
}

public Action Team_BP(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "fleav");
		ServerCommand("bot_add_ct %s", "kolor");
		ServerCommand("bot_add_ct %s", "Aaron");
		ServerCommand("bot_add_ct %s", "gubi");
		ServerCommand("bot_add_ct %s", "1NSERT2");
		ServerCommand("mp_teamlogo_1 bp");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "fleav");
		ServerCommand("bot_add_t %s", "kolor");
		ServerCommand("bot_add_t %s", "Aaron");
		ServerCommand("bot_add_t %s", "gubi");
		ServerCommand("bot_add_t %s", "1NSERT2");
		ServerCommand("mp_teamlogo_2 bp");
	}
	
	return Plugin_Handled;
}

public Action Team_mCon(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "StepzZ");
		ServerCommand("bot_add_ct %s", "VoxelArc");
		ServerCommand("bot_add_ct %s", "BickBuster");
		ServerCommand("bot_add_ct %s", "Maxaxe");
		ServerCommand("bot_add_ct %s", "Syther");
		ServerCommand("mp_teamlogo_1 mcon");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "StepzZ");
		ServerCommand("bot_add_t %s", "VoxelArc");
		ServerCommand("bot_add_t %s", "BickBuster");
		ServerCommand("bot_add_t %s", "Maxaxe");
		ServerCommand("bot_add_t %s", "Syther");
		ServerCommand("mp_teamlogo_2 mcon");
	}
	
	return Plugin_Handled;
}

public Action Team_HEET(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Luckyy");
		ServerCommand("bot_add_ct %s", "afro");
		ServerCommand("bot_add_ct %s", "bodyy");
		ServerCommand("bot_add_ct %s", "Djoko");
		ServerCommand("bot_add_ct %s", "Ex3rcice");
		ServerCommand("mp_teamlogo_1 heet");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Luckyy");
		ServerCommand("bot_add_t %s", "afro");
		ServerCommand("bot_add_t %s", "bodyy");
		ServerCommand("bot_add_t %s", "Djoko");
		ServerCommand("bot_add_t %s", "Ex3rcice");
		ServerCommand("mp_teamlogo_2 heet");
	}
	
	return Plugin_Handled;
}

public Action Team_LLL(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Rezst");
		ServerCommand("bot_add_ct %s", "ryu");
		ServerCommand("bot_add_ct %s", "Nexius");
		ServerCommand("bot_add_ct %s", "ReFuZR");
		ServerCommand("bot_add_ct %s", "rabbit");
		ServerCommand("mp_teamlogo_1 lll");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Rezst");
		ServerCommand("bot_add_t %s", "ryu");
		ServerCommand("bot_add_t %s", "Nexius");
		ServerCommand("bot_add_t %s", "ReFuZR");
		ServerCommand("bot_add_t %s", "rabbit");
		ServerCommand("mp_teamlogo_2 lll");
	}
	
	return Plugin_Handled;
}

public Action Team_LDLC(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Graviti");
		ServerCommand("bot_add_ct %s", "Broox");
		ServerCommand("bot_add_ct %s", "ElectuS");
		ServerCommand("bot_add_ct %s", "Diviiii");
		ServerCommand("bot_add_ct %s", "Neityu");
		ServerCommand("mp_teamlogo_1 ldlc");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Graviti");
		ServerCommand("bot_add_t %s", "Broox");
		ServerCommand("bot_add_t %s", "ElectuS");
		ServerCommand("bot_add_t %s", "Diviiii");
		ServerCommand("bot_add_t %s", "Neityu");
		ServerCommand("mp_teamlogo_2 ldlc");
	}
	
	return Plugin_Handled;
}

public Action Team_Vireo(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Fur_Daddy");
		ServerCommand("bot_add_ct %s", "emokie");
		ServerCommand("bot_add_ct %s", "Champ");
		ServerCommand("bot_add_ct %s", "KRL");
		ServerCommand("bot_add_ct %s", "drayza");
		ServerCommand("mp_teamlogo_1 vireo");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Fur_Daddy");
		ServerCommand("bot_add_t %s", "emokie");
		ServerCommand("bot_add_t %s", "Champ");
		ServerCommand("bot_add_t %s", "KRL");
		ServerCommand("bot_add_t %s", "drayza");
		ServerCommand("mp_teamlogo_2 vireo");
	}
	
	return Plugin_Handled;
}

public Action Team_Imperial(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "fer");
		ServerCommand("bot_add_ct %s", "FalleN");
		ServerCommand("bot_add_ct %s", "fnx");
		ServerCommand("bot_add_ct %s", "boltz");
		ServerCommand("bot_add_ct %s", "VINI");
		ServerCommand("mp_teamlogo_1 impe");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "fer");
		ServerCommand("bot_add_t %s", "FalleN");
		ServerCommand("bot_add_t %s", "fnx");
		ServerCommand("bot_add_t %s", "boltz");
		ServerCommand("bot_add_t %s", "VINI");
		ServerCommand("mp_teamlogo_2 impe");
	}
	
	return Plugin_Handled;
}

public Action Team_Berzerk(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "AbuWilly");
		ServerCommand("bot_add_ct %s", "devraNN");
		ServerCommand("bot_add_ct %s", "ND");
		ServerCommand("bot_add_ct %s", "CHANKY");
		ServerCommand("bot_add_ct %s", "maty");
		ServerCommand("mp_teamlogo_1 berz");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "AbuWilly");
		ServerCommand("bot_add_t %s", "devraNN");
		ServerCommand("bot_add_t %s", "ND");
		ServerCommand("bot_add_t %s", "CHANKY");
		ServerCommand("bot_add_t %s", "maty");
		ServerCommand("mp_teamlogo_2 berz");
	}
	
	return Plugin_Handled;
}

public Action Team_K1CK(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "v1c7oR");
		ServerCommand("bot_add_ct %s", "SPELLAN");
		ServerCommand("bot_add_ct %s", "rafftu");
		ServerCommand("bot_add_ct %s", "AwaykeN");
		ServerCommand("bot_add_ct %s", "SAiKY");
		ServerCommand("mp_teamlogo_1 k1ck");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "v1c7oR");
		ServerCommand("bot_add_t %s", "SPELLAN");
		ServerCommand("bot_add_t %s", "rafftu");
		ServerCommand("bot_add_t %s", "AwaykeN");
		ServerCommand("bot_add_t %s", "SAiKY");
		ServerCommand("mp_teamlogo_2 k1ck");
	}
	
	return Plugin_Handled;
}

public Action Team_TC(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "propleh");
		ServerCommand("bot_add_ct %s", "tricky");
		ServerCommand("bot_add_ct %s", "almazer");
		ServerCommand("bot_add_ct %s", "SasukeQO");
		ServerCommand("bot_add_ct %s", "zLy");
		ServerCommand("mp_teamlogo_1 tc");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "propleh");
		ServerCommand("bot_add_t %s", "tricky");
		ServerCommand("bot_add_t %s", "almazer");
		ServerCommand("bot_add_t %s", "SasukeQO");
		ServerCommand("bot_add_t %s", "zLy");
		ServerCommand("mp_teamlogo_2 tc");
	}
	
	return Plugin_Handled;
}

public Action Team_LFO(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "HaZR");
		ServerCommand("bot_add_ct %s", "sterling");
		ServerCommand("bot_add_ct %s", "Liki");
		ServerCommand("bot_add_ct %s", "SaVage");
		ServerCommand("bot_add_ct %s", "apoc");
		ServerCommand("mp_teamlogo_1 lfo");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "HaZR");
		ServerCommand("bot_add_t %s", "sterling");
		ServerCommand("bot_add_t %s", "Liki");
		ServerCommand("bot_add_t %s", "SaVage");
		ServerCommand("bot_add_t %s", "apoc");
		ServerCommand("mp_teamlogo_2 lfo");
	}
	
	return Plugin_Handled;
}

public Action Team_AG(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "FIOURN");
		ServerCommand("bot_add_ct %s", "Monster");
		ServerCommand("bot_add_ct %s", "waituu");
		ServerCommand("bot_add_ct %s", "ayaya");
		ServerCommand("bot_add_ct %s", "AiM");
		ServerCommand("mp_teamlogo_1 ag");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "FIOURN");
		ServerCommand("bot_add_t %s", "Monster");
		ServerCommand("bot_add_t %s", "waituu");
		ServerCommand("bot_add_t %s", "ayaya");
		ServerCommand("bot_add_t %s", "AiM");
		ServerCommand("mp_teamlogo_2 ag");
	}
	
	return Plugin_Handled;
}

public Action Team_NKT(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "XigN");
		ServerCommand("bot_add_ct %s", "ImpressioN");
		ServerCommand("bot_add_ct %s", "Kntz");
		ServerCommand("bot_add_ct %s", "dobu");
		ServerCommand("bot_add_ct %s", "cool4st");
		ServerCommand("mp_teamlogo_1 nkt");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "XigN");
		ServerCommand("bot_add_t %s", "ImpressioN");
		ServerCommand("bot_add_t %s", "Kntz");
		ServerCommand("bot_add_t %s", "dobu");
		ServerCommand("bot_add_t %s", "cool4st");
		ServerCommand("mp_teamlogo_2 nkt");
	}
	
	return Plugin_Handled;
}

public Action Team_1shot(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "GreK");
		ServerCommand("bot_add_ct %s", "FpSSS");
		ServerCommand("bot_add_ct %s", "Get_Jeka");
		ServerCommand("bot_add_ct %s", "faydett");
		ServerCommand("bot_add_ct %s", "synyx");
		ServerCommand("mp_teamlogo_1 1s");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "GreK");
		ServerCommand("bot_add_t %s", "FpSSS");
		ServerCommand("bot_add_t %s", "Get_Jeka");
		ServerCommand("bot_add_t %s", "faydett");
		ServerCommand("bot_add_t %s", "synyx");
		ServerCommand("mp_teamlogo_2 1s");
	}
	
	return Plugin_Handled;
}

public Action Team_Boca(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "luchov");
		ServerCommand("bot_add_ct %s", "elemeNt");
		ServerCommand("bot_add_ct %s", "alexer");
		ServerCommand("bot_add_ct %s", "nbl");
		ServerCommand("bot_add_ct %s", "MRN1");
		ServerCommand("mp_teamlogo_1 boca");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "luchov");
		ServerCommand("bot_add_t %s", "elemeNt");
		ServerCommand("bot_add_t %s", "alexer");
		ServerCommand("bot_add_t %s", "nbl");
		ServerCommand("bot_add_t %s", "MRN1");
		ServerCommand("mp_teamlogo_2 boca");
	}
	
	return Plugin_Handled;
}

public Action Team_ITB(int client, int iArgs)
{
	char szArg[12];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	if (strcmp(szArg, "ct") == 0)
	{
		ServerCommand("bot_kick ct all");
		ServerCommand("bot_add_ct %s", "Adam9130");
		ServerCommand("bot_add_ct %s", "smooya");
		ServerCommand("bot_add_ct %s", "dobbo");
		ServerCommand("bot_add_ct %s", "CYPHER");
		ServerCommand("bot_add_ct %s", "Tadpole");
		ServerCommand("mp_teamlogo_1 itb");
	}
	
	if (strcmp(szArg, "t") == 0)
	{
		ServerCommand("bot_kick t all");
		ServerCommand("bot_add_t %s", "Adam9130");
		ServerCommand("bot_add_t %s", "smooya");
		ServerCommand("bot_add_t %s", "dobbo");
		ServerCommand("bot_add_t %s", "CYPHER");
		ServerCommand("bot_add_t %s", "Tadpole");
		ServerCommand("mp_teamlogo_2 itb");
	}
	
	return Plugin_Handled;
}

public void OnMapStart()
{
	g_iProfileRankOffset = FindSendPropInfo("CCSPlayerResource", "m_nPersonaDataPublicLevel");
	g_iPlayerColorOffset = FindSendPropInfo("CCSPlayerResource", "m_iCompTeammateColor");
	
	GetCurrentMap(g_szMap, sizeof(g_szMap));
	
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
			
			if (Math_GetRandomInt(1, 100) <= 5)
			{
				FakeClientCommand(i, "+lookatweapon");
				FakeClientCommand(i, "-lookatweapon");
			}
			
			if ((g_iCurrentRound == 0 || g_iCurrentRound == 15) && bInBuyZone)
			{
				switch (Math_GetRandomInt(1,6))
				{
					case 1,2,3: FakeClientCommand(i, "buy vest");
					case 6:	FakeClientCommand(i, "buy %s", (iTeam == CS_TEAM_CT) ? "defuser" : "p250");
				}
			}
			else if ((iAccount > g_cvBotEcoLimit.IntValue || GetPlayerWeaponSlot(i, CS_SLOT_PRIMARY) != -1) && bInBuyZone)
			{
				if (GetEntProp(i, Prop_Data, "m_ArmorValue") < 50 || GetEntProp(i, Prop_Send, "m_bHasHelmet") == 0)
					FakeClientCommand(i, "buy vesthelm");
				
				if (iTeam == CS_TEAM_CT && !bHasDefuser)
					FakeClientCommand(i, "buy defuser");
			}
			else if (iAccount < g_cvBotEcoLimit.IntValue && iAccount > 2000 && !bHasDefuser && bInBuyZone)
			{
				switch (Math_GetRandomInt(1,15))
				{
					case 1: FakeClientCommand(i, "buy vest");
					case 10: FakeClientCommand(i, "buy %s", (iTeam == CS_TEAM_CT) ? "defuser" : "vest");
				}
			}
		}
	}
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
						
						if (fPlantedC4Distance > 2000.0 && !BotIsBusy(client) && GetEntData(client, g_iBotNearbyEnemiesOffset) == 0 && !g_bDontSwitch[client])
						{
							SDKCall(g_hSwitchWeaponCall, client, GetPlayerWeaponSlot(client, CS_SLOT_KNIFE), 0);
							BotMoveTo(client, fPlantedC4Location, FASTEST_ROUTE);
						}
					}
				}
				
				if (g_bFreezetimeEnd && !g_bBombPlanted && !BotIsBusy(client) && !BotIsHiding(client) && !BotMimic_IsPlayerMimicing(client))
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
	
	if(g_bFreezetimeEnd)
		return Plugin_Stop;
	else
		return Plugin_Continue;
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
				g_fReactionTime[client] = Math_GetRandomFloat(0.10, 0.30);
			}
			g_bIsProBot[client] = true;
		}
		
		CS_SetClientClanTag(client, szClanTag);
		GetCrosshairCode(szBotName, g_szCrosshairCode[client], 35);
		
		g_iUSPChance[client] = Math_GetRandomInt(1, 100);
		g_iM4A1SChance[client] = Math_GetRandomInt(1, 100);
		g_pCurrArea[client] = INVALID_NAV_AREA;
		
		SDKHook(client, SDKHook_OnTakeDamageAlive, OnTakeDamageAlive);
	}
}

public void OnRoundStart(Event eEvent, char[] szName, bool bDontBroadcast)
{
	int iTeam = g_bIsBombScenario ? CS_TEAM_CT : CS_TEAM_T;
	int iOppositeTeam = g_bIsBombScenario ? CS_TEAM_T : CS_TEAM_CT;
	
	g_iCurrentRound = GameRules_GetProp("m_totalRoundsPlayed");
	g_bFreezetimeEnd = false;
	g_bAbortExecute = false;
	g_bTerroristEco = false;
	g_bEveryoneDead = false;
	g_fRoundStart = GetGameTime();
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && IsFakeClient(i) && IsPlayerAlive(i))
		{	
			g_iUncrouchChance[i] = Math_GetRandomInt(1, 100);
			g_bDontSwitch[i] = false;
			g_bDropWeapon[i] = false;
			g_bHasGottenDrop[i] = false;
			g_iTarget[i] = -1;
				
			if(g_bIsBombScenario || g_bIsHostageScenario)
			{
				if(GetClientTeam(i) == iTeam)
					SetEntData(i, g_iBotMoraleOffset, -3);
				if(g_bHalftimeSwitch && GetClientTeam(i) == iOppositeTeam)
				{
					SetEntData(i, g_iBotMoraleOffset, 1);
				}
			}
		}
	}
	
	g_bHalftimeSwitch = false;
	CreateTimer(0.2, Timer_DropWeapons, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

public void OnFreezetimeEnd(Event eEvent, char[] szName, bool bDontBroadcast)
{
	g_bFreezetimeEnd = true;
	g_fFreezeTimeEnd = GetGameTime();
	bool bWarmupPeriod = !!GameRules_GetProp("m_bWarmupPeriod");
	
	if(bWarmupPeriod || g_bTerroristEco || HumansOnTeam(CS_TEAM_T) > 0)
		return;
	
	if(Math_GetRandomInt(1,100) <= 60)
	{
		if (strcmp(g_szMap, "de_mirage") == 0)
		{
			g_iRndExecute = (g_iCurrentRound == 0 || g_iCurrentRound == 15) ? Math_GetRandomInt(1, 3) : Math_GetRandomInt(1, 21);
			LogMessage("BOT STUFF: %s selected execute for Round %i: %i", g_szMap, g_iCurrentRound, g_iRndExecute);
			PrepareMirageExecutes();
		}
		else if (strcmp(g_szMap, "de_dust2") == 0)
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
			g_iRndExecute = Math_GetRandomInt(1, 2);
			LogMessage("BOT STUFF: %s selected execute for Round %i: %i", g_szMap, g_iCurrentRound, g_iRndExecute);
			PrepareTrainExecutes();
		}
		else if (strcmp(g_szMap, "de_nuke") == 0)
		{
			g_iRndExecute = Math_GetRandomInt(1, 2);
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
			g_iRndExecute = Math_GetRandomInt(1, 3);
			LogMessage("BOT STUFF: %s selected execute for Round %i: %i", g_szMap, g_iCurrentRound, g_iRndExecute);
			PrepareCacheExecutes();
		}
		else if (strcmp(g_szMap, "de_ancient") == 0)
		{
			g_iRndExecute = Math_GetRandomInt(1, 3);
			LogMessage("BOT STUFF: %s selected execute for Round %i: %i", g_szMap, g_iCurrentRound, g_iRndExecute);
			PrepareAncientExecutes();
		}
	}
}

public void OnWeaponZoom(Event eEvent, const char[] szName, bool bDontBroadcast)
{
	int client = GetClientOfUserId(eEvent.GetInt("userid"));
	
	if (IsValidClient(client) && IsFakeClient(client) && IsPlayerAlive(client))
		CreateTimer(0.3, Timer_Zoomed, GetClientUserId(client));
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
		{
			g_bZoomed[client] = false;
			CreateTimer(0.1, Timer_DelaySwitch, GetClientUserId(client));
		}
	}
}

public void OnLastRoundHalf(Event eEvent, const char[] szName, bool bDontBroadcast)
{	
	g_bHalftimeSwitch = true;
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
			if (g_iM4A1SChance[client] <= 50 && iAccount >= CS_GetWeaponPrice(client, CSWeapon_M4A1_SILENCER))
			{
				CSGO_SetMoney(client, iAccount - CS_GetWeaponPrice(client, CSWeapon_M4A1_SILENCER));
				CSGO_ReplaceWeapon(client, CS_SLOT_PRIMARY, "weapon_m4a1_silencer");
				
				return Plugin_Changed;
			}
			
			if (Math_GetRandomInt(1, 100) <= 5 && iAccount >= CS_GetWeaponPrice(client, CSWeapon_AUG))
			{
				CSGO_SetMoney(client, iAccount - CS_GetWeaponPrice(client, CSWeapon_AUG));
				CSGO_ReplaceWeapon(client, CS_SLOT_PRIMARY, "weapon_aug");
				
				return Plugin_Changed;
			}
		}
		else if (strcmp(szWeapon, "mac10") == 0)
		{
			if (Math_GetRandomInt(1, 100) <= 40 && iAccount >= CS_GetWeaponPrice(client, CSWeapon_GALILAR))
			{
				CSGO_SetMoney(client, iAccount - CS_GetWeaponPrice(client, CSWeapon_GALILAR));
				CSGO_ReplaceWeapon(client, CS_SLOT_PRIMARY, "weapon_galilar");
				
				return Plugin_Changed;
			}
		}
		else if (strcmp(szWeapon, "mp9") == 0)
		{
			if (Math_GetRandomInt(1, 100) <= 40 && iAccount >= CS_GetWeaponPrice(client, CSWeapon_FAMAS))
			{
				CSGO_SetMoney(client, iAccount - CS_GetWeaponPrice(client, CSWeapon_FAMAS));
				CSGO_ReplaceWeapon(client, CS_SLOT_PRIMARY, "weapon_famas");
				
				return Plugin_Changed;
			}
			else if (Math_GetRandomInt(1, 100) <= 15 && iAccount >= CS_GetWeaponPrice(client, CSWeapon_UMP45))
			{
				CSGO_SetMoney(client, iAccount - CS_GetWeaponPrice(client, CSWeapon_UMP45));
				CSGO_ReplaceWeapon(client, CS_SLOT_PRIMARY, "weapon_ump45");
				
				return Plugin_Changed;
			}
		}
		else if (strcmp(szWeapon, "tec9") == 0 || strcmp(szWeapon, "fiveseven") == 0)
		{
			if (Math_GetRandomInt(1, 100) <= 50)
			{
				CSGO_SetMoney(client, iAccount - CS_GetWeaponPrice(client, CSWeapon_CZ75A));
				CSGO_ReplaceWeapon(client, CS_SLOT_PRIMARY, "weapon_cz75a");
				
				return Plugin_Changed;
			}
		}
	}
	return Plugin_Continue;
}

public MRESReturn CCSBot_ThrowGrenade(int client, DHookParam hParams)
{
	if (BotMimic_IsPlayerMimicing(client))
		return MRES_Supercede;
	
	hParams.GetVector(1, g_fNadeTarget[client]);
	
	return MRES_Ignored;
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
		BotBendLineOfSight(client, fEyePos, g_fNadeTarget[client], g_fNadeTarget[client], 180.0);
		hParams.SetVector(2, g_fNadeTarget[client]);
		
		return MRES_ChangedHandled;
	}
	else if(strcmp(szDesc, "Noise") == 0)
	{
		int iActiveWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		
		int iDefIndex = IsValidEntity(iActiveWeapon) ? GetEntProp(iActiveWeapon, Prop_Send, "m_iItemDefinitionIndex") : 0;
		
		if(eItems_GetWeaponSlotByDefIndex(iDefIndex) == CS_SLOT_KNIFE)
		{
			BotEquipBestWeapon(client, true);
			g_bDontSwitch[client] = true;
			CreateTimer(2.0, Timer_EnableSwitch, GetClientUserId(client));
		}

		float fNoisePos[3], fClientEyes[3];
		
		DHookGetParamVector(hParams, 2, fNoisePos);
		fNoisePos[2] += 25.0;
		DHookSetParamVector(hParams, 2, fNoisePos);
		
		GetClientEyePosition(client, fClientEyes);
		if(Math_GetRandomInt(1, 100) <= 35 && IsPointVisible(fClientEyes, fNoisePos) && LineGoesThroughSmoke(fClientEyes, fNoisePos))
			DHookSetParam(hParams, 7, true);
		
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
			
			if(((GetGameTime() - g_fFreezeTimeEnd) < GetEntDataFloat(client, g_iBotSafeTimeOffset) && !BotMimic_IsPlayerMimicing(client)) || g_bEveryoneDead)
				iButtons &= ~IN_SPEED;
			
			if(GetEntPropFloat(client, Prop_Send, "m_flMaxspeed") == 1.0)
				SetEntPropFloat(client, Prop_Send, "m_flMaxspeed", 260.0);
			
			if (g_bIsProBot[client])
			{		
				g_iTarget[client] = BotGetEnemy(client);
				
				float fTargetDistance;
				int iZoomLevel;
				bool bIsEnemyVisible = !!GetEntData(client, g_iEnemyVisibleOffset);
				bool bIsAttacking = !!GetEntData(client, g_iBotAttackingOffset);
				bool bIsHiding = BotIsHiding(client);
				bool bIsDucking = !!(GetEntityFlags(client) & FL_DUCKING);
				bool bIsReloading = IsPlayerReloading(client);
				
				if(HasEntProp(iActiveWeapon, Prop_Send, "m_zoomLevel"))
					iZoomLevel = GetEntProp(iActiveWeapon, Prop_Send, "m_zoomLevel");
				
				if (!GetEntProp(client, Prop_Send, "m_bIsScoped"))
					g_bZoomed[client] = false;
				
				if(bIsHiding && (iDefIndex == 8 || iDefIndex == 39) && iZoomLevel == 0)
					iButtons |= IN_ATTACK2;
				else if(!bIsHiding && (iDefIndex == 8 || iDefIndex == 39) && iZoomLevel == 1)
					iButtons |= IN_ATTACK2;
				
				if (bIsHiding && g_iUncrouchChance[client] <= 50)
					iButtons &= ~IN_DUCK;
					
				if (!IsValidClient(g_iTarget[client]) || !IsPlayerAlive(g_iTarget[client]) || g_fTargetPos[client][2] == 0)
					return Plugin_Continue;
				
				SetEntData(client, g_iBotDispositionOffset, view_as<int>(OPPORTUNITY_FIRE));
				
				if (bIsEnemyVisible && bIsAttacking && GetEntityMoveType(client) != MOVETYPE_LADDER)
				{
					g_bAbortExecute = true;
					
					if (eItems_GetWeaponSlotByDefIndex(iDefIndex) == CS_SLOT_KNIFE)
						BotEquipBestWeapon(client, true);
				
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
						}
						case 1:
						{
							if (fOnTarget > fAimTolerance && !bIsDucking && !bIsReloading)
								SetEntPropFloat(client, Prop_Send, "m_flMaxspeed", 1.0);
						}
						case 9, 40:
						{
							if (GetClientAimTarget(client, true) == g_iTarget[client] && g_bZoomed[client] && !bIsReloading)
							{
								iButtons |= IN_ATTACK;
								
								SetEntPropFloat(client, Prop_Send, "m_flMaxspeed", 1.0);
							}
						}
					}
					
					fClientLoc[2] += 35.5;
					
					if (!GetEntProp(iActiveWeapon, Prop_Data, "m_bInReload") && IsPointVisible(fClientLoc, g_fTargetPos[client]) && fOnTarget > fAimTolerance && fTargetDistance < 2000.0 && (iDefIndex == 7 || iDefIndex == 8 || iDefIndex == 10 || iDefIndex == 13 || iDefIndex == 14 || iDefIndex == 16 || iDefIndex == 39 || iDefIndex == 60 || iDefIndex == 28))
						iButtons |= IN_DUCK;
					
					if (!(GetEntityFlags(client) & FL_ONGROUND))
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
			
			//All these offsets are inside BotProfileManager::Init
			StoreToAddress(pLocalProfile + view_as<Address>(104), view_as<int>(g_fLookAngleMaxAccel[client]), NumberType_Int32);
			StoreToAddress(pLocalProfile + view_as<Address>(116), view_as<int>(g_fLookAngleMaxAccel[client]), NumberType_Int32);
			StoreToAddress(pLocalProfile + view_as<Address>(84), view_as<int>(g_fReactionTime[client]), NumberType_Int32);
		}
		
		if(!(g_iCurrentRound == 0 || g_iCurrentRound == 15))
			CreateTimer(1.0, RFrame_CheckBuyZoneValue, GetClientSerial(client));
		
		if (g_iUSPChance[client] >= 25)
		{
			if (GetClientTeam(client) == CS_TEAM_CT)
			{
				char szUSP[32];
				
				GetClientWeapon(client, szUSP, sizeof(szUSP));
				
				if (strcmp(szUSP, "weapon_hkp2000") == 0)
					CSGO_ReplaceWeapon(client, CS_SLOT_SECONDARY, "weapon_usp_silencer");
			}
		}
	}
}

public Action RFrame_CheckBuyZoneValue(Handle hTimer, int iSerial)
{
	int client = GetClientFromSerial(iSerial);
	
	if (!IsValidClient(client) || !IsPlayerAlive(client))return Plugin_Stop;
	int iTeam = GetClientTeam(client);
	if (iTeam < 2)return Plugin_Stop;
	
	int iAccount = GetEntProp(client, Prop_Send, "m_iAccount");
	
	bool bInBuyZone = view_as<bool>(GetEntProp(client, Prop_Send, "m_bInBuyZone"));
	
	if (!bInBuyZone)return Plugin_Stop;
	
	int iPrimary = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
	
	char szDefaultPrimary[64];
	GetClientWeapon(client, szDefaultPrimary, sizeof(szDefaultPrimary));
	
	if ((iAccount < 2000 || (iAccount > 2000 && iAccount < g_cvBotEcoLimit.IntValue)) && iPrimary == -1)
	{
		if(GetClientTeam(client) == CS_TEAM_T)
			g_bTerroristEco = true;
	}
	
	if ((iAccount > 2000) && (iAccount < g_cvBotEcoLimit.IntValue) && iPrimary == -1 && (strcmp(szDefaultPrimary, "weapon_hkp2000") == 0 || strcmp(szDefaultPrimary, "weapon_usp_silencer") == 0 || strcmp(szDefaultPrimary, "weapon_glock") == 0))
	{
		int iRndPistol = Math_GetRandomInt(1, 3);
		
		switch (iRndPistol)
		{
			case 1: FakeClientCommand(client, "buy p250");
			case 2: FakeClientCommand(client, "buy %s", (iTeam == CS_TEAM_CT) ? "fiveseven" : "tec9");
			case 3: FakeClientCommand(client, "buy deagle");
		}
	}
	return Plugin_Stop;
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
	Handle hGameConfig = LoadGameConfigFile("botstuff.games");
	if (hGameConfig == INVALID_HANDLE)
		SetFailState("Failed to find botstuff.games game config.");
	
	if(!(g_pTheBots = GameConfGetAddress(hGameConfig, "TheBots")))
		SetFailState("Failed to get TheBots address.");
	
	if ((g_iBotTargetSpotOffset = GameConfGetOffset(hGameConfig, "CCSBot::m_targetSpot")) == -1)
		SetFailState("Failed to get CCSBot::m_targetSpot offset.");
	
	if ((g_iBotNearbyEnemiesOffset = GameConfGetOffset(hGameConfig, "CCSBot::m_nearbyEnemyCount")) == -1)
		SetFailState("Failed to get CCSBot::m_nearbyEnemyCount offset.");
	
	if ((g_iBotTaskOffset = GameConfGetOffset(hGameConfig, "CCSBot::m_task")) == -1)
		SetFailState("Failed to get CCSBot::m_task offset.");
	
	if ((g_iFireWeaponOffset = GameConfGetOffset(hGameConfig, "CCSBot::m_fireWeaponTimestamp")) == -1)
		SetFailState("Failed to get CCSBot::m_fireWeaponTimestamp offset.");
	
	if ((g_iEnemyVisibleOffset = GameConfGetOffset(hGameConfig, "CCSBot::m_isEnemyVisible")) == -1)
		SetFailState("Failed to get CCSBot::m_isEnemyVisible offset.");
	
	if ((g_iBotProfileOffset = GameConfGetOffset(hGameConfig, "CCSBot::m_pLocalProfile")) == -1)
		SetFailState("Failed to get CCSBot::m_pLocalProfile offset.");
	
	if ((g_iBotSafeTimeOffset = GameConfGetOffset(hGameConfig, "CCSBot::m_safeTime")) == -1)
		SetFailState("Failed to get CCSBot::m_safeTime offset.");
	
	if ((g_iBotAttackingOffset = GameConfGetOffset(hGameConfig, "CCSBot::m_isAttacking")) == -1)
		SetFailState("Failed to get CCSBot::m_isAttacking offset.");
	
	if ((g_iBotEnemyOffset = GameConfGetOffset(hGameConfig, "CCSBot::m_enemy")) == -1)
		SetFailState("Failed to get CCSBot::m_enemy offset.");
	
	if ((g_iBotLookAtSpotStateOffset = GameConfGetOffset(hGameConfig, "CCSBot::m_lookAtSpotState")) == -1)
		SetFailState("Failed to get CCSBot::m_lookAtSpotState offset.");
	
	if ((g_iBotDispositionOffset = GameConfGetOffset(hGameConfig, "CCSBot::m_disposition")) == -1)
		SetFailState("Failed to get CCSBot::m_disposition offset.");
	
	if ((g_iBotMoraleOffset = GameConfGetOffset(hGameConfig, "CCSBot::m_morale")) == -1)
		SetFailState("Failed to get CCSBot::m_morale offset.");
	
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
	PrepSDKCall_SetFromConf(hGameConfig, SDKConf_Signature, "CCSBot::IsVisible");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer, VDECODE_FLAG_ALLOWNULL);
	PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
	if ((g_hBotIsVisible = EndPrepSDKCall()) == INVALID_HANDLE)SetFailState("Failed to create SDKCall for CCSBot::IsVisible signature!");
	
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
	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hGameConfig, SDKConf_Signature, "SetCrosshairCode");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	if ((g_hSetCrosshairCode = EndPrepSDKCall()) == INVALID_HANDLE)SetFailState("Failed to create SDKCall for SetCrosshairCode signature!");
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConfig, SDKConf_Virtual, "Weapon_Switch");
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer, VDECODE_FLAG_ALLOWNULL);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	if ((g_hSwitchWeaponCall = EndPrepSDKCall()) == INVALID_HANDLE)SetFailState("Failed to create SDKCall for Weapon_Switch offset!");
	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hGameConfig, SDKConf_Signature, "CBotManager::IsLineBlockedBySmoke");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Pointer);
	PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
	if ((g_hIsLineBlockedBySmoke = EndPrepSDKCall()) == INVALID_HANDLE)SetFailState("Failed to create SDKCall for CBotManager::IsLineBlockedBySmoke offset!");
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConfig, SDKConf_Signature, "CCSBot::SetBotEnemy");
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Plain);
	if ((g_hBotSetEnemy = EndPrepSDKCall()) == INVALID_HANDLE)SetFailState("Failed to create SDKCall for CCSBot::SetBotEnemy signature!");
	
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
	
	//CCSBot::ThrowGrenade Detour
	DynamicDetour hBotThrowGrenadeDetour = DynamicDetour.FromConf(hGameData, "CCSBot::ThrowGrenade");
	if(!hBotThrowGrenadeDetour.Enable(Hook_Pre, CCSBot_ThrowGrenade))
		SetFailState("Failed to setup detour for CCSBot::ThrowGrenade");
	
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

public void BotSetEnemy(int client, int iEnemy)
{
	SDKCall(g_hBotSetEnemy, client, iEnemy);
}

public int BotBendLineOfSight(int client, const float fEye[3], const float fTarget[3], float fBend[3], float fAngleLimit)
{
	SDKCall(g_hBotBendLineOfSight, client, fEye, fTarget, fBend, fAngleLimit);
}

public void SetCrosshairCode(Address pCCSPlayerResource, int client, const char[] szCode)
{
	SDKCall(g_hSetCrosshairCode, pCCSPlayerResource, client, szCode);
}

public int BotGetEnemy(int client)
{
	return GetEntDataEnt2(client, g_iBotEnemyOffset);
}

public bool BotIsBusy(int client)
{
	TaskType iBotTask = view_as<TaskType>(GetEntData(client, g_iBotTaskOffset));
	
	return iBotTask == PLANT_BOMB || iBotTask == RESCUE_HOSTAGES || iBotTask == COLLECT_HOSTAGES || iBotTask == GUARD_LOOSE_BOMB || iBotTask == GUARD_BOMB_ZONE || iBotTask == GUARD_HOSTAGES || iBotTask == GUARD_HOSTAGE_RESCUE_ZONE || iBotTask == ESCAPE_FROM_FLAMES;
}

public int GetNearestEntity(int client, char[] szClassname)
{
	int iNearestEntity = -1;
	float fClientOrigin[3], fClientEyes[3], fEntityOrigin[3];
	
	GetEntPropVector(client, Prop_Data, "m_vecOrigin", fClientOrigin); // Line 2607
	GetClientEyePosition(client, fClientEyes); // Line 2607
	
	//Get the distance between the first entity and client
	float fDistance, fNearestDistance = -1.0;
	
	//Find all the entity and compare the distances
	int iEntity = -1;
	while ((iEntity = FindEntityByClassname(iEntity, szClassname)) != -1)
	{
		GetEntPropVector(iEntity, Prop_Data, "m_vecOrigin", fEntityOrigin); // Line 2610
		fDistance = GetVectorDistance(fClientOrigin, fEntityOrigin);
		
		if ((fDistance < fNearestDistance || fNearestDistance == -1.0) && IsPointVisible(fClientEyes, fEntityOrigin))
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

public Action Timer_Zoomed(Handle hTimer, any client)
{
	client = GetClientOfUserId(client);
	
	if(client != 0 && IsClientInGame(client))
		g_bZoomed[client] = true;	
	
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
						if (Math_GetRandomInt(1, 100) <= 80)
							bShootSpine = true;
					}
					case 2, 3, 4, 30, 32, 36, 61, 63:
					{
						if (Math_GetRandomInt(1, 100) <= 30)
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

stock bool IsPointVisible(float fStart[3], float fEnd[3])
{
	TR_TraceRayFilter(fStart, fEnd, MASK_VISIBLE_AND_NPCS, RayType_EndPoint, TraceEntityFilterStuff);
	return TR_GetFraction() >= 0.9;
}

public bool TraceEntityFilterStuff(int iEntity, int iMask)
{
	return iEntity > MaxClients;
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

stock bool IsValidClient(int client)
{
	return client > 0 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && !IsClientSourceTV(client);
}