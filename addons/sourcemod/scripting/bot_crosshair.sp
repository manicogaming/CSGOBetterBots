#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <cstrike>
#include <dhooks>

public Plugin myinfo = 
{
	name = "BOT Crosshairs", 
	author = "manico", 
	description = "Assigns crosshairs to bots.", 
	version = "1.0", 
	url = "http://steamcommunity.com/id/manico001"
};

char g_szCrosshairCode[MAXPLAYERS+1][35];
Handle g_hSetCrosshairCode;

public void OnPluginStart()
{
	LoadSDK();
}

public void OnMapStart()
{
	SDKHook(FindEntityByClassname(MaxClients + 1, "cs_player_manager"), SDKHook_ThinkPost, OnThinkPost);
}

public void OnClientPostAdminCheck(int client)
{
	if (IsValidClient(client) && IsFakeClient(client))
	{
		char szBotName[MAX_NAME_LENGTH];
		
		GetClientName(client, szBotName, sizeof(szBotName));
		
		GetCrosshairCode(szBotName, g_szCrosshairCode[client], 35);
	}
}

public void OnThinkPost(int iEnt)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && IsFakeClient(i))
		{
			SetCrosshairCode(GetEntityAddress(iEnt), i, g_szCrosshairCode[i]);
		}
	}
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
	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hGameConfig, SDKConf_Signature, "SetCrosshairCode");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	if ((g_hSetCrosshairCode = EndPrepSDKCall()) == INVALID_HANDLE)SetFailState("Failed to create SDKCall for SetCrosshairCode signature!");
	
	delete hGameConfig;
}

public void SetCrosshairCode(Address pCCSPlayerResource, int client, const char[] szCode)
{
	SDKCall(g_hSetCrosshairCode, pCCSPlayerResource, client, szCode);
}

stock bool IsValidClient(int client)
{
	return client > 0 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && !IsClientSourceTV(client);
}