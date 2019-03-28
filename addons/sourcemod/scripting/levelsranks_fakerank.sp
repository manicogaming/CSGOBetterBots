#pragma semicolon 1
#pragma newdecls required

#include <clientprefs>
#include <sdkhooks>
#include <sdktools>
#include <lvl_ranks>
#include <cstrike>

#define PLUGIN_NAME "Levels Ranks"
#define PLUGIN_AUTHOR "RoadSide Romeo"

int		g_iFRType,
		g_iFRButton[MAXPLAYERS+1],
		g_iRankPlayers[MAXPLAYERS+1],
		g_iRankPlayersType[MAXPLAYERS+1],
		g_iRankOffset,
		g_iRankOffsetType;
Handle	g_hFakeRank = null;

public Plugin myinfo = {name = "[LR] Module - FakeRank", author = PLUGIN_AUTHOR, version = PLUGIN_VERSION}
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	switch(GetEngineVersion())
	{
		case Engine_CSGO: LogMessage("[" ... PLUGIN_NAME ... " Fake Rank] Successfully launched");
		default: SetFailState("[" ... PLUGIN_NAME ... " Fake Rank] Plug-in works only on CS:GO");
	}
}

public void OnPluginStart()
{
	HookEvent("player_spawn", PlayerSpawn);
	g_hFakeRank = RegClientCookie("LR_FakeRank", "LR_FakeRank", CookieAccess_Private);
	LoadTranslations("levels_ranks_fakerank.phrases");

	for(int iClient = 1; iClient <= MaxClients; iClient++)
    {
		if(IsClientInGame(iClient) && IsFakeClient(iClient))
		{
			if(AreClientCookiesCached(iClient))
			{
				OnClientCookiesCached(iClient);
			}
		}
	}
}

public void OnMapStart()
{
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), "configs/levels_ranks/fakerank.ini");
	KeyValues hLR_FR = new KeyValues("LR_FakeRank");

	if(!hLR_FR.ImportFromFile(sPath) || !hLR_FR.GotoFirstSubKey())
	{
		SetFailState("[" ... PLUGIN_NAME ... " Fake Rank] file is not found (%s)", sPath);
	}

	hLR_FR.Rewind();

	if(hLR_FR.JumpToKey("Settings"))
	{
		g_iFRType = hLR_FR.GetNum("type", 0);
	}
	else SetFailState("[" ... PLUGIN_NAME ... " Fake Rank] section Settings is not found (%s)", sPath);
	delete hLR_FR;

	g_iRankOffset = FindSendPropInfo("CCSPlayerResource", "m_iCompetitiveRanking");
	g_iRankOffsetType = FindSendPropInfo("CCSPlayerResource", "m_iCompetitiveRankType");
	SDKHook(FindEntityByClassname(MaxClients + 1, "cs_player_manager"), SDKHook_ThinkPost, Hook_OnThinkPost);
}

public void OnMapEnd()
{
	SDKUnhook(FindEntityByClassname(MaxClients + 1, "cs_player_manager"), SDKHook_ThinkPost, Hook_OnThinkPost);
}

public Action OnPlayerRunCmd(int iClient, int& buttons, int& impulse, float fVel[3], float fAngles[3], int& iWeapon)
{
	if(StartMessageOne("ServerRankRevealAll", iClient) != INVALID_HANDLE)
	{
		EndMessage();
	}
}

public void Hook_OnThinkPost(int iEnt)
{
	SetEntDataArray(iEnt, g_iRankOffset, g_iRankPlayers, MAXPLAYERS+1);
	SetEntDataArray(iEnt, g_iRankOffsetType, g_iRankPlayersType, MAXPLAYERS+1, 1);
}

public void LR_OnLevelChanged(int iClient, int iNewLevel, bool bUp)
{
	g_iRankPlayers[iClient] = iNewLevel;
	CheckRankType(iClient);
}  

public void PlayerSpawn(Handle hEvent, char[] sEvName, bool bDontBroadcast)
{
	int iClient = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	g_iRankPlayers[iClient] = LR_GetClientInfo(iClient, ST_RANK);
	
	CheckRankType(iClient);
}

public void LR_OnMenuCreated(int iClient, int iRank, Menu& hMenu)
{
	if(iRank == 0 && g_iFRType == 2)
	{
		char sText[64];
		SetGlobalTransTarget(iClient);
		switch(g_iFRButton[iClient])
		{
			case 0: FormatEx(sText, sizeof(sText), "%t", "FR_Menu_Normal");
			case 1: FormatEx(sText, sizeof(sText), "%t", "FR_Menu_Wingman");
		}
		hMenu.AddItem("FakeRank", sText);
	}
}

public void LR_OnMenuItemSelected(int iClient, int iRank, const char[] sInfo)
{
	if(iRank == 0 && strcmp(sInfo, "FakeRank") == 0)
	{
		switch(g_iFRButton[iClient])
		{
			case 0: g_iFRButton[iClient] = 1;
			case 1: g_iFRButton[iClient] = 0;
		}

		CheckRankType(iClient);
		LR_MenuInventory(iClient);
	}
}

void CheckRankType(int iClient)
{
	switch(g_iFRType)
	{
		case 1: g_iRankPlayersType[iClient] = 7;
		case 2:
		{
			switch(g_iFRButton[iClient])
			{
				case 0: g_iRankPlayersType[iClient] = 0;
				case 1: g_iRankPlayersType[iClient] = 7;
			}
		}
	}
}

public void OnClientCookiesCached(int iClient)
{
	char sCookie[8];
	GetClientCookie(iClient, g_hFakeRank, sCookie, sizeof(sCookie));
	g_iFRButton[iClient] = StringToInt(sCookie);
} 

public void OnClientDisconnect(int iClient)
{
	if(AreClientCookiesCached(iClient))
	{
		char sBuffer[8];
		FormatEx(sBuffer, sizeof(sBuffer), "%i", g_iFRButton[iClient]);
		SetClientCookie(iClient, g_hFakeRank, sBuffer);		
	}
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