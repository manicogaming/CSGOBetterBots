/***************************************************************************
****
****		Author :				RoadSide Romeo	creator of the plugin; moduls for the plugin
****		Partners :			R1KO			fix errors; module system;
****							Kruzya			fix errors;
****							Grey™			new syntax;
****
****		Date of creation :		November 27, 2014
****		Date of official release :	April 12, 2015
****		Last update :			February 08, 2018
****
***************************************************************************/

#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

#define EngineGameCSGO 1
#define EngineGameCSS 2

#undef REQUIRE_EXTENSIONS
#include <cstrike>
#define REQUIRE_EXTENSIONS

#pragma newdecls required
#include <lvl_ranks>

#define PLUGIN_NAME "Levels Ranks"
#define PLUGIN_AUTHOR "RoadSide Romeo"
#define PLUGIN_SITE "http://hlmod.ru/resources/levels-ranks-core.177/"

#define EXP(%0) g_iClientData[%0][0]
#define RANK(%0) g_iClientData[%0][1]
#define KILLS(%0) g_iClientData[%0][2]
#define DEATHS(%0) g_iClientData[%0][3]
#define SHOOTS(%0) g_iClientData[%0][4]
#define HITS(%0) g_iClientData[%0][5]
#define HEADSHOTS(%0) g_iClientData[%0][6]
#define ASSISTS(%0) g_iClientData[%0][7]
#define VIP(%0) g_iClientData[%0][8]

#define HookLR(%0) HookEventEx(#%0, LRHooks)
#define LogLR(%0) LogError("[" ... PLUGIN_NAME ... " Core] " ... %0)
#define CrashLR(%0) SetFailState("[" ... PLUGIN_NAME ... " Core] " ... %0)
#define MenuLR(%0) public int %0(Menu hMenu, MenuAction mAction, int iClient, int iSlot)
#define DBCallbackLR(%0) public void %0(Database db, DBResultSet dbRs, const char[] sError, any iClient)

#define SNDCHAN_LR_RANK 80

int			g_iClientData[MAXPLAYERS+1][9],
			g_iKillstreak[MAXPLAYERS+1],
			g_iEngineGame,
			g_iCountRetryConnect,
			g_iDBCountPlayers,
			g_iDBRankPlayer[MAXPLAYERS+1],
			g_iCountPlayers;
float			g_fCoefficient[MAXPLAYERS+1][2];
bool			g_bHaveBomb[MAXPLAYERS+1];
Handle		g_hForward_OnMenuCreated,
			g_hForward_OnMenuItemSelected,
			g_hForward_OnLevelChanged,
			g_hForward_OnLevelCheckSynhc;

#include "levels_ranks/settings.sp"
#include "levels_ranks/database.sp"
#include "levels_ranks/custom_functions.sp"
#include "levels_ranks/menus.sp"
#include "levels_ranks/hooks.sp"
#include "levels_ranks/natives.sp"

public Plugin myinfo = {name = "[LR] Core", author = PLUGIN_AUTHOR, version = PLUGIN_VERSION, url = PLUGIN_SITE}
public void OnPluginStart()
{
	switch(GetEngineVersion())
	{
		case Engine_CSGO: g_iEngineGame = EngineGameCSGO;
		case Engine_CSS: g_iEngineGame = EngineGameCSS;
		default: CrashLR("This plugin works only on CS:GO and CS:Source");
	}

	g_hForward_OnMenuCreated = CreateGlobalForward("LR_OnMenuCreated", ET_Ignore, Param_Cell, Param_Cell, Param_CellByRef);
	g_hForward_OnMenuItemSelected = CreateGlobalForward("LR_OnMenuItemSelected", ET_Ignore, Param_Cell, Param_Cell, Param_String);
	g_hForward_OnLevelChanged = CreateGlobalForward("LR_OnLevelChanged", ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
	g_hForward_OnLevelCheckSynhc = CreateGlobalForward("LR_OnCheckSync", ET_Ignore, Param_CellByRef);

	LoadTranslations("levels_ranks_core.phrases");
	RegAdminCmd("sm_lvl_reset", ResetStatsFull, ADMFLAG_ROOT);

	SetSettings();
	MakeHooks();
	ConnectDB();
}

public void OnMapStart()
{
	char sPath[256];
	File hFile = OpenFile("addons/sourcemod/configs/levels_ranks/downloads.ini", "r");

	if(hFile == null)
	{
		CrashLR("Unable to load (addons/sourcemod/configs/levels_ranks/downloads.ini)");
	}

	while(hFile.ReadLine(sPath, 256))
	{
		TrimString(sPath);
		if(IsCharAlpha(sPath[0]))
		{
			AddFileToDownloadsTable(sPath);
		}
	}

	delete hFile;

	if(g_bSoundLVL) LR_PrecacheSound();
}

public void OnMapEnd()
{
	if(g_iDaysDeleteFromBase > 0)
	{
		PurgeDatabase();
	}
}

public void OnClientPutInServer(int iClient)
{
	if(IsClientAuthorized(iClient))
	{
		LoadDataPlayer(iClient);
	}
}

public void OnClientAuthorized(int iClient)
{
	if(IsClientInGame(iClient) || IsFakeClient(iClient))
	{
		LoadDataPlayer(iClient);
	}
}

public void OnClientDisconnect(int iClient)
{
	g_iKillstreak[iClient] = 0;
	g_fCoefficient[iClient][0] = 0.0;
	g_fCoefficient[iClient][1] = 0.0;
	SaveDataPlayer(iClient);
	g_bInitialized[iClient] = false;
}

public void OnPluginEnd()
{
	for(int iClient = 1; iClient <= MaxClients; iClient++)
	{
		if(IsClientInGame(iClient) && IsFakeClient(iClient))
		{
			OnClientDisconnect(iClient);	
		}
	}
}